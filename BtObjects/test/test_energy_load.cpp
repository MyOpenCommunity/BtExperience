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

#include "test_energy_load.h"

#include "loads_device.h"
#include "energy_device.h" // AutomaticUpdates
#include "energyload.h"
#include "objecttester.h"

#include <QtTest>


void TestEnergyLoadManagement::initObjects(LoadsDevice *_dev, EnergyLoadManagement *_obj)
{
	obj = _obj;
	dev = _dev;
}

void TestEnergyLoadManagement::init()
{
	LoadsDevice *d = new LoadsDevice("1");

	obj = new EnergyLoadManagement(d, "");
	dev = new LoadsDevice("1", 1);
}

void TestEnergyLoadManagement::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestEnergyLoadManagement::testReceiveLoadStatus()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(loadStatusChanged()));

	v[LoadsDevice::DIM_LOAD] = LoadsDevice::LOAD_CRITICAL;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoadStatus(), EnergyLoadManagement::Critical);

	v[LoadsDevice::DIM_LOAD] = LoadsDevice::LOAD_WARNING;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoadStatus(), EnergyLoadManagement::Warning);

	v[LoadsDevice::DIM_LOAD] = LoadsDevice::LOAD_OK;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoadStatus(), EnergyLoadManagement::Ok);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestEnergyLoadManagement::testReceiveConsumption()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(consumptionChanged()));

	v[LoadsDevice::DIM_CURRENT] = 100;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getConsumption(), 100);

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestEnergyLoadManagement::testReceiveTotals()
{
	QVariantList totals = obj->getPeriodTotals();
	EnergyLoadTotal *l1 = qobject_cast<EnergyLoadTotal *>(totals[0].value<QObject *>());
	EnergyLoadTotal *l2 = qobject_cast<EnergyLoadTotal *>(totals[1].value<QObject *>());

	ObjectTester td1(l1, SIGNAL(resetDateTimeChanged()));
	ObjectTester td2(l2, SIGNAL(resetDateTimeChanged()));
	ObjectTester tt1(l1, SIGNAL(totalChanged()));
	ObjectTester tt2(l2, SIGNAL(totalChanged()));

	QDateTime reset1 = QDateTime::currentDateTime();
	QDateTime reset2 = QDateTime::currentDateTime().addDays(-1);

	DeviceValues v;

	v[LoadsDevice::DIM_PERIOD] = 0;
	v[LoadsDevice::DIM_TOTAL] = 100;
	v[LoadsDevice::DIM_RESET_DATE] = reset1;

	obj->valueReceived(v);
	td1.checkSignals();
	tt1.checkSignals();
	td2.checkNoSignals();
	tt2.checkNoSignals();
	QCOMPARE(l1->getResetDateTime(), reset1);
	QCOMPARE(l1->getTotal(), 100);

	v[LoadsDevice::DIM_PERIOD] = 1;
	v[LoadsDevice::DIM_TOTAL] = 100;
	v[LoadsDevice::DIM_RESET_DATE] = reset1;

	obj->valueReceived(v);
	td1.checkNoSignals();
	tt1.checkNoSignals();
	td2.checkSignals();
	tt2.checkSignals();
	QCOMPARE(l2->getResetDateTime(), reset1);
	QCOMPARE(l2->getTotal(), 100);

	v[LoadsDevice::DIM_PERIOD] = 0;
	v[LoadsDevice::DIM_TOTAL] = 100;
	v[LoadsDevice::DIM_RESET_DATE] = reset2;

	obj->valueReceived(v);
	td1.checkSignals();
	tt1.checkNoSignals();
	td2.checkNoSignals();
	tt2.checkNoSignals();
	QCOMPARE(l1->getResetDateTime(), reset2);
	QCOMPARE(l1->getTotal(), 100);

	v[LoadsDevice::DIM_PERIOD] = 1;
	v[LoadsDevice::DIM_TOTAL] = 101;
	v[LoadsDevice::DIM_RESET_DATE] = reset1;

	obj->valueReceived(v);
	td1.checkNoSignals();
	tt1.checkNoSignals();
	td2.checkNoSignals();
	tt2.checkSignals();
	QCOMPARE(l2->getResetDateTime(), reset1);
	QCOMPARE(l2->getTotal(), 101);
}

void TestEnergyLoadManagement::testRequestLoadStatus()
{
	obj->requestLoadStatus();
	dev->requestLevel();
	compareClientRequest();
}

void TestEnergyLoadManagement::testRequestTotals()
{
	obj->requestTotals();
	dev->requestTotal(0);
	dev->requestTotal(1);
	compareClientRequest();
}

void TestEnergyLoadManagement::testRequestConsumptionUpdateStartStop()
{
	obj->requestConsumptionUpdateStart();
	dev->requestCurrentUpdateStart();
	compareClientCommand();

	obj->requestConsumptionUpdateStop();
	dev->requestCurrentUpdateStop();
	// compareClientCommand();
}

void TestEnergyLoadManagement::testResetTotal()
{
	obj->resetTotal(0);
	dev->resetTotal(0);
	compareClientCommand();

	obj->resetTotal(1);
	dev->resetTotal(1);
	compareClientCommand();
}


void TestEnergyLoadManagementWithControlUnit::init()
{
	LoadsDevice *d = new LoadsDevice("1");

	obj = new EnergyLoadManagementWithControlUnit(d, true, "");
	dev = new LoadsDevice("1", 1);

	initObjects(dev, obj);
}

void TestEnergyLoadManagementWithControlUnit::testForceOn()
{
	obj->forceOn();
	dev->enable();
	compareClientCommand();
}

void TestEnergyLoadManagementWithControlUnit::testForceOnMinutes()
{
	obj->forceOn(30);
	dev->forceOff(30);
	compareClientCommand();

	obj->forceOn(130);
	dev->forceOff(130);
	compareClientCommand();
}

void TestEnergyLoadManagementWithControlUnit::testStopForcing()
{
	obj->stopForcing();
	dev->forceOn();
	compareClientCommand();
}

void TestEnergyLoadManagementWithControlUnit::testReceiveLoadEnabled()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(loadEnabledChanged()));

	v[LoadsDevice::DIM_ENABLED] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoadEnabled(), true);

	v[LoadsDevice::DIM_ENABLED] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoadEnabled(), false);
}

void TestEnergyLoadManagementWithControlUnit::testReceiveLoadForced()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(loadForcedChanged()));

	v[LoadsDevice::DIM_FORCED] = true;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoadForced(), true);

	v[LoadsDevice::DIM_FORCED] = false;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLoadForced(), false);
}
