#include "test_media_objects.h"
#include "media_device.h"
#include "mediaobjects.h"
#include "objecttester.h"

#include <QtTest/QtTest>


void TestSourceBase::initObjects(SourceDevice *_dev, SourceBase *_obj)
{
	dev = _dev;
	obj = _obj;
}

void TestSourceBase::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestSourceBase::testSetActive()
{
	obj->setActive(3);
	dev->turnOn("3");
	compareClientCommand();
}

void TestSourceBase::testPreviousTrack()
{
	obj->previousTrack();
	dev->prevTrack();
	compareClientCommand();
}

void TestSourceBase::testNextTrack()
{
	obj->nextTrack();
	dev->nextTrack();
	compareClientCommand();
}

void TestSourceBase::testReceiveAreaChanged()
{
	DeviceValues v;
	ObjectTester active(obj, SIGNAL(activeChanged()));
	ObjectTester areas(obj, SIGNAL(activeAreasChanged()));

	v[SourceDevice::DIM_AREAS_UPDATED] = true;

	// active areas haven't really changed
	obj->valueReceived(v);
	active.checkNoSignals();
	areas.checkNoSignals();
	QVERIFY(!obj->isActive());
	QCOMPARE(obj->getActiveAreas(), QList<int>());

	// active areas updated and device turned on
	obj->dev->active_areas.insert("2");

	obj->valueReceived(v);
	active.checkSignals();
	areas.checkSignals();
	QVERIFY(obj->isActive());
	QCOMPARE(obj->getActiveAreas(), QList<int>() << 2);

	// active areas updated, device still on
	obj->dev->active_areas.insert("3");

	obj->valueReceived(v);
	active.checkNoSignals();
	areas.checkSignals();
	QVERIFY(obj->isActive());
	QCOMPARE(obj->getActiveAreas(), QList<int>() << 2 << 3);

	// device off on all areas
	obj->dev->active_areas.clear();

	obj->valueReceived(v);
	active.checkSignals();
	areas.checkSignals();
	QVERIFY(!obj->isActive());
	QCOMPARE(obj->getActiveAreas(), QList<int>());
}

void TestSourceBase::testReceiveCurrentTrack()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(currentTrackChanged()));

	v[SourceDevice::DIM_TRACK] = 7;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getCurrentTrack(), 7);

	obj->valueReceived(v);
	t.checkNoSignals();
}


void TestSourceAux::init()
{
	SourceDevice *d = new SourceDevice("3");

	SourceAux *obj = new SourceAux(d, "");
	SourceDevice *dev = new SourceDevice("3", 1);

	initObjects(dev, obj);
}


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
