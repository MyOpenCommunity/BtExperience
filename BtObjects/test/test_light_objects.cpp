#include "test_light_objects.h"
#include "lightobjects.h"
#include "lighting_device.h"
#include "objecttester.h"
#include "main.h" // bt_global::config

#include <QtTest>


void TestLight::initObjects(LightingDevice *_dev, Light *_obj)
{
	dev = _dev;
	obj = _obj;
}

void TestLight::init()
{
	bt_global::config = new QHash<GlobalField, QString>();
	(*bt_global::config)[TS_NUMBER] = 2;

	LightingDevice *d = new LightingDevice("3", NOT_PULL);

	obj = new Light("", "", d);
	dev = new LightingDevice("3", NOT_PULL, 1);
}

void TestLight::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;

	delete bt_global::config;
	bt_global::config = NULL;
}

void TestLight::testSetStatus()
{
	obj->setStatus(true);
	dev->turnOn();
	compareClientCommand();

	obj->setStatus(false);
	dev->turnOff();
	compareClientCommand();
}

void TestLight::testReceiveStatus()
{
	DeviceValues v;
	v[LightingDevice::DIM_DEVICE_ON] = true;

	ObjectTester t(obj, SIGNAL(statusChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), true);

	obj->valueReceived(v);
	t.checkNoSignals();
}


void TestDimmer::initObjects(DimmerDevice *_dev, Dimmer *_obj)
{
	dev = _dev;
	obj = _obj;

	TestLight::initObjects(dev, obj);
}

void TestDimmer::init()
{
	bt_global::config = new QHash<GlobalField, QString>();
	(*bt_global::config)[TS_NUMBER] = 2;

	DimmerDevice *d = new DimmerDevice("3", NOT_PULL);

	obj = new Dimmer("", "", d);
	dev = new DimmerDevice("3", NOT_PULL, 1);

	initObjects(dev, obj);
}

void TestDimmer::testLevelDown()
{
	obj->decreaseLevel();
	dev->decreaseLevel();
	compareClientCommand();
}

void TestDimmer::testLevelUp()
{
	obj->increaseLevel();
	dev->increaseLevel();
	compareClientCommand();
}

void TestDimmer::testReceiveLevel()
{
	DeviceValues v;
	v[LightingDevice::DIM_DEVICE_ON] = true;
	v[LightingDevice::DIM_DIMMER_LEVEL] = 3;

	ObjectTester tstatus(obj, SIGNAL(statusChanged()));
	ObjectTester tperc(obj, SIGNAL(percentageChanged()));
	obj->valueReceived(v);
	tstatus.checkSignals();
	tperc.checkSignals();
	QCOMPARE(obj->getStatus(), true);
	QCOMPARE(obj->getPercentage(), 10);

	obj->valueReceived(v);
	tstatus.checkNoSignals();
	tperc.checkNoSignals();
}


void TestDimmer100::init()
{
	bt_global::config = new QHash<GlobalField, QString>();
	(*bt_global::config)[TS_NUMBER] = 2;

	Dimmer100Device *d = new Dimmer100Device("3", NOT_PULL);

	obj = new Dimmer("", "", d);
	dev = new Dimmer100Device("3", NOT_PULL, 1);

	initObjects(dev, obj);
}

void TestDimmer100::testReceiveLevel100()
{
	DeviceValues v;
	v[LightingDevice::DIM_DEVICE_ON] = true;
	v[LightingDevice::DIM_DIMMER_LEVEL] = 5;
	v[LightingDevice::DIM_DIMMER100_LEVEL] = 34;
	v[LightingDevice::DIM_DIMMER100_SPEED] = 50;

	ObjectTester tstatus(obj, SIGNAL(statusChanged()));
	ObjectTester tperc(obj, SIGNAL(percentageChanged()));
	obj->valueReceived(v);
	tstatus.checkSignals();
	tperc.checkSignals();
	QCOMPARE(obj->getStatus(), true);
	QCOMPARE(obj->getPercentage(), 30);

	obj->valueReceived(v);
	tstatus.checkNoSignals();
	tperc.checkNoSignals();
}
