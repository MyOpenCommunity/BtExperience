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

	obj = new Light("", "", QTime(), Light::FixedTimingDisabled, true, d);
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
	obj->setActive(true);
	dev->turnOn();
	compareClientCommand();

	obj->setActive(false);
	dev->turnOff();
	compareClientCommand();
}

void TestLight::testReceiveStatus()
{
	DeviceValues v;
	v[LightingDevice::DIM_DEVICE_ON] = true;

	ObjectTester t(obj, SIGNAL(activeChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->isActive(), true);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestLight::testSetTiming()
{
	obj->hours = 15;
	obj->minutes = 0;
	obj->seconds = 3;
	obj->setActiveWithTiming();
	dev->variableTiming(15, 0, 3);
	compareClientCommand();
}

void TestLight::testSetHours()
{
	const int value = 1;
	obj->hours = value;
	obj->setHours(-1);
	QCOMPARE(obj->hours, value);
	obj->setHours(256);
	QCOMPARE(obj->hours, value);
	obj->setHours(255);
	QCOMPARE(obj->hours, 255);
	obj->setHours(0);
	QCOMPARE(obj->hours, 0);
}

void TestLight::testSetMinutes()
{
	const int value = 1;
	obj->minutes = value;
	obj->setMinutes(-1);
	QCOMPARE(obj->minutes, value);
	obj->setMinutes(60);
	QCOMPARE(obj->minutes, value);
	obj->setMinutes(59);
	QCOMPARE(obj->minutes, 59);
	obj->setMinutes(0);
	QCOMPARE(obj->minutes, 0);
}

void TestLight::testSetSeconds()
{
	const int value = 1;
	obj->seconds = value;
	obj->setSeconds(-1);
	QCOMPARE(obj->seconds, value);
	obj->setSeconds(60);
	QCOMPARE(obj->seconds, value);
	obj->setSeconds(59);
	QCOMPARE(obj->seconds, 59);
	obj->setSeconds(0);
	QCOMPARE(obj->seconds, 0);
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

	obj = new Dimmer("", "", QTime(), Light::FixedTimingDisabled, true, d);
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

	ObjectTester tstatus(obj, SIGNAL(activeChanged()));
	ObjectTester tperc(obj, SIGNAL(percentageChanged()));
	obj->valueReceived(v);
	tstatus.checkSignals();
	tperc.checkSignals();
	QCOMPARE(obj->isActive(), true);
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

	obj = new Dimmer100("", "", QTime(), Light::FixedTimingDisabled, true, d, 255, 255);
	dev = new Dimmer100Device("3", NOT_PULL, 1);

	initObjects(dev, obj);
}

void TestDimmer100::testReceiveLevel()
{
	DeviceValues v;
	v[LightingDevice::DIM_DEVICE_ON] = true;
	v[LightingDevice::DIM_DIMMER_LEVEL] = 5;
	v[LightingDevice::DIM_DIMMER100_LEVEL] = 34;
	v[LightingDevice::DIM_DIMMER100_SPEED] = 50;

	ObjectTester tstatus(obj, SIGNAL(activeChanged()));
	ObjectTester tperc(obj, SIGNAL(percentageChanged()));
	obj->valueReceived(v);
	tstatus.checkSignals();
	tperc.checkSignals();
	QCOMPARE(obj->isActive(), true);
	QCOMPARE(obj->getPercentage(), 34);

	obj->valueReceived(v);
	tstatus.checkNoSignals();
	tperc.checkNoSignals();
}

void TestDimmer100::testSetStatus()
{
	obj->setOnSpeed(47);
	obj->setActive(true);
	dev->turnOn(47);
	compareClientCommand();

	obj->setOffSpeed(48);
	obj->setActive(false);
	dev->turnOff(48);
	compareClientCommand();
}

void TestDimmer100::testLevelUp100()
{
	obj->setStepAmount(17);
	obj->setStepSpeed(127);
	obj->decreaseLevel100();
	dev->decreaseLevel100(17, 127);
	compareClientCommand();
}

void TestDimmer100::testLevelDown100()
{
	obj->setStepAmount(16);
	obj->setStepSpeed(126);
	obj->decreaseLevel100();
	dev->decreaseLevel100(16, 126);
	compareClientCommand();
}

void TestDimmer100::testOnSpeed()
{
	ObjectTester t(obj, SIGNAL(onSpeedChanged()));

	obj->setOnSpeed(7);
	QCOMPARE(obj->getOnSpeed(), 7);
	t.checkSignals();

	obj->setOnSpeed(7);
	t.checkNoSignals();
}

void TestDimmer100::testOffSpeed()
{
	ObjectTester t(obj, SIGNAL(offSpeedChanged()));

	obj->setOffSpeed(7);
	QCOMPARE(obj->getOffSpeed(), 7);
	t.checkSignals();

	obj->setOffSpeed(7);
	t.checkNoSignals();
}

void TestDimmer100::testStepSpeed()
{
	ObjectTester t(obj, SIGNAL(stepSpeedChanged()));

	obj->setStepSpeed(7);
	QCOMPARE(obj->getStepSpeed(), 7);
	t.checkSignals();

	obj->setStepSpeed(7);
	t.checkNoSignals();
}

void TestDimmer100::testStepAmount()
{
	ObjectTester t(obj, SIGNAL(stepAmountChanged()));

	obj->setStepAmount(7);
	QCOMPARE(obj->getStepAmount(), 7);
	t.checkSignals();

	obj->setStepAmount(7);
	t.checkNoSignals();
}

void TestDimmer100::testSetTiming()
{
	obj->setOnSpeed(123);
	obj->setHours(15);
	obj->setMinutes(0);
	obj->setSeconds(3);
	obj->setActiveWithTiming();
	dev->turnOn(123);
	dev->variableTiming(15, 0, 3);
	compareClientCommand();
}
