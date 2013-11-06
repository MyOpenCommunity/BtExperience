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

#include "test_alarm_clock.h"

#include "media_device.h"
#include "mediaobjects.h"
#include "alarmclock.h"
#include "objecttester.h"

#include <QtTest>

#define FRAME_TIMEOUT 500

void TestAlarmClockBeep::init()
{
	obj = new AlarmClock("", true, AlarmClock::AlarmClockBeep, 0, 0, 0);
	qRegisterMetaType<AlarmClock *>("AlarmClock*");
}

void TestAlarmClockBeep::cleanup()
{
	delete obj;
}

void TestAlarmClockBeep::testStart()
{
	QVERIFY(obj->isEnabled());

	obj->triggersIfHasTo();

	QVERIFY(!obj->isEnabled());
	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());
	QCOMPARE(obj->tick_count, 0);
}

void TestAlarmClockBeep::testStop()
{
	obj->triggersIfHasTo();

	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());

	obj->stop();

	QVERIFY(!obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());
}

void TestAlarmClockBeep::testPostpone()
{
	obj->triggersIfHasTo();

	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());

	obj->postpone();

	QVERIFY(!obj->timer_tick->isActive());
	QVERIFY(obj->timer_postpone->isActive());
}

void TestAlarmClockBeep::testRestart()
{
	obj->actual_type = AlarmClock::AlarmClockBeep;

	obj->timer_postpone->start();
	obj->start_time = QTime::currentTime().addSecs(-10);
	obj->tick_count = 20;

	obj->restart();

	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());
	QCOMPARE(obj->tick_count, 0);
}

void TestAlarmClockBeep::testRestartExpired()
{
	obj->actual_type = AlarmClock::AlarmClockBeep;

	obj->timer_postpone->start();
	obj->start_time = QTime::currentTime().addSecs(-4000);
	obj->tick_count = 20;

	obj->restart();

	QVERIFY(!obj->timer_tick->isActive());
	QCOMPARE(obj->tick_count, 20);
}

void TestAlarmClockBeep::testFirstTick()
{
	ObjectTester t(obj, SIGNAL(ringMe(AlarmClock*)));

	obj->actual_type = AlarmClock::AlarmClockBeep;
	obj->tick_count = 0;
	obj->alarmTick();

	t.checkSignals();
}

void TestAlarmClockBeep::testTick()
{
	ObjectTester t(obj, SIGNAL(ringMe(AlarmClock*)));

	obj->actual_type = AlarmClock::AlarmClockBeep;
	obj->tick_count = 10;
	obj->alarmTick();

	t.checkSignals();
}

void TestAlarmClockBeep::testLastTick()
{
	ObjectTester t(obj, SIGNAL(ringMe(AlarmClock*)));

	obj->actual_type = AlarmClock::AlarmClockBeep;
	obj->tick_count = 23;
	obj->alarmTick();

	t.checkNoSignals();
}


void TestAlarmClockSoundDiffusion::initTestCase()
{
	dummy = new ObjectDataModel();

	ObjectModel::setGlobalSource(dummy);
}

void TestAlarmClockSoundDiffusion::cleanupTestCase()
{
	delete dummy;

	ObjectModel::setGlobalSource(0);
}

void TestAlarmClockSoundDiffusion::init()
{
	amplifier_dev.append(AmplifierDevice::createDevice("11", 1));
	amplifier_dev.append(AmplifierDevice::createDevice("12", 1));
	amplifier_dev.append(AmplifierDevice::createDevice("21", 1));
	amplifier_dev.append(AmplifierDevice::createDevice("31", 1));
	source_dev = new SourceDevice("3", 1);

	amplifiers.append(new Amplifier(1, "", AmplifierDevice::createDevice("11")));
	amplifiers.append(new Amplifier(1, "", AmplifierDevice::createDevice("12")));
	amplifiers.append(new Amplifier(2, "", AmplifierDevice::createDevice("21")));
	amplifiers.append(new Amplifier(3, "", AmplifierDevice::createDevice("31")));
	source = new SourceObject("", new SourceAux(new SourceDevice("3")), SourceObject::Aux);

	obj = new AlarmClock("", true, AlarmClock::AlarmClockSoundSystem, 0, 0, 0);
	obj->setVolume(25); // 8 in 0-31 amplifier scale
	obj->setSource(source);
	obj->setAmplifier(amplifiers[1]);
}

void TestAlarmClockSoundDiffusion::cleanup()
{
	delete source_dev;
	delete obj;
}

void TestAlarmClockSoundDiffusion::testStart()
{
	QVERIFY(obj->isEnabled());

	obj->triggersIfHasTo();

	QVERIFY(!obj->isEnabled());
	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());
	QCOMPARE(obj->tick_count, 0);

	compareClientCommand(FRAME_TIMEOUT);
}

void TestAlarmClockSoundDiffusion::testStop()
{
	obj->triggersIfHasTo();

	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());

	compareClientCommand(FRAME_TIMEOUT);

	obj->stop();

	QVERIFY(!obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());

	compareClientCommand(FRAME_TIMEOUT);
}

void TestAlarmClockSoundDiffusion::testPostpone()
{
	obj->triggersIfHasTo();

	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());

	compareClientCommand(FRAME_TIMEOUT);

	obj->postpone();

	amplifier_dev[1]->turnOff();

	QVERIFY(!obj->timer_tick->isActive());
	QVERIFY(obj->timer_postpone->isActive());

	compareClientCommand(FRAME_TIMEOUT);
}

void TestAlarmClockSoundDiffusion::testRestart()
{
	obj->actual_type = AlarmClock::AlarmClockSoundSystem;

	obj->timer_postpone->start();
	obj->start_time = QTime::currentTime().addSecs(-10);
	obj->tick_count = 20;

	obj->restart();

	QVERIFY(obj->timer_tick->isActive());
	QVERIFY(!obj->timer_postpone->isActive());
	QCOMPARE(obj->tick_count, 0);
}

void TestAlarmClockSoundDiffusion::testRestartExpired()
{
	obj->actual_type = AlarmClock::AlarmClockSoundSystem;

	obj->timer_postpone->start();
	obj->start_time = QTime::currentTime().addSecs(-4000);
	obj->tick_count = 20;

	obj->restart();

	QVERIFY(!obj->timer_tick->isActive());
	QCOMPARE(obj->tick_count, 20);
}

void TestAlarmClockSoundDiffusion::testFirstTick()
{
	obj->actual_type = AlarmClock::AlarmClockSoundSystem;
	obj->tick_count = 0;
	obj->alarmTick();

	source_dev->turnOn("1");
	amplifier_dev[1]->setVolume(0);
	amplifier_dev[1]->turnOn();

	compareClientCommand();
}

void TestAlarmClockSoundDiffusion::testTick()
{
	obj->actual_type = AlarmClock::AlarmClockSoundSystem;

	// tests that the first 9 ticks set the volume from 0 to 8, then stop updating volume
	for (int i = 1; i < 11; ++i)
	{
		obj->tick_count = i;
		obj->alarmTick();

		if (i < 9)
			amplifier_dev[1]->setVolume(i - 1);
		compareClientCommand();
	}
}

void TestAlarmClockSoundDiffusion::testLastTick()
{
	obj->actual_type = AlarmClock::AlarmClockSoundSystem;
	obj->tick_count = 39;
	obj->alarmTick();

	amplifier_dev[1]->turnOff();

	compareClientCommand();
}
