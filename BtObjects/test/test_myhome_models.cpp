#include "test_myhome_models.h"
#include "objectmodel.h"
#include "lightobjects.h"
#include "mediaobjects.h"
#include "lighting_device.h"
#include "media_device.h"
#include "objecttester.h"
#include "main.h" // bt_global::config

#include <QtTest>


void TestObjectModel::init()
{
	bt_global::config = new QHash<GlobalField, QString>();

	dev1 = new DimmerDevice("1");
	dev2 = AmplifierDevice::createDevice("22");

	light1 = new Light("light1", "1", QTime(), Light::FixedTimingDisabled, true, dev1);
	light2 = new Light("light2", "2", QTime(), Light::FixedTimingDisabled, true, dev1);
	light3 = new Light("light3", "3", QTime(), Light::FixedTimingDisabled, true, dev1);

	amplifier1 = new Amplifier(2, "amplifier1", dev2);
	amplifier2 = new Amplifier(3, "amplifier1", dev2);

	src = new ObjectDataModel();

	ObjectModel::setGlobalSource(src);

	obj = new ObjectModel();

	QList<ItemInterface *> items;

	items << light1 << light2 << light3 << amplifier1 << amplifier2;

	initObjects(src, obj, items);
}

void TestObjectModel::cleanup()
{
	delete dev1;
	delete obj;
	delete src;

	clearDeviceCache(); // deletes dev2
	ObjectModel::setGlobalSource(0);

	delete bt_global::config;
	bt_global::config = 0;
}

void TestObjectModel::testFilterObjectId()
{
	*src << light1;
	*src << light2;
	*src << light3;
	*src << amplifier1;
	*src << amplifier2;
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 5);
	qApp->processEvents();
	ts.clearSignals();

	obj->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdLightCustom);

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), light1);
	QCOMPARE(obj->getObject(1), light2);
	QCOMPARE(obj->getObject(2), light3);

	obj->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdSoundAmplifier);

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->rowCount(), 2);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), amplifier1);
	QCOMPARE(obj->getObject(1), amplifier2);
}

void TestObjectModel::testFilterObjectKey()
{
	*src << light1;
	*src << light2;
	*src << light3;
	*src << amplifier1;
	*src << amplifier2;
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 5);
	qApp->processEvents();
	ts.clearSignals();

	obj->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdLightCustom
					     << "objectKey" << "2");

	QCOMPARE(obj->getCount(), 1);
	QCOMPARE(obj->rowCount(), 1);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), light2);

	obj->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdSoundAmplifier
					     << "objectKey" << "3");

	QCOMPARE(obj->getCount(), 1);
	QCOMPARE(obj->rowCount(), 1);

	qApp->processEvents();
	ts.checkSignals();  // TODO should not emit countChanged()

	QCOMPARE(obj->getObject(0), amplifier2);

	QVariantList filters;
	QVariantMap filter;

	// sets filters to select alarm clocks objects
	filter["objectId"] = ObjectInterface::IdLightCustom;
	filter["objectKey"] = "1";
	filters << filter;
	filter["objectId"] = ObjectInterface::IdLightCustom;
	filter["objectKey"] = "2";
	filters << filter;

	obj->setFilters(filters);

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->rowCount(), 2);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), light1);
	QCOMPARE(obj->getObject(1), light2);
}

void TestObjectModel::testMultipleFilter()
{
	*src << light1;
	*src << light2;
	*src << light3;
	*src << amplifier1;
	*src << amplifier2;
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	QCOMPARE(obj->getCount(), 5);
	QCOMPARE(obj->rowCount(), 5);
	qApp->processEvents();
	ts.clearSignals();

	obj->setFilters(ObjectModelFilters() << "objectKey" << "2" << "objectId" << ObjectInterface::IdLightCustom <<
			ObjectModelFilters() << "objectKey" << "3" << "objectId" << ObjectInterface::IdSoundAmplifier);

	QCOMPARE(obj->getCount(), 2);
	QCOMPARE(obj->rowCount(), 2);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), light2);
	QCOMPARE(obj->getObject(1), amplifier2);
}

void TestObjectModel::testComplexFilter()
{
	*src << light1;
	*src << light2;
	*src << light3;
	*src << amplifier1;
	*src << amplifier2;
	qApp->processEvents(); // flush pending countChanged()

	ObjectTester ts(obj, SIGNAL(countChanged()));

	obj->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdLightCustom);

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 3);

	qApp->processEvents();
	ts.checkSignals();

	obj->setRange(QVariantList() << 1 << 4);

	QCOMPARE(obj->getCount(), 3);
	QCOMPARE(obj->rowCount(), 2);

	qApp->processEvents();
	ts.checkSignals();

	QCOMPARE(obj->getObject(0), light2);
	QCOMPARE(obj->getObject(1), light3);
}
