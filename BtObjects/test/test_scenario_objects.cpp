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


#include "test_scenario_objects.h"
#include "objecttester.h"
#include "scenario_device.h"
#include "scenarioobjects.h"
#include "openmsg.h"

#include <QtTest>

Q_DECLARE_METATYPE(DeviceValues)
Q_DECLARE_METATYPE(ScenarioModule::Status)

#define TEST_COMMAND "*1*1*1##"


static const int SCENARIO_NUMBER = 1;

namespace
{
	DeviceValues packValues(int key, bool val)
	{
		DeviceValues v;
		v[key] = val;
		return v;
	}

	DeviceValues packStartValues(bool val, int scenario)
	{
		DeviceValues v;
		QVariant var;
		var.setValue(ScenarioProgrammingStatus(val, scenario));
		v[ScenarioDevice::DIM_START] = var;
		return v;
	}
}

void TestScenarioModule::init()
{
	ScenarioDevice *d = new ScenarioDevice("3");
	scen = new ScenarioModule(SCENARIO_NUMBER, "test_scen", d);
	dev = new ScenarioDevice("3", 1);
}

void TestScenarioModule::cleanup()
{
	delete scen->dev;
	delete scen;
	delete dev;
}

void TestScenarioModule::testReceiveLock()
{
	checkMethod();
}

void TestScenarioModule::testReceiveLock_data()
{
	QTest::addColumn<DeviceValues>("value");
	QTest::addColumn<ScenarioModule::Status>("start_status");
	QTest::addColumn<ScenarioModule::Status>("end_status");
	QTest::addColumn<int>("signals_emitted");

	// Receive Lock
	DeviceValues v = packValues(ScenarioDevice::DIM_LOCK, true);

	QTest::newRow("Locked") <<
		v << ScenarioModule::Locked << ScenarioModule::Locked << 0;
	QTest::newRow("Unlocked") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Locked << 1;
	QTest::newRow("Editing") <<
		v << ScenarioModule::Editing << ScenarioModule::Locked << 1;
}

void TestScenarioModule::testReceiveUnlock()
{
	checkMethod();
}

void TestScenarioModule::testReceiveUnlock_data()
{
	QTest::addColumn<DeviceValues>("value");
	QTest::addColumn<ScenarioModule::Status>("start_status");
	QTest::addColumn<ScenarioModule::Status>("end_status");
	QTest::addColumn<int>("signals_emitted");

	// Receive Unlock
	DeviceValues v = packValues(ScenarioDevice::DIM_LOCK, false);

	QTest::newRow("Locked") <<
		v << ScenarioModule::Locked << ScenarioModule::Unlocked << 1;
	QTest::newRow("Unlocked") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Unlocked << 0;
	QTest::newRow("Editing") <<
		v << ScenarioModule::Editing << ScenarioModule::Unlocked << 1;
}

void TestScenarioModule::testReceiveStart()
{
	checkMethod();
}

void TestScenarioModule::testReceiveStart_data()
{
	QTest::addColumn<DeviceValues>("value");
	QTest::addColumn<ScenarioModule::Status>("start_status");
	QTest::addColumn<ScenarioModule::Status>("end_status");
	QTest::addColumn<int>("signals_emitted");

	// Receive Start
	DeviceValues v = packStartValues(true, SCENARIO_NUMBER);

	QTest::newRow("Locked") <<
		v << ScenarioModule::Locked << ScenarioModule::Locked << 0;
	QTest::newRow("Unlocked") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Editing << 1;
	QTest::newRow("Editing") <<
		v << ScenarioModule::Editing << ScenarioModule::Editing << 0;
}

void TestScenarioModule::testReceiveStartOtherScenario()
{
	checkMethod();
}

void TestScenarioModule::testReceiveStartOtherScenario_data()
{
	QTest::addColumn<DeviceValues>("value");
	QTest::addColumn<ScenarioModule::Status>("start_status");
	QTest::addColumn<ScenarioModule::Status>("end_status");
	QTest::addColumn<int>("signals_emitted");

	// Receive Start on another scenario
	DeviceValues v = packStartValues(true, SCENARIO_NUMBER + 1);

	QTest::newRow("Locked") <<
		v << ScenarioModule::Locked << ScenarioModule::Locked << 0;
	QTest::newRow("Unlocked") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Locked << 1;
	QTest::newRow("Editing") <<
		v << ScenarioModule::Editing << ScenarioModule::Editing << 0;
}

void TestScenarioModule::testReceiveStop()
{
	checkMethod();
}

void TestScenarioModule::testReceiveStop_data()
{
	QTest::addColumn<DeviceValues>("value");
	QTest::addColumn<ScenarioModule::Status>("start_status");
	QTest::addColumn<ScenarioModule::Status>("end_status");
	QTest::addColumn<int>("signals_emitted");

	// Receive Stop on my scenario
	DeviceValues v = packStartValues(false, SCENARIO_NUMBER);

	QTest::newRow("Locked") <<
		v << ScenarioModule::Locked << ScenarioModule::Unlocked << 1;
	QTest::newRow("Unlocked") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Unlocked << 0;
	QTest::newRow("Editing") <<
		v << ScenarioModule::Editing << ScenarioModule::Unlocked << 1;

	// Receive Stop on another scenario
	v = packStartValues(false, SCENARIO_NUMBER + 1);

	QTest::newRow("LockedOther") <<
		v << ScenarioModule::Locked << ScenarioModule::Unlocked << 1;
	QTest::newRow("UnlockedOther") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Unlocked << 0;
	QTest::newRow("EditingOther") <<
		v << ScenarioModule::Editing << ScenarioModule::Unlocked << 1;
}

void TestScenarioModule::testActivateScenario()
{
	scen->activate();
	dev->activateScenario(SCENARIO_NUMBER);
	compareClientCommand();
}

void TestScenarioModule::testStartProgramming()
{
	scen->startProgramming();
	dev->startProgramming(SCENARIO_NUMBER);
	compareClientCommand();
}

void TestScenarioModule::testStopProgramming()
{
	scen->stopProgramming();
	dev->stopProgramming(SCENARIO_NUMBER);
	compareClientCommand();
}

void TestScenarioModule::checkMethod()
{
	QFETCH(DeviceValues, value);
	QFETCH(ScenarioModule::Status, start_status);
	QFETCH(ScenarioModule::Status, end_status);
	QFETCH(int, signals_emitted);

	ObjectTester t(scen, SIGNAL(statusChanged()));

	scen->status = start_status;
	scen->valueReceived(value);
	t.checkSignalCount(SIGNAL(statusChanged()), signals_emitted);
	QCOMPARE(scen->status, end_status);
}

void TestScenarioAdvanced::testWeekdays()
{
	AdvancedScenario obj(0, 0, false, 0, "", "", "");
	ObjectTester t(&obj, SIGNAL(daysChanged()));

	for (int i = 0; i < 8; ++i)
	{
		QVERIFY(!obj.isDayEnabled(i));

		obj.setDayEnabled(i, true);
		t.checkSignals();
		QVERIFY(obj.isDayEnabled(i));

		obj.setDayEnabled(i, false);
		t.checkSignals();
		QVERIFY(!obj.isDayEnabled(i));
	}

	obj.days = 64; // sunday
	QVERIFY(obj.isDayEnabled(0));
	QVERIFY(obj.isDayEnabled(7));
}

void TestScenarioAdvanced::testDeviceCondition()
{
	DeviceConditionObject dc(DeviceCondition::AUX, "", "1", "3", NOT_PULL);
	AdvancedScenario obj(&dc, 0, true, 127, TEST_COMMAND, "", "");
	ObjectTester ts(&obj, SIGNAL(started()));
	OpenMsg off("*9*0*3##"), on("*9*1*3##");
	RawDevice dev(1);

	dc.setParent(0);

	dc.device_cond->dev->manageFrame(off);
	ts.checkNoSignals();

	dc.device_cond->dev->manageFrame(on);
	ts.checkSignals();

	dev.sendCommand(TEST_COMMAND);
	compareClientCommand();
}

void TestScenarioAdvanced::testWeekdayCondition()
{
	int today_mask = 1 << (QDate::currentDate().dayOfWeek() - 1);
	int not_today_mask = (~today_mask) & 127;

	DeviceConditionObject dc(DeviceCondition::AUX, "", "1", "3", NOT_PULL);
	AdvancedScenario obj1(&dc, 0, true, today_mask, TEST_COMMAND, "", "");
	ObjectTester ts1(&obj1, SIGNAL(started()));
	OpenMsg off("*9*0*3##"), on("*9*1*3##");
	RawDevice dev(1);

	dc.setParent(0);

	dc.device_cond->dev->manageFrame(off);
	ts1.checkNoSignals();

	dc.device_cond->dev->manageFrame(on);
	ts1.checkSignals();

	dev.sendCommand(TEST_COMMAND);
	compareClientCommand();

	AdvancedScenario obj2(&dc, 0, true, not_today_mask, TEST_COMMAND, "", "");
	ObjectTester ts2(&obj2, SIGNAL(started()));

	dc.setParent(0);

	dc.device_cond->dev->manageFrame(off);
	ts2.checkNoSignals();

	dc.device_cond->dev->manageFrame(on);
	ts2.checkNoSignals();
}

void TestScenarioAdvanced::testTimeCondition()
{
	TimeConditionObject tc(0, 0);
	AdvancedScenario obj(0, &tc, true, 127, TEST_COMMAND, "", "");
	ObjectTester ts(&obj, SIGNAL(started()));
	RawDevice dev(1);

	tc.setParent(0);

	tc.timer.setInterval(500);

	QVERIFY(ts.waitForSignal(1000));

	dev.sendCommand(TEST_COMMAND);
	compareClientCommand();
}

void TestScenarioAdvanced::testTimeDeviceCondition()
{
	DeviceConditionObject dc(DeviceCondition::AUX, "", "1", "3", NOT_PULL);
	TimeConditionObject tc(0, 0);
	AdvancedScenario obj(&dc, &tc, true, 127, TEST_COMMAND, "", "");
	ObjectTester ts(&obj, SIGNAL(started()));
	OpenMsg off("*9*0*3##"), on("*9*1*3##");
	RawDevice dev(1);

	tc.setParent(0);
	dc.setParent(0);

	tc.timer.setInterval(500);

	dc.device_cond->dev->manageFrame(off);
	ts.checkNoSignals();

	dc.device_cond->dev->manageFrame(on);
	ts.checkNoSignals();

	QVERIFY(dc.isSatisfied());
	QVERIFY(ts.waitForSignal(1000));

	dev.sendCommand(TEST_COMMAND);
	compareClientCommand();
}

void TestScenarioAdvancedTime::init()
{
	obj = new TimeConditionObject(0, 0);
}

void TestScenarioAdvancedTime::cleanup()
{
	delete obj;
}

void TestScenarioAdvancedTime::testTimeoutFuture()
{
	QTime now = QTime::currentTime();
	QTime timeout = now.addSecs(60 * 5);

	obj->setHours(timeout.hour());
	obj->setMinutes(timeout.minute());
	obj->save();

	int expected = (60 * 5 - now.second()) * 1000;

	QVERIFY(abs(obj->timer.interval() - expected) < 1000);
}

void TestScenarioAdvancedTime::testTimeoutPast()
{
	QTime now = QTime::currentTime();
	QTime timeout = now.addSecs(-60 * 5);

	obj->setHours(timeout.hour());
	obj->setMinutes(timeout.minute());
	obj->save();

	int expected = (24 * 60 * 60 - 60 * 5 - now.second()) * 1000;

	QVERIFY(abs(obj->timer.interval() - expected) < 1000);
}

void TestScenarioAdvancedDeviceEdit::init()
{
	bt_global::config = new QHash<GlobalField, QString>();
}

void TestScenarioAdvancedDeviceEdit::cleanup()
{
	delete bt_global::config;
	bt_global::config = 0;
}

void TestScenarioAdvancedDeviceEdit::testLightConditionInit()
{
	DeviceConditionObject objon(DeviceCondition::LIGHT, "", "1", "2", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList());
	QCOMPARE(objon.device_cond->getState(), qMakePair(1, 1));

	DeviceConditionObject objoff(DeviceCondition::LIGHT, "", "0", "2", NOT_PULL);

	QCOMPARE(objoff.getOnOff(), QVariant(false));
	QCOMPARE(objoff.getRangeValues(), QVariantList());
	QCOMPARE(objoff.device_cond->getState(), qMakePair(0, 0));
}

void TestScenarioAdvancedDeviceEdit::testDimmerConditionInit()
{
	DeviceConditionObject objon(DeviceCondition::DIMMING, "", "5-7", "3", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 50 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(5, 7));

	DeviceConditionObject objoff(DeviceCondition::DIMMING, "", "0", "3", NOT_PULL);

	QCOMPARE(objoff.getOnOff(), QVariant(false));
	QCOMPARE(objoff.getRangeValues(), QVariantList() << 20 << 40);
	QCOMPARE(objoff.device_cond->getState(), qMakePair(0, 0));
}

void TestScenarioAdvancedDeviceEdit::testDimmer100ConditionInit()
{
	DeviceConditionObject objon(DeviceCondition::DIMMING100, "", "41-70", "4", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(41, 70));

	DeviceConditionObject objoff(DeviceCondition::DIMMING100, "", "0", "4", NOT_PULL);

	QCOMPARE(objoff.getOnOff(), QVariant(false));
	QCOMPARE(objoff.getRangeValues(), QVariantList() << 1 << 20);
	QCOMPARE(objoff.device_cond->getState(), qMakePair(0, 0));
}

void TestScenarioAdvancedDeviceEdit::testAmplifierConditionInit()
{
	DeviceConditionObject objon(DeviceCondition::AMPLIFIER, "", "13-22", "21", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(13, 22));

	DeviceConditionObject objoff(DeviceCondition::AMPLIFIER, "", "-1", "21", NOT_PULL);

	QCOMPARE(objoff.getOnOff(), QVariant(false));
	QCOMPARE(objoff.getRangeValues(), QVariantList() << 1 << 100);
	QCOMPARE(objoff.device_cond->getState(), qMakePair(-1, -1));
}

void TestScenarioAdvancedDeviceEdit::testTemperatureConditionInit()
{
	DeviceConditionObject objon(DeviceCondition::TEMPERATURE, "", "220", "16", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant());
	QCOMPARE(objon.getRangeValues(), QVariantList() << 22.0);
	QCOMPARE(objon.device_cond->getState(), qMakePair(220, 220));
}

void TestScenarioAdvancedDeviceEdit::testLightConditionOnOff()
{
	DeviceConditionObject objon(DeviceCondition::LIGHT, "", "1", "2", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList());
	QCOMPARE(objon.device_cond->getState(), qMakePair(1, 1));

	objon.setOnOff(QVariant(false));

	QCOMPARE(objon.getOnOff(), QVariant(false));
	QCOMPARE(objon.getRangeValues(), QVariantList());
	QCOMPARE(objon.device_cond->getState(), qMakePair(0, 0));

	objon.setOnOff(QVariant(true));

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList());
	QCOMPARE(objon.device_cond->getState(), qMakePair(1, 1));
}

void TestScenarioAdvancedDeviceEdit::testDimmerConditionOnOff()
{
	DeviceConditionObject objon(DeviceCondition::DIMMING, "", "5-7", "3", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 50 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(5, 7));

	objon.setOnOff(QVariant(false));

	QCOMPARE(objon.getOnOff(), QVariant(false));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 50 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(0, 0));

	objon.setOnOff(QVariant(true));

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 50 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(5, 7));
}

void TestScenarioAdvancedDeviceEdit::testDimmer100ConditionOnOff()
{
	DeviceConditionObject objon(DeviceCondition::DIMMING100, "", "41-70", "4", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(41, 70));

	objon.setOnOff(QVariant(false));

	QCOMPARE(objon.getOnOff(), QVariant(false));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(0, 0));

	objon.setOnOff(QVariant(true));

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(41, 70));
}

void TestScenarioAdvancedDeviceEdit::testAmplifierConditionOnOff()
{
	DeviceConditionObject objon(DeviceCondition::AMPLIFIER, "", "13-22", "21", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(13, 22));

	objon.setOnOff(QVariant(false));

	QCOMPARE(objon.getOnOff(), QVariant(false));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(-1, -1));

	objon.setOnOff(QVariant(true));

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 41 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(13, 22));
}

void TestScenarioAdvancedDeviceEdit::testConditionReset()
{
	// only tests one object type because updates go through
	// the code already tested aobve
	DeviceConditionObject objon(DeviceCondition::DIMMING, "", "5-7", "3", NOT_PULL);

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 50 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(5, 7));

	objon.conditionDown();

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 20 << 40);
	QCOMPARE(objon.device_cond->getState(), qMakePair(2, 4));

	objon.reset();

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 50 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(5, 7));

	objon.reset();

	QCOMPARE(objon.getOnOff(), QVariant(true));
	QCOMPARE(objon.getRangeValues(), QVariantList() << 50 << 70);
	QCOMPARE(objon.device_cond->getState(), qMakePair(5, 7));
}
