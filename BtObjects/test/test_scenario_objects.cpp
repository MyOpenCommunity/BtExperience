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

#include <QtTest>

Q_DECLARE_METATYPE(DeviceValues)
Q_DECLARE_METATYPE(ScenarioModule::Status)


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
	// Receiving a STOP frame shouldn't trigger a state change, we should receive
	// a frame afterwards from the scenario module
	QTest::addColumn<DeviceValues>("value");
	QTest::addColumn<ScenarioModule::Status>("start_status");
	QTest::addColumn<ScenarioModule::Status>("end_status");
	QTest::addColumn<int>("signals_emitted");

	// Receive Stop on my scenario
	DeviceValues v = packStartValues(false, SCENARIO_NUMBER);

	QTest::newRow("Locked") <<
		v << ScenarioModule::Locked << ScenarioModule::Locked << 0;
	QTest::newRow("Unlocked") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Unlocked << 0;
	QTest::newRow("Editing") <<
		v << ScenarioModule::Editing << ScenarioModule::Editing << 0;

	// Receive Stop on another scenario
	v = packStartValues(false, SCENARIO_NUMBER + 1);

	QTest::newRow("LockedOther") <<
		v << ScenarioModule::Locked << ScenarioModule::Locked << 0;
	QTest::newRow("UnlockedOther") <<
		v << ScenarioModule::Unlocked << ScenarioModule::Unlocked << 0;
	QTest::newRow("EditingOther") <<
		v << ScenarioModule::Editing << ScenarioModule::Editing << 0;
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
