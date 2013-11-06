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

#ifndef TEST_ALARM_CLOCK_H
#define TEST_ALARM_CLOCK_H

#include "test_btobject.h"

class AlarmClock;
class AmplifierDevice;
class SourceDevice;
class Amplifier;
class SourceObject;
class ObjectDataModel;


class TestAlarmClockBeep : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testStart();
	void testStop();
	void testPostpone();
	void testRestart();
	void testRestartExpired();

	void testFirstTick();
	void testTick();
	void testLastTick();

private:
	AlarmClock *obj;
};


class TestAlarmClockSoundDiffusion : public TestBtObject
{
	Q_OBJECT

private slots:
	void initTestCase();
	void cleanupTestCase();

	void init();
	void cleanup();

	void testStart();
	void testStop();
	void testPostpone();
	void testRestart();
	void testRestartExpired();

	void testFirstTick();
	void testTick();
	void testLastTick();

private:
	ObjectDataModel *dummy;
	AlarmClock *obj;
	QList<AmplifierDevice *> amplifier_dev;
	SourceDevice *source_dev;
	QList<Amplifier *> amplifiers;
	SourceObject *source;
};

#endif // TEST_ALARM_CLOCK_H
