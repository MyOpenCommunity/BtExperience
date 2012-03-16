#include "test_media_objects.h"
#include "media_device.h"
#include "mediaobjects.h"
#include "objecttester.h"

#include <QtTest/QtTest>


void TestAmplifier::init()
{
	AmplifierDevice *d = AmplifierDevice::createDevice("32");

	obj = new Amplifier(3, "", d);
	dev = AmplifierDevice::createDevice("32", 1);
}

void TestAmplifier::cleanup()
{
	delete obj;
	// amplifiers created above are in device cache
	clearDeviceCache();
}

void TestAmplifier::testSetActive()
{
	obj->setActive(true);
	dev->turnOn();
	compareClientCommand();

	obj->setActive(false);
	dev->turnOff();
	compareClientCommand();
}

void TestAmplifier::testSetVolume()
{
	obj->setVolume(10);
	dev->setVolume(10);
	compareClientCommand();
}

void TestAmplifier::testReceiveActive()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(activeChanged()));

	// on status
	v[AmplifierDevice::DIM_STATUS] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->isActive(), true);

	obj->valueReceived(v);
	t.checkNoSignals();

	// off status
	v[AmplifierDevice::DIM_STATUS] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->isActive(), false);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestAmplifier::testReceiveVolume()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(volumeChanged()));

	// on status
	v[AmplifierDevice::DIM_VOLUME] = 12;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getVolume(), 12);

	obj->valueReceived(v);
	t.checkNoSignals();

	// off status
	v[AmplifierDevice::DIM_VOLUME] = 13;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getVolume(), 13);

	obj->valueReceived(v);
	t.checkNoSignals();
}
