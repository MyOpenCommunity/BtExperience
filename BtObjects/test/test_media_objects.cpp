/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#include "test_media_objects.h"
#include "media_device.h"
#include "mediaobjects.h"
#include "objecttester.h"

#include <QtTest/QtTest>


void TestSoundAmbient::init()
{
	srcd1 = new SourceDevice("1");
	srcd2 = new SourceDevice("2");

	ampd22 = AmplifierDevice::createDevice("22");
	ampd23 = AmplifierDevice::createDevice("23");
	ampd33 = AmplifierDevice::createDevice("33");

	obj2 = new SoundAmbient(2, "", ObjectInterface::IdMultiChannelSoundAmbient, -1);
	obj3 = new SoundAmbient(3, "", ObjectInterface::IdMultiChannelSoundAmbient, -1);

	src1 = new SourceAux(srcd1);
	srco1 = new SourceObject("", src1, SourceObject::Aux);
	src1->setSourceObject(srco1);
	src2 = new SourceAux(srcd2);
	srco2 = new SourceObject("", src2, SourceObject::Aux);
	src2->setSourceObject(srco2);

	amp22 = new Amplifier(2, "", ampd22);
	amp23 = new Amplifier(2, "", ampd23);
	amp33 = new Amplifier(3, "", ampd33);

	QList<SoundAmbient *> ambients;
	QList<Amplifier *> amplifiers;
	QList<SourceObject *> sources;

	ambients << obj2 << obj3;
	amplifiers << amp22 << amp23 << amp33;
	sources << srco1 << srco2;

	foreach (SoundAmbient *ambient, ambients)
	{
		ambient->connectSources(sources);
		ambient->connectAmplifiers(amplifiers);
	}
}

void TestSoundAmbient::cleanup()
{
	delete srcd1;
	delete srcd2;

	delete obj2;
	delete obj3;
	delete src1;
	delete src2;
	delete amp22;
	delete amp23;
	delete amp33;

	clearDeviceCache();
}

void TestSoundAmbient::testActiveAmplifiers()
{
	DeviceValues v;
	ObjectTester t2(obj2, SIGNAL(activeAmplifierChanged()));
	ObjectTester t3(obj3, SIGNAL(activeAmplifierChanged()));

	v[AmplifierDevice::DIM_STATUS] = true;

	// turn on first amplifier
	amp22->valueReceived(v);
	t2.checkSignals();
	t3.checkNoSignals();
	QVERIFY(obj2->getHasActiveAmplifier());
	QCOMPARE(obj2->amplifier_count, 1);
	QVERIFY(!obj3->getHasActiveAmplifier());

	// no change when turning on second amplifier
	amp23->valueReceived(v);
	t2.checkNoSignals();
	t3.checkNoSignals();
	QVERIFY(obj2->getHasActiveAmplifier());
	QCOMPARE(obj2->amplifier_count, 2);
	QVERIFY(!obj3->getHasActiveAmplifier());

	v[AmplifierDevice::DIM_STATUS] = false;

	// no change when turning off one amplifier
	amp23->valueReceived(v);
	t2.checkNoSignals();
	t3.checkNoSignals();
	QVERIFY(obj2->getHasActiveAmplifier());
	QCOMPARE(obj2->amplifier_count, 1);
	QVERIFY(!obj3->getHasActiveAmplifier());

	// change status when turning off last amplifier
	amp22->valueReceived(v);
	t2.checkSignals();
	t3.checkNoSignals();
	QVERIFY(!obj2->getHasActiveAmplifier());
	QCOMPARE(obj2->amplifier_count, 0);
	QVERIFY(!obj3->getHasActiveAmplifier());

	// no change for duplicate off notification
	amp22->valueReceived(v);
	t2.checkNoSignals();
	t3.checkNoSignals();
	QVERIFY(!obj2->getHasActiveAmplifier());
	QCOMPARE(obj2->amplifier_count, 0);
	QVERIFY(!obj3->getHasActiveAmplifier());
}

void TestSoundAmbient::testActiveSource()
{
	DeviceValues v;
	ObjectTester t2(obj2, SIGNAL(currentSourceChanged()));
	ObjectTester t3(obj3, SIGNAL(currentSourceChanged()));

	v[SourceDevice::DIM_AREAS_UPDATED] = true;

	// turn on source on environment 2
	srcd1->active_areas.insert("2");
	src1->valueReceived(v);
	t2.checkSignals();
	t3.checkNoSignals();
	QCOMPARE(obj2->getCurrentSource(), srco1);
	QCOMPARE(obj2->getPreviousSource(), static_cast<QObject *>(0));
	QCOMPARE(obj3->getCurrentSource(), static_cast<QObject *>(0));
	QCOMPARE(obj3->getPreviousSource(), static_cast<QObject *>(0));

	// switch source from anvironment 2 to 3
	srcd1->active_areas.clear();
	srcd1->active_areas.insert("3");
	src1->valueReceived(v);
	t2.checkSignals();
	t3.checkSignals();
	QCOMPARE(obj2->getCurrentSource(), static_cast<QObject *>(0));
	QCOMPARE(obj2->getPreviousSource(), srco1);
	QCOMPARE(obj3->getCurrentSource(), srco1);
	QCOMPARE(obj3->getPreviousSource(), static_cast<QObject *>(0));

	// switch source on in environemnt 4
	srcd1->active_areas.insert("4");
	src1->valueReceived(v);
	t2.checkNoSignals();
	t3.checkNoSignals();
	QCOMPARE(obj2->getCurrentSource(), static_cast<QObject *>(0));
	QCOMPARE(obj2->getPreviousSource(), srco1);
	QCOMPARE(obj3->getCurrentSource(), srco1);
	QCOMPARE(obj3->getPreviousSource(), static_cast<QObject *>(0));

	// turn off source on environment 3
	srcd1->active_areas.clear();
	src1->valueReceived(v);
	t2.checkNoSignals();
	t3.checkSignals();
	QCOMPARE(obj2->getCurrentSource(), static_cast<QObject *>(0));
	QCOMPARE(obj2->getPreviousSource(), srco1);
	QCOMPARE(obj3->getCurrentSource(), static_cast<QObject *>(0));
	QCOMPARE(obj3->getPreviousSource(), srco1);
}


void TestSourceBase::initObjects(SourceDevice *_dev, SourceBase *_obj, SourceObject *_so)
{
	dev = _dev;
	obj = _obj;
	so = _so;
}

void TestSourceBase::cleanup()
{
	delete obj->dev;
	delete obj;
	delete so;
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

	SourceAux *obj = new SourceAux(d);
	SourceObject *so = new SourceObject("", obj, SourceObject::Aux);
	obj->setSourceObject(so);
	SourceDevice *dev = new SourceDevice("3", 1);

	initObjects(dev, obj, so);
}


void TestSourceRadio::init()
{
	RadioSourceDevice *d = new RadioSourceDevice("3");

	obj = new SourceRadio(5, d);
	so = new SourceObject("", obj, SourceObject::RdsRadio);
	obj->setSourceObject(so);
	dev = new RadioSourceDevice("3", 1);

	initObjects(dev, obj, so);
}

void TestSourceRadio::testSetStation()
{
	obj->setCurrentStation(2);
	dev->setStation("2");
	compareClientCommand();
}

void TestSourceRadio::testPreviousStation()
{
	obj->previousStation();
	dev->prevTrack();
	compareClientCommand();
}

void TestSourceRadio::testNextStation()
{
	obj->nextStation();
	dev->nextTrack();
	compareClientCommand();
}

void TestSourceRadio::testFrequencyUp()
{
	ObjectTester t(obj, SIGNAL(currentFrequencyChanged()));

	dev->frequency = obj->frequency = obj->dev->frequency = 9800;
	QVERIFY(!obj->request_frequency.isActive());

	obj->frequencyUp(2);
	dev->frequenceUp("2");
	compareClientCommand();
	t.checkSignals();
	QVERIFY(obj->request_frequency.isActive());
	QCOMPARE(obj->getCurrentFrequency(), 9810);
}

void TestSourceRadio::testFrequencyDown()
{
	ObjectTester t(obj, SIGNAL(currentFrequencyChanged()));

	dev->frequency = obj->frequency = obj->dev->frequency = 9800;
	QVERIFY(!obj->request_frequency.isActive());

	obj->frequencyDown(2);
	dev->frequenceDown("2");
	compareClientCommand();
	t.checkSignals();
	QVERIFY(obj->request_frequency.isActive());
	QCOMPARE(obj->getCurrentFrequency(), 9790);
}

void TestSourceRadio::testSearchUp()
{
	ObjectTester t(obj, SIGNAL(currentFrequencyChanged()));

	obj->frequency = obj->dev->frequency = 9800;
	QVERIFY(!obj->request_frequency.isActive());

	obj->searchUp();
	dev->frequenceUp();
	compareClientCommand();
	t.checkSignals();
	QVERIFY(!obj->request_frequency.isActive());
	QCOMPARE(obj->getCurrentFrequency(), -1);
}

void TestSourceRadio::testSearchDown()
{
	ObjectTester t(obj, SIGNAL(currentFrequencyChanged()));

	obj->frequency = obj->dev->frequency = 9800;
	QVERIFY(!obj->request_frequency.isActive());

	obj->searchDown();
	dev->frequenceDown();
	compareClientCommand();
	t.checkSignals();
	QVERIFY(!obj->request_frequency.isActive());
	QCOMPARE(obj->getCurrentFrequency(), -1);
}

void TestSourceRadio::testReceiveFrequency()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(currentFrequencyChanged()));

	v[RadioSourceDevice::DIM_FREQUENCY] = 9800;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getCurrentFrequency(), 9800);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestSourceRadio::testReceiveRds()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(rdsTextChanged()));

	v[RadioSourceDevice::DIM_RDS] = "Prova 123";

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getRdsText(), QString("Prova 123"));

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestSourceRadio::testReceiveStation()
{
	DeviceValues v;
	ObjectTester track(obj, SIGNAL(currentTrackChanged()));
	ObjectTester station(obj, SIGNAL(currentStationChanged()));

	v[RadioSourceDevice::DIM_TRACK] = 3;

	obj->valueReceived(v);
	track.checkSignals();
	station.checkSignals();
	QCOMPARE(obj->getCurrentTrack(), 3);
	QCOMPARE(obj->getCurrentStation(), 3);

	obj->valueReceived(v);
	track.checkNoSignals();
	station.checkNoSignals();
}


void TestAmplifier::initObjects(AmplifierDevice *_dev, Amplifier *_obj)
{
	dev = _dev;
	obj = _obj;
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
	// min volume
	obj->setVolume(0);
	dev->setVolume(0);
	compareClientCommand();

	// med volume
	obj->setVolume(62);
	dev->setVolume(19);
	compareClientCommand();

	// max volume
	obj->setVolume(100);
	dev->setVolume(31);
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

	v[AmplifierDevice::DIM_VOLUME] = 12;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getVolume(), 38);

	obj->valueReceived(v);
	t.checkNoSignals();

	// double receive
	v[AmplifierDevice::DIM_VOLUME] = 13;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getVolume(), 41);

	obj->valueReceived(v);
	t.checkNoSignals();
}


void TestPowerAmplifier::init()
{
	PowerAmplifierDevice *d = new PowerAmplifierDevice("32");
	QMap<int, QString> presets;

	presets[0] = "P1";
	presets[1] = "P2";
	presets[2] = "P3";
	presets[3] = "P4";
	presets[4] = "P5";
	presets[11] = "P18";

	obj = new PowerAmplifier(3, "", d, presets);
	dev = new PowerAmplifierDevice("32", 1);

	initObjects(dev, obj);
}

void TestPowerAmplifier::testBass()
{
	obj->bassDown();
	dev->bassDown();
	compareClientCommand();

	obj->bassUp();
	dev->bassUp();
	compareClientCommand();
}

void TestPowerAmplifier::testTreble()
{
	obj->trebleDown();
	dev->trebleDown();
	compareClientCommand();

	obj->trebleUp();
	dev->trebleUp();
	compareClientCommand();
}

void TestPowerAmplifier::testBalance()
{
	obj->balanceLeft();
	dev->balanceLeft();
	compareClientCommand();

	obj->balanceRight();
	dev->balanceRight();
	compareClientCommand();
}

void TestPowerAmplifier::testPreset()
{
	obj->previousPreset();
	dev->prevPreset();
	compareClientCommand();

	obj->nextPreset();
	dev->nextPreset();
	compareClientCommand();

	obj->setPreset(12);
	dev->setPreset(12);
	compareClientCommand();
}

void TestPowerAmplifier::testPreset2()
{
	ObjectDataModel *dm = obj->getPresets();
	PowerAmplifierPreset *preset = qobject_cast<PowerAmplifierPreset *>(dm->getObject(dm->rowCount() - 1));
	obj->setPreset(preset->getObjectId());
	dev->setPreset(11);
	compareClientCommand();
}

void TestPowerAmplifier::testLoud()
{
	obj->setLoud(true);
	dev->loudOn();
	compareClientCommand();

	obj->setLoud(false);
	dev->loudOff();
	compareClientCommand();
}

void TestPowerAmplifier::testReceiveBass()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(bassChanged()));

	v[PowerAmplifierDevice::DIM_BASS] = 2;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getBass(), 2);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestPowerAmplifier::testReceiveTreble()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(trebleChanged()));

	v[PowerAmplifierDevice::DIM_TREBLE] = 2;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getTreble(), 2);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestPowerAmplifier::testReceiveBalance()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(balanceChanged()));

	v[PowerAmplifierDevice::DIM_BALANCE] = 2;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getBalance(), 2);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestPowerAmplifier::testReceivePreset()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(presetChanged()));

	v[PowerAmplifierDevice::DIM_PRESET] = 2;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getPreset(), 2);
	QCOMPARE(obj->getPresetDescription(), QString("Pop"));

	obj->valueReceived(v);
	t.checkNoSignals();

	v[PowerAmplifierDevice::DIM_PRESET] = 12;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getPreset(), 12);
	QCOMPARE(obj->getPresetDescription(), QString("P3"));
}

void TestPowerAmplifier::testReceiveLoud()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(loudChanged()));

	v[PowerAmplifierDevice::DIM_LOUD] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoud(), true);

	obj->valueReceived(v);
	t.checkNoSignals();
}
