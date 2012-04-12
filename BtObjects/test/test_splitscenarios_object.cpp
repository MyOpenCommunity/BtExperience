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

#include "test_splitscenarios_object.h"

#include "openserver_mock.h"
#include "openclient.h"
#include "objecttester.h"

#include "splitbasicscenario.h"
#include "airconditioning_device.h"
#include "probe_device.h"

#include <QtTest/QtTest>
#include <QPair>


namespace {
	const QString PROGRAM_COMMAND_1("command 1");
	const QString PROGRAM_EMPTY("");
	const QString PROGRAM_FOO("foo");
	const QString PROGRAM_MANUAL("manual");
	const QString PROGRAM_OFF("off");
}

void TestSplitScenarios::init()
{
	dev_probe = new NonControlledProbeDevice("11", NonControlledProbeDevice::INTERNAL, 1);
	dev = new AirConditioningDevice("12", 1);
	QStringList programs;
	programs << PROGRAM_MANUAL << PROGRAM_COMMAND_1;
	obj = new SplitBasicScenario(
				"TestSplitBasicScenario",
				"13",
				new AirConditioningDevice("12"),
				"14",
				"15",
				new NonControlledProbeDevice("11", NonControlledProbeDevice::INTERNAL),
				programs
				);
}

void TestSplitScenarios::cleanup()
{
	delete obj->dev;
	delete obj->dev_probe;
	delete obj;
	delete dev_probe;
	delete dev;
}

void TestSplitScenarios::testReceiveTemperature()
{
	DeviceValues v;
	v[NonControlledProbeDevice::DIM_TEMPERATURE] = 256;

	ObjectTester t(obj, SIGNAL(temperatureChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(256, obj->getTemperature());

	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestSplitScenarios::testSetProgram()
{
	ObjectTester t(obj, SIGNAL(programChanged()));
	obj->setProgram(PROGRAM_MANUAL);
	t.checkSignals();
	QCOMPARE(PROGRAM_MANUAL, obj->getProgram());

	obj->setProgram(PROGRAM_COMMAND_1);
	t.checkSignals();
	QCOMPARE(PROGRAM_COMMAND_1, obj->getProgram());

	obj->setProgram(PROGRAM_COMMAND_1);
	t.checkNoSignals();
	QCOMPARE(PROGRAM_COMMAND_1, obj->getProgram());

	obj->setProgram(PROGRAM_EMPTY);
	t.checkNoSignals();
	QCOMPARE(PROGRAM_COMMAND_1, obj->getProgram());

	obj->setProgram(PROGRAM_FOO);
	t.checkNoSignals();
	QCOMPARE(PROGRAM_COMMAND_1, obj->getProgram());

	obj->setProgram(PROGRAM_OFF);
	t.checkSignals();
	QCOMPARE(PROGRAM_OFF, obj->getProgram());
}

void TestSplitScenarios::compareClientCommand()
{
	flushCompressedFrames(dev);
	flushCompressedFrames(dev_probe);
	flushCompressedFrames(obj->dev);
	flushCompressedFrames(obj->dev_probe);
	TestBtObject::compareClientCommand();
}

void TestSplitScenarios::testSendCommand()
{
	// set command 1 program
	obj->setProgram(PROGRAM_COMMAND_1);
	QCOMPARE(PROGRAM_COMMAND_1, obj->getProgram());

	obj->ok();
	dev->activateScenario("14");
	compareClientCommand();
}

void TestSplitScenarios::testSendOffCommand()
{
	// set off program
	obj->setProgram(PROGRAM_OFF);
	QCOMPARE(PROGRAM_OFF, obj->getProgram());

	obj->ok();
	dev->setOffCommand("15");
	dev->turnOff();
	compareClientCommand();
}
