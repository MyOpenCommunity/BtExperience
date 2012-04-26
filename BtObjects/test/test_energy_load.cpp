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
#include "energyload.h"
#include "objecttester.h"

#include <QtTest>


void TestEnergyLoadDiagnostic::init()
{
	LoadsDevice *d = new LoadsDevice("1");

	obj = new EnergyLoadDiagnostic(d, "");
	dev = new LoadsDevice("1", 1);
}

void TestEnergyLoadDiagnostic::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestEnergyLoadDiagnostic::testReceiveStatus()
{
	DeviceValues v;
	ObjectTester t(obj, SIGNAL(statusChanged()));

	v[LoadsDevice::DIM_LOAD] = LoadsDevice::LOAD_CRITICAL;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), EnergyLoadDiagnostic::Critical);

	v[LoadsDevice::DIM_LOAD] = LoadsDevice::LOAD_WARNING;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), EnergyLoadDiagnostic::Warning);

	v[LoadsDevice::DIM_LOAD] = LoadsDevice::LOAD_OK;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getStatus(), EnergyLoadDiagnostic::Ok);

	obj->valueReceived(v);
	t.checkNoSignals();
}
