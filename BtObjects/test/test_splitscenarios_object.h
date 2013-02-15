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

#ifndef TEST_SPLITSCENARIOS_OBJECT_H
#define TEST_SPLITSCENARIOS_OBJECT_H

#include "test_btobject.h"

#include <QObject>


class AdvancedAirConditioningDevice;
class AirConditioningDevice;
class NonControlledProbeDevice;
class SplitAdvancedScenario;
class SplitBasicScenario;
class SplitBasicProgram;
class SplitAdvancedProgram;


class TestSplitScenarios : public TestBtObject
{
Q_OBJECT
private slots:
	void init();
	void cleanup();

	void testReceiveTemperature();
	void testReceiveTemperature2();
	void testSendCommand();
	void testSendAdvancedCommand();
	void testSendOffCommand();
	void testSendAdvancedOffCommand();
	void testCreationWithNullProbe();
	void testSetProgram();
	void testSetAdvancedProgram();
	void testSetAdvancedProperties();

private:
	void compareClientCommand();
	SplitBasicProgram *findOffProgram();
	SplitBasicProgram *findProgram(const QString &name);
	SplitAdvancedProgram *findProgramAdv(const QString &name);

	SplitAdvancedScenario *obj_adv;
	SplitBasicScenario *obj;
	AdvancedAirConditioningDevice *dev_adv;
	AirConditioningDevice *dev;
	NonControlledProbeDevice *dev_probe;
};

#endif // TEST_SPLITSCENARIOS_OBJECT_H
