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

#include "test_stopandgo_objects.h"

#include "stopandgo_device.h"
#include "stopandgoobjects.h"
#include "objecttester.h"

#include <QtTest>


void TestStopAndGo::initObjects(StopAndGoDevice *_dev, StopAndGo *_obj)
{
	dev = _dev;
	obj = _obj;
}

void TestStopAndGo::init()
{
	StopAndGoDevice *d = new StopAndGoDevice("1");

	obj = new StopAndGo(d, "");
	dev = new StopAndGoDevice("1", 1);
}

void TestStopAndGo::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestStopAndGo::testSendAutoReset()
{
	obj->setAutoReset(true);
	dev->sendAutoResetActivation();
	compareClientCommand();

	obj->setAutoReset(false);
	dev->sendAutoResetDisactivation();
	compareClientCommand();
}

void TestStopAndGo::testReceiveStatus()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(statusChanged()));

	v[StopAndGoDevice::DIM_OPENED] = false;
	v[StopAndGoDevice::DIM_FAULT] = false;
	v[StopAndGoDevice::DIM_LOCKED] = false;
	v[StopAndGoDevice::DIM_OPENED_LE_N] = false;
	v[StopAndGoDevice::DIM_OPENED_GROUND] = false;
	v[StopAndGoDevice::DIM_OPENED_VMAX] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), StopAndGo::Closed);

	v[StopAndGoDevice::DIM_OPENED] = true;
	v[StopAndGoDevice::DIM_FAULT] = true;
	v[StopAndGoDevice::DIM_LOCKED] = false;
	v[StopAndGoDevice::DIM_OPENED_LE_N] = false;
	v[StopAndGoDevice::DIM_OPENED_GROUND] = false;
	v[StopAndGoDevice::DIM_OPENED_VMAX] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), StopAndGo::Opened);

	v[StopAndGoDevice::DIM_OPENED] = true;
	v[StopAndGoDevice::DIM_FAULT] = false;
	v[StopAndGoDevice::DIM_LOCKED] = true;
	v[StopAndGoDevice::DIM_OPENED_LE_N] = false;
	v[StopAndGoDevice::DIM_OPENED_GROUND] = false;
	v[StopAndGoDevice::DIM_OPENED_VMAX] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), StopAndGo::Locked);

	v[StopAndGoDevice::DIM_OPENED] = true;
	v[StopAndGoDevice::DIM_FAULT] = false;
	v[StopAndGoDevice::DIM_LOCKED] = false;
	v[StopAndGoDevice::DIM_OPENED_LE_N] = true;
	v[StopAndGoDevice::DIM_OPENED_GROUND] = false;
	v[StopAndGoDevice::DIM_OPENED_VMAX] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), StopAndGo::ShortCircuit);

	v[StopAndGoDevice::DIM_OPENED] = true;
	v[StopAndGoDevice::DIM_FAULT] = false;
	v[StopAndGoDevice::DIM_LOCKED] = false;
	v[StopAndGoDevice::DIM_OPENED_LE_N] = false;
	v[StopAndGoDevice::DIM_OPENED_GROUND] = true;
	v[StopAndGoDevice::DIM_OPENED_VMAX] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), StopAndGo::GroundFail);

	v[StopAndGoDevice::DIM_OPENED] = true;
	v[StopAndGoDevice::DIM_FAULT] = false;
	v[StopAndGoDevice::DIM_LOCKED] = false;
	v[StopAndGoDevice::DIM_OPENED_LE_N] = false;
	v[StopAndGoDevice::DIM_OPENED_GROUND] = false;
	v[StopAndGoDevice::DIM_OPENED_VMAX] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), StopAndGo::Overtension);
}

void TestStopAndGo::testReceiveAutoReset()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(autoResetChanged()));

	v[StopAndGoDevice::DIM_OPENED] = false;
	v[StopAndGoDevice::DIM_AUTORESET_DISACTIVE] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getAutoReset(), true);

	v[StopAndGoDevice::DIM_OPENED] = false;
	v[StopAndGoDevice::DIM_AUTORESET_DISACTIVE] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getAutoReset(), false);

	obj->valueReceived(v);
	t.checkNoSignals();
}


void TestStopAndGoPlus::init()
{
	StopAndGoPlusDevice *d = new StopAndGoPlusDevice("1");

	obj = new StopAndGoPlus(d, "");
	dev = new StopAndGoPlusDevice("1", 1);

	TestStopAndGo::initObjects(dev, obj);
}

void TestStopAndGoPlus::testSendDiagnostic()
{
	obj->setDiagnostic(true);
	dev->sendTrackingSystemActivation();
	compareClientCommand();

	obj->setDiagnostic(false);
	dev->sendTrackingSystemDisactivation();
	compareClientCommand();
}

void TestStopAndGoPlus::testReceiveDiagnostic()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(diagnosticChanged()));

	v[StopAndGoDevice::DIM_OPENED] = false;
	v[StopAndGoDevice::DIM_TRACKING_DISACTIVE] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getDiagnostic(), true);

	v[StopAndGoDevice::DIM_OPENED] = false;
	v[StopAndGoDevice::DIM_TRACKING_DISACTIVE] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getDiagnostic(), false);

	obj->valueReceived(v);
	t.checkNoSignals();
}


void TestStopAndGoBTest::init()
{
	StopAndGoBTestDevice *d = new StopAndGoBTestDevice("1");

	obj = new StopAndGoBTest(d, "");
	dev = new StopAndGoBTestDevice("1", 1);

	TestStopAndGo::initObjects(dev, obj);
}

void TestStopAndGoBTest::testSendAutoTest()
{
	obj->setAutoTest(true);
	dev->sendDiffSelftestActivation();
	compareClientCommand();

	obj->setAutoTest(false);
	dev->sendDiffSelftestDisactivation();
	compareClientCommand();
}

void TestStopAndGoBTest::testSendAutoTestFrequency()
{
	obj->setAutoTestFrequency(12);
	obj->apply();
	dev->sendSelftestFreq(12);
	compareClientCommand();
}

void TestStopAndGoBTest::testReceiveAutoTest()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(autoTestChanged()));

	v[StopAndGoDevice::DIM_OPENED] = false;
	v[StopAndGoDevice::DIM_AUTOTEST_DISACTIVE] = false;

	obj->valueReceived(v);
	t.checkNoSignals();
	QCOMPARE(obj->getAutoTest(), false);

	obj->auto_test = false;
	obj->current[StopAndGoBTest::AUTO_TEST_FREQUENCY] = obj->to_apply[StopAndGoBTest::AUTO_TEST_FREQUENCY] = 12;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getAutoTest(), true);

	v[StopAndGoDevice::DIM_OPENED] = false;
	v[StopAndGoDevice::DIM_AUTOTEST_DISACTIVE] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getAutoTest(), false);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestStopAndGoBTest::testReceiveAutoTestFrequency()
{
	DeviceValues v;
	ObjectTester tf(obj, SIGNAL(autoTestFrequencyChanged()));
	ObjectTester ta(obj, SIGNAL(autoTestChanged()));

	v[StopAndGoBTestDevice::DIM_AUTOTEST_FREQ] = 12;

	obj->valueReceived(v);
	tf.checkSignals();
	ta.checkNoSignals();
	QCOMPARE(obj->getAutoTest(), false);
	QCOMPARE(obj->getAutoTestFrequency(), 12);

	obj->auto_test = true;
	obj->current[StopAndGoBTest::AUTO_TEST_FREQUENCY] = obj->to_apply[StopAndGoBTest::AUTO_TEST_FREQUENCY] = -1;

	obj->valueReceived(v);
	tf.checkSignals();
	ta.checkSignals();
	QCOMPARE(obj->getAutoTest(), true);
	QCOMPARE(obj->getAutoTestFrequency(), 12);

	obj->valueReceived(v);
	tf.checkNoSignals();
	ta.checkNoSignals();

	v[StopAndGoBTestDevice::DIM_AUTOTEST_FREQ] = 13;

	obj->valueReceived(v);
	tf.checkSignals();
	ta.checkNoSignals();
	QCOMPARE(obj->getAutoTest(), true);
	QCOMPARE(obj->getAutoTestFrequency(), 13);
}
