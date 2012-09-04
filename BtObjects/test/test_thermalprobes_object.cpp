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

#include "test_thermalprobes_object.h"
#include "../devices/probe_device.h"
#include "thermalprobes.h"
#include "openserver_mock.h"
#include "openclient.h"
#include "objecttester.h"

#include <QtTest/QtTest>
#include <QPair>


void TestThermalNonControlledProbes::init()
{
	NonControlledProbeDevice *d = new NonControlledProbeDevice("23#1", NonControlledProbeDevice::EXTERNAL);

	obj = new ThermalNonControlledProbe("", "", ObjectInterface::IdThermalExternalProbe, d);
	dev = new NonControlledProbeDevice("23#1", NonControlledProbeDevice::EXTERNAL, 1);
}

void TestThermalNonControlledProbes::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestThermalNonControlledProbes::testReceiveTemperature()
{
	DeviceValues v;
	v[NonControlledProbeDevice::DIM_TEMPERATURE] = 1010;

	ObjectTester t(obj, SIGNAL(temperatureChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(-10, obj->getTemperature());

	obj->valueReceived(v);
	t.checkNoSignals();
}


void TestThermalControlledProbes::initObjects(ControlledProbeDevice *_dev, ThermalControlledProbeFancoil *_obj)
{
	obj = _obj;
	dev = _dev;
}

void TestThermalControlledProbes::init()
{
	ControlledProbeDevice *d = new ControlledProbeDevice("23#1", "1", "23", ControlledProbeDevice::CENTRAL_99ZONES, ControlledProbeDevice::NORMAL);

	obj = new ThermalControlledProbe("", "", ThermalControlledProbe::CentralUnit99Zones, d);
	dev = new ControlledProbeDevice("23#1", "1", "23", ControlledProbeDevice::CENTRAL_99ZONES, ControlledProbeDevice::NORMAL, 1);
}

void TestThermalControlledProbes::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestThermalControlledProbes::compareClientCommand()
{
	flushCompressedFrames(dev);
	flushCompressedFrames(obj->dev);
	TestBtObject::compareClientCommand();
}

void TestThermalControlledProbes::testSetSetPoint()
{
	clearAllClients();

	// test sending the first frame
	obj->setSetpoint(30);
	dev->setManual(30);
	compareClientCommand();

	// test sending again with the same set point
	obj->setSetpoint(30);
	dev->setManual(30);
	compareClientCommand();

	// TODO check frame not sent if same setpoint
}

void TestThermalControlledProbes::testSetProbeStatus()
{
	obj->setProbeStatus(ThermalControlledProbe::Off);
	dev->setOff();
	compareClientCommand();

	obj->setProbeStatus(ThermalControlledProbe::Manual);
	dev->setManual(215);
	compareClientCommand();

	obj->setProbeStatus(ThermalControlledProbe::Auto);
	dev->setAutomatic();
	compareClientCommand();

	obj->setProbeStatus(ThermalControlledProbe::Antifreeze);
	dev->setProtection();
	compareClientCommand();

	// TODO check frame not sent if same state
}

void TestThermalControlledProbes::testReceiveTemperature()
{
	DeviceValues v;
	v[ControlledProbeDevice::DIM_TEMPERATURE] = 1010;

	ObjectTester t(obj, SIGNAL(temperatureChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(-10, obj->getTemperature());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlledProbes::testReceiveSetPoint()
{
	DeviceValues v;
	v[ControlledProbeDevice::DIM_SETPOINT] = 1010;

	ObjectTester t(obj, SIGNAL(setpointChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(-10, obj->getSetpoint());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlledProbes::testReceiveStatus(ControlledProbeDevice::ProbeStatus device_status,
					  ThermalControlledProbe::ProbeStatus object_status)
{
	DeviceValues v;
	v[ControlledProbeDevice::DIM_STATUS] = device_status;

	ObjectTester t(obj, SIGNAL(probeStatusChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(object_status, obj->getProbeStatus());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlledProbes::testReceiveLocalStatus(ControlledProbeDevice::ProbeStatus device_status,
					       ThermalControlledProbe::ProbeStatus object_status,
					       bool changed)
{
	DeviceValues v;
	v[ControlledProbeDevice::DIM_LOCAL_STATUS] = device_status;

	ObjectTester t(obj, SIGNAL(probeStatusChanged()));
	obj->valueReceived(v);
	if (changed)
		t.checkSignals();
	else
		t.checkNoSignals();
	QCOMPARE(object_status, obj->getProbeStatus());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlledProbes::testReceiveStatus()
{
	testReceiveStatus(ControlledProbeDevice::ST_OFF, ThermalControlledProbe::Off);
	testReceiveStatus(ControlledProbeDevice::ST_NONE, ThermalControlledProbe::Unknown);
	testReceiveStatus(ControlledProbeDevice::ST_MANUAL, ThermalControlledProbe::Manual);
	testReceiveStatus(ControlledProbeDevice::ST_PROTECTION, ThermalControlledProbe::Antifreeze);
	testReceiveStatus(ControlledProbeDevice::ST_AUTO, ThermalControlledProbe::Auto);
}

void TestThermalControlledProbes::testReceiveLocalStatus()
{
	testReceiveStatus(ControlledProbeDevice::ST_OFF, ThermalControlledProbe::Off);
	testReceiveLocalStatus(ControlledProbeDevice::ST_OFF, ThermalControlledProbe::Off, false);
	testReceiveLocalStatus(ControlledProbeDevice::ST_NORMAL, ThermalControlledProbe::Off, false);

	testReceiveStatus(ControlledProbeDevice::ST_MANUAL, ThermalControlledProbe::Manual);
	testReceiveLocalStatus(ControlledProbeDevice::ST_OFF, ThermalControlledProbe::Off, true);
	testReceiveLocalStatus(ControlledProbeDevice::ST_PROTECTION, ThermalControlledProbe::Antifreeze, true);
	testReceiveLocalStatus(ControlledProbeDevice::ST_NORMAL, ThermalControlledProbe::Manual, true);

	testReceiveStatus(ControlledProbeDevice::ST_PROTECTION, ThermalControlledProbe::Antifreeze);
	testReceiveLocalStatus(ControlledProbeDevice::ST_OFF, ThermalControlledProbe::Off, true);
	testReceiveLocalStatus(ControlledProbeDevice::ST_PROTECTION, ThermalControlledProbe::Antifreeze, true);
	testReceiveLocalStatus(ControlledProbeDevice::ST_NORMAL, ThermalControlledProbe::Antifreeze, false);

	testReceiveStatus(ControlledProbeDevice::ST_AUTO, ThermalControlledProbe::Auto);
	testReceiveLocalStatus(ControlledProbeDevice::ST_OFF, ThermalControlledProbe::Off, true);
	testReceiveLocalStatus(ControlledProbeDevice::ST_PROTECTION, ThermalControlledProbe::Antifreeze, true);
	testReceiveLocalStatus(ControlledProbeDevice::ST_NORMAL, ThermalControlledProbe::Auto, true);
}

void TestThermalControlledProbes::testReceiveLocalOffset()
{
	DeviceValues v;
	v[ControlledProbeDevice::DIM_LOCAL_STATUS] = ControlledProbeDevice::ST_NORMAL;
	v[ControlledProbeDevice::DIM_OFFSET] = 2;

	ObjectTester t(obj, SIGNAL(localOffsetChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLocalOffset(), 2);

	obj->valueReceived(v);
	t.checkNoSignals();

	v.clear();
	v[ControlledProbeDevice::DIM_LOCAL_STATUS] = ControlledProbeDevice::ST_OFF;
	v[ControlledProbeDevice::DIM_OFFSET] = 3;

	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getLocalOffset(), 0);
}


void TestThermalControlledProbesFancoil::init()
{
	ControlledProbeDevice *d = new ControlledProbeDevice("23#1", "1", "23", ControlledProbeDevice::CENTRAL_99ZONES, ControlledProbeDevice::FANCOIL);

	obj = new ThermalControlledProbeFancoil("", "", ThermalControlledProbe::CentralUnit99Zones, d);
	dev = new ControlledProbeDevice("23#1", "1", "23", ControlledProbeDevice::CENTRAL_99ZONES, ControlledProbeDevice::FANCOIL, 1);

	initObjects(dev, obj);
}

void TestThermalControlledProbesFancoil::testSetFancoilSpeed()
{
	obj->setFancoil(ThermalControlledProbeFancoil::FancoilMin);
	dev->setFancoilSpeed(1);
	compareClientCommand();

	obj->setFancoil(ThermalControlledProbeFancoil::FancoilMed);
	dev->setFancoilSpeed(2);
	compareClientCommand();

	obj->setFancoil(ThermalControlledProbeFancoil::FancoilMax);
	dev->setFancoilSpeed(3);
	compareClientCommand();

	obj->setFancoil(ThermalControlledProbeFancoil::FancoilAuto);
	dev->setFancoilSpeed(0);
	compareClientCommand();
}

void TestThermalControlledProbesFancoil::testReceiveFancoilSpeed(int device_speed, ThermalControlledProbeFancoil::FancoilSpeed object_speed)
{
	DeviceValues v;
	v[ControlledProbeDevice::DIM_FANCOIL_STATUS] = device_speed;

	ObjectTester t(obj, SIGNAL(fancoilChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(object_speed, obj->getFancoil());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestThermalControlledProbesFancoil::testReceiveFancoilSpeed()
{
	testReceiveFancoilSpeed(1, ThermalControlledProbeFancoil::FancoilMin);
	testReceiveFancoilSpeed(2, ThermalControlledProbeFancoil::FancoilMed);
	testReceiveFancoilSpeed(3, ThermalControlledProbeFancoil::FancoilMax);
	testReceiveFancoilSpeed(0, ThermalControlledProbeFancoil::FancoilAuto);
}
