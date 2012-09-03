/*
 * BTouch - Graphical User Interface to control MyHome System
 *
 * Copyright (C) 2010 BTicino S.p.A.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "test_thermal_objects.h"
#include "thermalobjects.h"
#include "objecttester.h"

#include <QtTest/QtTest>

void TestThermalControlUnit::initObjects(ThermalDevice *_dev, ThermalControlUnit *_obj)
{
	dev = _dev;
	obj = _obj;
}

void TestThermalControlUnit::testSetSeason()
{
	obj->setSeason(ThermalControlUnit::Winter);
	dev->setWinter();
	compareClientCommand();

	obj->setSeason(ThermalControlUnit::Summer);
	dev->setSummer();
	compareClientCommand();

	// TODO test no frame sent
}

void TestThermalControlUnit::testReceiveSeason()
{
	DeviceValues v;
	v[ThermalDevice::DIM_SEASON] = ThermalDevice::SE_WINTER;

	ObjectTester t(obj, SIGNAL(seasonChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getSeason(), ThermalControlUnit::Winter);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlUnit::testReceiveEndDate()
{
	DeviceValues v;
	v[ThermalDevice::DIM_DATE] = QDate(2012, 8, 30);

	ObjectTester t(obj, SIGNAL(seasonChanged()));
	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlUnit::testReceiveEndTime()
{
	DeviceValues v;
	v[ThermalDevice::DIM_TIME] = QTime(12, 3);

	ObjectTester t(obj, SIGNAL(seasonChanged()));
	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlUnit::testReceiveEndDuration()
{
	DeviceValues v;
	QVariant var;
	var.setValue(BtTime(24, 59, 59));
	v[ThermalDevice::DIM_DURATION] = var;

	ObjectTester t(obj, SIGNAL(seasonChanged()));
	obj->valueReceived(v);
	t.checkNoSignals();
}

template<class T>
void TestThermalControlUnit::testChangeModality(ThermalDevice::Status status, int object_id, T **result)
{
	if (result)
		*result = NULL;

	QVERIFY(obj->getCurrentModality() == NULL);

	DeviceValues v;
	v[ThermalDevice::DIM_STATUS] = status;

	ObjectTester t(obj, SIGNAL(currentModalityChanged()));
	obj->valueReceived(v);
	t.checkSignals();

	T *mod = qobject_cast<T *>(obj->getCurrentModality());
	QVERIFY(mod != NULL);
	QCOMPARE(mod->getObjectId(), object_id);

	obj->valueReceived(v);
	t.checkNoSignals();

	if (result)
		*result = mod;
}

void TestThermalControlUnit::testModalityOff()
{
	ThermalControlUnitOff *off;

	testChangeModality(ThermalDevice::ST_OFF, ThermalControlUnit::IdOff, &off);
	QVERIFY(off != NULL);

	off->apply();
	dev->setOff();
	compareClientCommand();
}

void TestThermalControlUnit::testModalityAntifreeze()
{
	ThermalControlUnitAntifreeze *af;

	testChangeModality(ThermalDevice::ST_PROTECTION, ThermalControlUnit::IdAntifreeze, &af);
	QVERIFY(af != NULL);

	af->apply();
	dev->setProtection();
	compareClientCommand();
}

void TestThermalControlUnit::testModalityProgram()
{
	testChangeModality<ThermalControlUnitProgram>(ThermalDevice::ST_PROGRAM, ThermalControlUnit::IdWeeklyPrograms);
}

void TestThermalControlUnit::testModalityVacation()
{
	testChangeModality<ThermalControlUnitTimedProgram>(ThermalDevice::ST_WEEKEND, ThermalControlUnit::IdWeekday);
}

void TestThermalControlUnit::testModalityHoliday()
{
	testChangeModality<ThermalControlUnitTimedProgram>(ThermalDevice::ST_HOLIDAY, ThermalControlUnit::IdHoliday);
}

void TestThermalControlUnit::testModalityManual()
{
	testChangeModality<ThermalControlUnitManual>(ThermalDevice::ST_MANUAL, ThermalControlUnit::IdManual);
}


void TestThermalControlUnit99Zones::init()
{
	ThermalDevice99Zones *d = new ThermalDevice99Zones("0");

	obj = new ThermalControlUnit99Zones("", "", d);
	dev = new ThermalDevice99Zones("0", 1);

	initObjects(dev, obj);
}

void TestThermalControlUnit99Zones::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestThermalControlUnit99Zones::testModalityScenarios()
{
	ThermalControlUnitScenario *scen;

	testChangeModality(ThermalDevice::ST_SCENARIO, ThermalControlUnit::IdScenarios, &scen);

	QVERIFY(scen != NULL);
}


void TestThermalControlUnit4Zones::init()
{
	ThermalDevice4Zones *d = new ThermalDevice4Zones("1#2");

	obj = new ThermalControlUnit4Zones("", "", d);
	dev = new ThermalDevice4Zones("1#2", 1);

	initObjects(dev, obj);
}

void TestThermalControlUnit4Zones::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestThermalControlUnit4Zones::testModalityTimedManual()
{
	ThermalControlUnitTimedManual *man;

	testChangeModality(ThermalDevice::ST_MANUAL_TIMED, ThermalControlUnit::IdTimedManual, &man);

	QVERIFY(man != NULL);
}


void TestThermalControlUnitObject::initObjects(ThermalDevice *_dev, ThermalControlUnitObject *_obj)
{
	dev = _dev;
	obj = _obj;
	if (!test_summer_programs.getCount())
	{
		test_summer_programs
			     << new ThermalRegulationProgram(1, ThermalControlUnit::Summer, QString("P1s"))
			     << new ThermalRegulationProgram(3, ThermalControlUnit::Summer, QString("P3s"))
			     << new ThermalRegulationProgram(5, ThermalControlUnit::Summer, QString("P5s"));
		test_winter_programs
			     << new ThermalRegulationProgram(1, ThermalControlUnit::Summer, QString("P2w"))
			     << new ThermalRegulationProgram(3, ThermalControlUnit::Summer, QString("P4w"))
			     << new ThermalRegulationProgram(5, ThermalControlUnit::Summer, QString("P6w"));
	}
	if (!test_summer_scenarios.getCount())
	{
		test_summer_scenarios
			       << new ThermalRegulationProgram(1, ThermalControlUnit::Summer, QString("S1s"))
			       << new ThermalRegulationProgram(3, ThermalControlUnit::Summer, QString("S3s"))
			       << new ThermalRegulationProgram(5, ThermalControlUnit::Summer, QString("S5s"));
		test_winter_scenarios
			       << new ThermalRegulationProgram(1, ThermalControlUnit::Summer, QString("S2w"))
			       << new ThermalRegulationProgram(3, ThermalControlUnit::Summer, QString("S4w"))
			       << new ThermalRegulationProgram(5, ThermalControlUnit::Summer, QString("S6w"));
	}
}

void TestThermalControlUnitObject::cleanup()
{
	delete obj->dev;
	delete dev;
}


void TestThermalControlUnitManual::init()
{
	ThermalDevice99Zones *d = new ThermalDevice99Zones("0");
	obj = new ThermalControlUnitManual("", d);

	dev = new ThermalDevice99Zones("0", 1);

	TestThermalControlUnitObject::initObjects(dev, obj);
}

void TestThermalControlUnitManual::initObjects(ThermalDevice *_dev, ThermalControlUnitManual *_obj)
{
	dev = _dev;
	obj = _obj;

	TestThermalControlUnitObject::initObjects(_dev, _obj);
}

void TestThermalControlUnitManual::testSetTemperature()
{
	ObjectTester t(obj, SIGNAL(temperatureChanged()));
	obj->setTemperature(30);
	t.checkSignals();
	QCOMPARE(obj->getTemperature(), 30);

	obj->setTemperature(30);
	t.checkNoSignals();
}

void TestThermalControlUnitManual::testReceiveTemperature()
{
	DeviceValues v;
	v[ThermalDevice::DIM_TEMPERATURE] = 1010;

	ObjectTester t(obj, SIGNAL(temperatureChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getTemperature(), -10);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlUnitManual::testApply()
{
	obj->setTemperature(30);

	obj->apply();
	dev->setManualTemp(30);
	compareClientCommand();
}


void TestThermalControlUnitTimedManual::init()
{
	ThermalDevice4Zones *d = new ThermalDevice4Zones("1#2");
	obj = new ThermalControlUnitTimedManual("", d);

	dev = new ThermalDevice4Zones("1#2", 1);

	initObjects(dev, obj);
}

void TestThermalControlUnitTimedManual::testSetTime()
{
	// in the test we must be sure that h, m, s all change
	QTime time = QTime(obj->getHours(), obj->getMinutes(), obj->getSeconds()).addSecs(-2 * 60 * 60 - 3 * 60 - 5);

	ObjectTester t(obj, SignalList()
				   << SIGNAL(hoursChanged())
				   << SIGNAL(minutesChanged())
				   << SIGNAL(secondsChanged()));
	obj->setHours(time.hour());
	obj->setMinutes(time.minute());
	obj->setSeconds(time.second());
	t.checkSignals();
	QCOMPARE(obj->getHours(), time.hour());
	QCOMPARE(obj->getMinutes(), time.minute());
	QCOMPARE(obj->getSeconds(), time.second());

	obj->setHours(time.hour());
	obj->setMinutes(time.minute());
	obj->setSeconds(time.second());
	t.checkNoSignals();
}

void TestThermalControlUnitTimedManual::testReceiveEndDuration()
{
	DeviceValues v;
	QVariant var;
	BtTime bt = BtTime(24, 59, 59);
	bt.setMaxHours(25);
	var.setValue(bt);
	v[ThermalDevice::DIM_DURATION] = var;

	ObjectTester t(obj, SignalList()
				   << SIGNAL(hoursChanged())
				   << SIGNAL(minutesChanged())
				   << SIGNAL(secondsChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(24, obj->getHours());
	QCOMPARE(59, obj->getMinutes());
	QCOMPARE(59, obj->getSeconds());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlUnitTimedManual::testApply()
{
	QTime time = QTime::currentTime();

	obj->setHours(time.hour());
	obj->setMinutes(time.minute());
	obj->setSeconds(time.second());
	obj->setTemperature(30);

	obj->apply();
	dev->setManualTempTimed(30, time);
	compareClientCommand();
}


void TestThermalControlUnitScenario::init()
{
	ThermalDevice99Zones *d = new ThermalDevice99Zones("0");
	obj = new ThermalControlUnitScenario("", &test_summer_scenarios, &test_winter_scenarios,d);

	dev = new ThermalDevice99Zones("0", 1);

	initObjects(dev, obj);
}

void TestThermalControlUnitScenario::testSetScenarioIndex()
{
	ObjectTester t(obj, SIGNAL(scenarioChanged()));

	obj->setScenarioIndex(1);
	t.checkSignals();

	obj->setScenarioIndex(1);
	t.checkNoSignals();
}

void TestThermalControlUnitScenario::testReceiveScenarioId()
{
	DeviceValues v;
	v[ThermalDevice::DIM_SCENARIO] = 5;
	v[ThermalDevice::DIM_SEASON] = ThermalDevice::SE_WINTER;

	ObjectTester t(obj, SIGNAL(scenarioChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getScenarioIndex(), 2);
	QCOMPARE(obj->getScenarioDescription(), QString("S6w"));

	// emits the signal every time the value is received
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getScenarioIndex(), 2);

	v[ThermalDevice::DIM_SCENARIO] = 3;
	v[ThermalDevice::DIM_SEASON] = ThermalDevice::SE_SUMMER;
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getScenarioIndex(), 1);
	QCOMPARE(obj->getScenarioDescription(), QString("S3s"));
}

void TestThermalControlUnitScenario::testApply()
{
	obj->setScenarioIndex(1);

	obj->apply();
	dev->setScenario(3);
	compareClientCommand();
}


void TestThermalControlUnitProgram::init()
{
	ThermalDevice99Zones *d = new ThermalDevice99Zones("0");
	obj = new ThermalControlUnitProgram("", 0, &test_summer_programs, &test_winter_programs, d);

	dev = new ThermalDevice99Zones("0", 1);

	initObjects(dev, obj);
}

void TestThermalControlUnitProgram::testSetProgramIndex()
{
	ObjectTester t(obj, SIGNAL(programChanged()));

	obj->setProgramIndex(1);
	t.checkSignals();

	obj->setProgramIndex(1);
	t.checkNoSignals();
}

void TestThermalControlUnitProgram::testReceiveProgramId()
{
	DeviceValues v;
	v[ThermalDevice::DIM_PROGRAM] = 5;
	v[ThermalDevice::DIM_SEASON] = ThermalDevice::SE_WINTER;

	ObjectTester t(obj, SIGNAL(programChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getProgramIndex(), 2);
	QCOMPARE(obj->getProgramDescription(), QString("P6w"));

	// emits the signal every time the value is received
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getProgramIndex(), 2);

	v[ThermalDevice::DIM_PROGRAM] = 3;
	v[ThermalDevice::DIM_SEASON] = ThermalDevice::SE_SUMMER;
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getProgramIndex(), 1);
	QCOMPARE(obj->getProgramDescription(), QString("P3s"));
}

void TestThermalControlUnitProgram::testApply()
{
	obj->setProgramIndex(1);

	obj->apply();
	dev->setWeekProgram(3);
	compareClientCommand();
}


void TestThermalControlUnitTimedProgram::initProgram(int object_id)
{
	ThermalDevice99Zones *d = new ThermalDevice99Zones("0");
	TestThermalControlUnitProgram::obj = obj = new ThermalControlUnitTimedProgram("", object_id, &test_summer_programs, &test_winter_programs, d);

	dev = new ThermalDevice99Zones("0", 1);

	initObjects(dev, obj);
}

void TestThermalControlUnitTimedProgram::testSetDate()
{
	obj->setYears(2012);
	obj->setMonths(1);
	obj->setDays(1);

	ObjectTester t(obj, SignalList() << SIGNAL(daysChanged())
				   << SIGNAL(monthsChanged())
				   << SIGNAL(yearsChanged()));

	obj->setDays(0);
	t.checkSignals();
}

void TestThermalControlUnitTimedProgram::testSetTime()
{
	obj->setHours(0);
	obj->setMinutes(0);
	obj->setSeconds(0);

	ObjectTester t(obj, SignalList() << SIGNAL(hoursChanged())
				   << SIGNAL(minutesChanged())
				   << SIGNAL(secondsChanged()));

	obj->setSeconds(-1);
	t.checkSignals();
}

void TestThermalControlUnitTimedProgram::testReceiveEndDate()
{
	DeviceValues v;
	v[ThermalDevice::DIM_DATE] = QDate(2001, 8, 30);

	ObjectTester t(obj, SignalList()
				   << SIGNAL(yearsChanged())
				   << SIGNAL(monthsChanged())
				   << SIGNAL(daysChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(2001, obj->getYears());
	QCOMPARE(8, obj->getMonths());
	QCOMPARE(30, obj->getDays());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlUnitTimedProgram::testReceiveEndTime()
{
	obj->setHours(0);
	obj->setMinutes(0);
	obj->setSeconds(0);

	DeviceValues v;
	v[ThermalDevice::DIM_TIME] = QTime(12, 3, 7);

	ObjectTester t(obj, SignalList()
				   << SIGNAL(hoursChanged())
				   << SIGNAL(minutesChanged())
				   << SIGNAL(secondsChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(12, obj->getHours());
	QCOMPARE(3, obj->getMinutes());
	QCOMPARE(7, obj->getSeconds());

	obj->valueReceived(v);
	t.checkNoSignals();
}


void TestThermalControlUnitVacation::init()
{
	initProgram(ThermalControlUnit::IdWeekday);
}

void TestThermalControlUnitVacation::testApply()
{
	obj->setProgramIndex(1);
	obj->setYears(2012);
	obj->setMonths(1);
	obj->setDays(1);
	obj->setHours(0);
	obj->setMinutes(0);
	obj->setSeconds(0);
	obj->apply();

	dev->setWeekendDateTime(QDate(2012, 1, 1), QTime(0, 0, 0), 3);
	compareClientCommand();
}


void TestThermalControlUnitHoliday::init()
{
	initProgram(ThermalControlUnit::IdHoliday);
}

void TestThermalControlUnitHoliday::testApply()
{
	obj->setProgramIndex(1);
	obj->setYears(2012);
	obj->setMonths(1);
	obj->setDays(1);
	obj->setHours(0);
	obj->setMinutes(0);
	obj->setSeconds(0);
	obj->apply();

	dev->setHolidayDateTime(QDate(2012, 1, 1), QTime(0, 0, 0), 3);
	compareClientCommand();
}
