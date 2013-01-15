#include "test_media_models.h"
#include "mediamodel.h"
#include "objecttester.h"
#include "iteminterface.h"

#include <QtTest>


namespace QTest
{
	template<> char *toString(const QList<ItemInterface *> &l)
	{
		QByteArray ba = "Objectlist(";
		for (int i = 0; i < l.length(); ++i)
		{
			ba += "(" + QString().sprintf("%p", l[i]) + ")";
		}
		ba = ba.left(ba.length() - 1) + ")";
		return qstrdup(ba.data());
	}
}


void TestMediaModel::initObjects(MediaDataModel *_src, MediaModel *_obj, QList<ItemInterface *> _items)
{
	src = _src;
	obj = _obj;
	items = _items;

	Q_ASSERT(_items.count() == 5);

	for (int i = 0; i < items.count(); ++i)
	{
		if (i < 3)
			items[i]->setContainerUii(3);
		else if (i < 5)
			items[i]->setContainerUii(1);
		else
			items[i]->setContainerUii(-1);
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

void TestMediaModel::testRemoveNoElements()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));
	src->removeRows(1, 0);
	qApp->processEvents();
	ts.checkNoSignals();

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->getRangeCount(), 3);
	qApp->processEvents();
	ts.checkSignals();
}

void TestMediaModel::testRemove()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	qApp->processEvents(); // flush pending countChanged()

	// remove one element
	ObjectTester ts(obj, SIGNAL(countChanged()));
	obj->remove(1);
	qApp->processEvents();
	ts.checkSignalCount(SIGNAL(countChanged), 2);

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->getRangeCount(), 2);

	qApp->processEvents();
	ts.checkSignals();
}

void TestMediaModel::testRemove2()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));
	obj->remove(2);
	obj->remove(1);
	obj->remove(0);
	qApp->processEvents();
	ts.checkSignalCount(SIGNAL(countChanged()), 2);

	QCOMPARE(obj->getCount(), 0);
	QCOMPARE(obj->getRangeCount(), 0);
}

void TestMediaModel::testRemove3()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	qApp->processEvents(); // flush pending countChanged()
	ObjectTester ts(obj, SIGNAL(countChanged()));

	// remove an element in the middle
	obj->remove(1);
	qApp->processEvents();
	ts.checkSignalCount(SIGNAL(countChanged), 2);
	QCOMPARE(src->getObject(1), items[2]);
}

void TestMediaModel::testRemoveObject()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	qApp->processEvents(); // flush pending countChanged()
	ObjectTester ts(obj, SIGNAL(countChanged()));

	obj->remove(items[0]);
	ts.checkSignals();
	QCOMPARE(src->item_list, items.mid(1, 2));
}

void TestMediaModel::testRemoveFiltered()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	(*src) << items[3];
	(*src) << items[4];

	obj->setContainers(QVariantList() << 3);
	obj->rowCount(); // force recount

	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);
	QCOMPARE(src->rowCount(), 5);
	qApp->processEvents();
	ts.clearSignals();

	obj->remove(1);
	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->rowCount(), 2);
	QCOMPARE(src->rowCount(), 4);
}

void TestMediaModel::testRemoveAll()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	(*src) << items[3];
	(*src) << items[4];

	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 5);
	QCOMPARE(src->rowCount(), 5);
	qApp->processEvents();
	ts.clearSignals();

	obj->clear();
	qApp->processEvents();
	ts.checkSignalCount(SIGNAL(countChanged), 1);

	QCOMPARE(obj->getCount(), 0);
	QCOMPARE(obj->rowCount(), 0);
	QCOMPARE(src->rowCount(), 0);
}

void TestMediaModel::testRemoveAllFiltered()
{
	(*src) << items[0];
	(*src) << items[1];
	(*src) << items[2];
	(*src) << items[3];
	(*src) << items[4];

	obj->setRange(QVariantList() << 1 << 2);
	obj->setContainers(QVariantList() << 3);
	obj->rowCount(); // force recount

	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 1);
	QCOMPARE(src->rowCount(), 5);
	qApp->processEvents();
	ts.clearSignals();

	obj->clear();
	qApp->processEvents();
	ts.checkSignalCount(SIGNAL(countChanged), 1);

	QCOMPARE(obj->getCount(), 0);
	QCOMPARE(obj->rowCount(), 0);
	QCOMPARE(src->rowCount(), 2);
}

void TestMediaModel::testRemoveAllWithRange()
{
	foreach (ItemInterface *i, items)
		(*src) << i;
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	obj->setRange(QVariantList() << 2 << 4);

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 2);
	ts.clearSignals();

	QCOMPARE(obj->getObject(0), items[2]);
	QCOMPARE(obj->getObject(1), items[3]);

	obj->clear();
	qApp->processEvents();
	ts.checkSignalCount(SIGNAL(countChanged), 2);

	QCOMPARE(obj->getCount(), 0);
	QCOMPARE(obj->rowCount(), 0);
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
	ts.checkSignalCount(SIGNAL(countChanged()), 2);

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
	ts.checkSignalCount(SIGNAL(countChanged()), 2);

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
