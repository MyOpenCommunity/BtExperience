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

#ifndef TEST_THERMALPROBES_OBJECT_H
#define TEST_THERMALPROBES_OBJECT_H

#include "test_btobject.h"
#include "../devices/probe_device.h" // ControlledProbeDevice::ProbeStatus
#include "thermalprobes.h" // ThermalControlledProbe::ProbeStatus

#include <QObject>

class ThermalControlledProbe;
class ControlledProbeDevice;


class TestThermalControlledProbes : public TestBtObject
{
Q_OBJECT
private slots:
	void init();
	void cleanup();

	void testSetSetPoint();
	void testSetProbeStatus();

	void testReceiveTemperature();
	void testReceiveSetPoint();
	void testReceiveStatus();
	void testReceiveLocalStatus();
	void testReceiveLocalOffset();

protected:
	void compareClientCommand();
	void initObjects(ControlledProbeDevice *dev, ThermalControlledProbeFancoil *obj);

private:
	void testReceiveStatus(ControlledProbeDevice::ProbeStatus device_status,
			       ThermalControlledProbe::ProbeStatus object_status);
	void testReceiveLocalStatus(ControlledProbeDevice::ProbeStatus device_status,
				    ThermalControlledProbe::ProbeStatus object_status,
				    bool changed);

	ThermalControlledProbe *obj;
	ControlledProbeDevice *dev;
};


class TestThermalControlledProbesFancoil : public TestThermalControlledProbes
{
Q_OBJECT
private slots:
	void init();

	void testSetFancoilSpeed();

	void testReceiveFancoilSpeed();

private:
	void testReceiveFancoilSpeed(int device_speed,
				     ThermalControlledProbeFancoil::FancoilSpeed object_speed);

	ThermalControlledProbeFancoil *obj;
	ControlledProbeDevice *dev;
};

#endif // TEST_THERMALPROBES_OBJECT_H
