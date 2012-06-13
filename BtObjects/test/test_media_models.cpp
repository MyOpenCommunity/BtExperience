#include "test_media_models.h"
#include "mediamodel.h"
#include "objecttester.h"
#include "iteminterface.h"

#include <QtTest>


void TestMediaModel::initObjects(MediaDataModel *_src, MediaModel *_obj, QList<ItemInterface *> _items)
{
	src = _src;
	obj = _obj;
	items = _items;

	Q_ASSERT(_items.count() == 5);

	for (int i = 0; i < items.count(); ++i)
	{
		if (i < 3)
			items[i]->setContainerId(3);
		else if (i < 5)
			items[i]->setContainerId(1);
		else
			items[i]->setContainerId(-1);
	}
}

void TestMediaModel::init()
{
	QList<ItemInterface *> test_items;

	for (int i = 0; i < 5; ++i)
		test_items << new ItemInterface;

	src = new MediaDataModel();
	obj = new MediaModel();
	obj->setSource(src);

	initObjects(src, obj, test_items);
}

void TestMediaModel::cleanup()
{
	delete obj;
	delete src;
}

void TestMediaModel::testInsert()
{
	ObjectTester ts(obj, SIGNAL(countChanged()));

	(*src) << items[0];
	// TODO ts.checkSignals();

	(*src) << items[1];
	// TODO ts.checkSignals();

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->rowCount(), 2);
	QCOMPARE(src->getObject(0), items[0]);
	QCOMPARE(src->getObject(1), items[1]);

	(*src) << items[2];
	// TODO ts.checkSignals();

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);

	for (int i = 0; i < 3; ++i)
		QCOMPARE(obj->getObject(i)->parent(), src);

	QCOMPARE(src->getObject(2), items[2]);
}

void TestMediaModel::testRemove()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);

	src->removeRows(1, 0);
	ts.checkNoSignals();
	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);

	obj->remove(1);

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->rowCount(), 2);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(src->getObject(0), items[0]);
	QCOMPARE(src->getObject(1), items[2]);
}

void TestMediaModel::testRemoveAll()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);

	obj->clear();

	QCOMPARE(obj->getCount(), 0);
	QCOMPARE(obj->rowCount(), 0);

	qApp->processEvents();
	ts.checkSignals();
}

void TestMediaModel::testFilterContainer()
{
	foreach (ItemInterface *i, items)
		(*src) << i;
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 5);

	obj->setContainers(QVariantList() << 3);

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), items[0]);
	QCOMPARE(obj->getObject(1), items[1]);
	QCOMPARE(obj->getObject(2), items[2]);

	obj->setContainers(QVariantList() << 1);

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->rowCount(), 2);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), items[3]);
	QCOMPARE(obj->getObject(1), items[4]);
}

void TestMediaModel::testFilterRange()
{
	foreach (ItemInterface *i, items)
		(*src) << i;
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 5);

	obj->setRange(QVariantList() << 2 << 4);

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 2);

	qApp->processEvents();
	ts.checkSignals(); // TODO should not emit countChanged()

	QCOMPARE(obj->getObject(0), items[2]);
	QCOMPARE(obj->getObject(1), items[3]);

	obj->setRange(QVariantList() << 2 << -1);

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 3);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), items[2]);
	QCOMPARE(obj->getObject(1), items[3]);
	QCOMPARE(obj->getObject(2), items[4]);
}
