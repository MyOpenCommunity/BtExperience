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
#include "splitadvancedscenario.h"
#include "airconditioning_device.h"
#include "probe_device.h"

#include <QtTest/QtTest>
#include <QPair>


namespace {
	const QString DAY("day");
	const QString NIGHT("night");
	const QString PROGRAM_EMPTY("");
	const QString PROGRAM_FOO("foo");
	const QString PROGRAM_OFF("off");

	SplitBasicProgram PROGRAM_DAY_B(DAY, 77);
	SplitBasicProgram PROGRAM_NIGHT_B(NIGHT, 79);

	SplitAdvancedProgram PROGRAM_DAY_A(DAY, SplitAdvancedProgram::ModeDehumidification, 200, SplitAdvancedProgram::SpeedMed, SplitAdvancedProgram::SwingOn);
	SplitAdvancedProgram PROGRAM_NIGHT_A(NIGHT, SplitAdvancedProgram::ModeDehumidification, 200, SplitAdvancedProgram::SpeedMin, SplitAdvancedProgram::SwingOff);

	QList<int> modes;
	QList<int> speeds;
	QList<int> swings;
}

void TestSplitScenarios::init()
{
	modes << SplitAdvancedProgram::ModeOff
		  << SplitAdvancedProgram::ModeWinter
		  << SplitAdvancedProgram::ModeSummer
		  << SplitAdvancedProgram::ModeFan
		  << SplitAdvancedProgram::ModeDehumidification
		  << SplitAdvancedProgram::ModeAuto;
	speeds << SplitAdvancedProgram::SpeedAuto
		   << SplitAdvancedProgram::SpeedMin
		   << SplitAdvancedProgram::SpeedMed
		   << SplitAdvancedProgram::SpeedMax
		   << SplitAdvancedProgram::SpeedSilent;
	swings << SplitAdvancedProgram::SwingOff
		   << SplitAdvancedProgram::SwingOn;
	dev_probe = new NonControlledProbeDevice("11", NonControlledProbeDevice::INTERNAL, 1);
	dev = new AirConditioningDevice("12", 1);
	dev_adv = new AdvancedAirConditioningDevice("16", 1);

	obj = new SplitBasicScenario(
				"TestSplitBasicScenario",
				"13",
				new AirConditioningDevice("12"),
				"15",
				new NonControlledProbeDevice("11", NonControlledProbeDevice::INTERNAL));
	obj->addProgram(&PROGRAM_DAY_B);
	obj->addProgram(&PROGRAM_NIGHT_B);

	obj_adv = new SplitAdvancedScenario(
				"TestSplitAdvancedScenario",
				"17",
				new AdvancedAirConditioningDevice("16"),
				"18",
				new NonControlledProbeDevice("11", NonControlledProbeDevice::INTERNAL),
				modes,
				speeds,
				swings);
	obj_adv->addProgram(&PROGRAM_DAY_A);
	obj_adv->addProgram(&PROGRAM_NIGHT_A);
}

void TestSplitScenarios::cleanup()
{
	delete obj_adv->dev;
	delete obj->dev;
	delete obj->dev_probe;
	delete obj_adv;
	delete obj;
	delete dev_probe;
	delete dev;
	delete dev_adv;
}

void TestSplitScenarios::testCreationWithNullProbe()
{
	SplitBasicScenario *obj_tmp = new SplitBasicScenario(
				"TestSplitBasicScenarioTemp",
				"22",
				new AirConditioningDevice("23"),
				"25",
				0);
	delete obj_tmp;
	QList<SplitAdvancedProgram *> split_programs_tmp;
	SplitAdvancedScenario *obj_adv_tmp = new SplitAdvancedScenario(
				"TestSplitAdvancedScenarioTemp",
				"19",
				new AdvancedAirConditioningDevice("20"),
				"21",
				0,
				modes,
				speeds,
				swings);
	delete obj_adv_tmp;
}

void TestSplitScenarios::testReceiveTemperature()
{
	DeviceValues v;
	v[NonControlledProbeDevice::DIM_TEMPERATURE] = 256;

	// receives the data
	ObjectTester t(obj, SIGNAL(temperatureChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(256, obj->getTemperature());

	// receives again same data: nothing happens
	obj->valueReceived(v);
	t.checkNoSignals();
}

void TestSplitScenarios::testReceiveTemperature2()
{
	DeviceValues v;
	v[NonControlledProbeDevice::DIM_TEMPERATURE] = 345;

	// receives the data
	ObjectTester t(obj_adv, SIGNAL(temperatureChanged()));
	obj_adv->valueReceived(v);
	t.checkSignals();
	QCOMPARE(345, obj_adv->getTemperature());

	// receives again same data: nothing happens
	obj_adv->valueReceived(v);
	t.checkNoSignals();
}

void TestSplitScenarios::testSetProgram()
{
	// sets manual program
	ObjectTester t(obj, SIGNAL(programChanged()));
	obj->setProgram(NIGHT);
	t.checkSignals();
	QCOMPARE(NIGHT, obj->getProgram());

	// sets command 1 program
	obj->setProgram(DAY);
	t.checkSignals();
	QCOMPARE(DAY, obj->getProgram());

	// tries to set command 1 program again: nothing happens
	obj->setProgram(DAY);
	t.checkNoSignals();
	QCOMPARE(DAY, obj->getProgram());

	// tries to set empty program: nothing happens
	obj->setProgram(PROGRAM_EMPTY);
	t.checkNoSignals();
	QCOMPARE(DAY, obj->getProgram());

	// tries to set a not configured program: nothing happens
	obj->setProgram(PROGRAM_FOO);
	t.checkNoSignals();
	QCOMPARE(DAY, obj->getProgram());

	// sets the off program (it must be always defined)
	obj->setProgram(PROGRAM_OFF);
	t.checkSignals();
	QCOMPARE(PROGRAM_OFF, obj->getProgram());
}

void TestSplitScenarios::testSetAdvancedProgram()
{
	// sets day program
	ObjectTester t(obj_adv, SIGNAL(programChanged()));
	obj_adv->setProgram(DAY);
	t.checkSignals();
	QCOMPARE(DAY, obj_adv->getProgram());

	// tries to set empty program: nothing happens
	obj_adv->setProgram(PROGRAM_EMPTY);
	t.checkNoSignals();
	QCOMPARE(DAY, obj_adv->getProgram());

	// tries to set day program again: nothing happens
	obj_adv->setProgram(DAY);
	t.checkNoSignals();
	QCOMPARE(DAY, obj_adv->getProgram());

	// tries to set a not configured program: nothing happens
	obj_adv->setProgram(PROGRAM_FOO);
	t.checkNoSignals();
	QCOMPARE(DAY, obj_adv->getProgram());

	// sets night program
	obj_adv->setProgram(NIGHT);
	t.checkSignals();
	QCOMPARE(NIGHT, obj_adv->getProgram());
}

void TestSplitScenarios::compareClientCommand()
{
	flushCompressedFrames(dev);
	flushCompressedFrames(dev_adv);
	flushCompressedFrames(dev_probe);
	flushCompressedFrames(obj->dev);
	flushCompressedFrames(obj->dev_probe);
	flushCompressedFrames(obj_adv->dev);
	TestBtObject::compareClientCommand();
}

void TestSplitScenarios::testSendCommand()
{
	// set command 1 program
	obj->setProgram(NIGHT);
	QCOMPARE(NIGHT, obj->getProgram());

	// confirms operation the frame is sent
	obj->apply();
	dev->activateScenario("79");
	compareClientCommand();
}

void TestSplitScenarios::testSendAdvancedCommand()
{
	// set day program
	obj_adv->setProgram(DAY);
	QCOMPARE(DAY, obj_adv->getProgram());

	// confirms operation the frame is sent
	obj_adv->apply();
	dev_adv->setStatus(
				AdvancedAirConditioningDevice::MODE_DEHUM,
				200,
				AdvancedAirConditioningDevice::VEL_MED,
				AdvancedAirConditioningDevice::SWING_ON
				);
	compareClientCommand();
}

void TestSplitScenarios::testSendOffCommand()
{
	// set off program
	obj->setProgram(PROGRAM_OFF);
	QCOMPARE(PROGRAM_OFF, obj->getProgram());

	// confirms operations: the frame is sent
	obj->apply();
	dev->setOffCommand("15");
	dev->turnOff();
	compareClientCommand();
}

void TestSplitScenarios::testSendAdvancedOffCommand()
{
	// set day program
	obj_adv->setProgram(DAY);
	QCOMPARE(DAY, obj_adv->getProgram());

	// set off mode
	obj_adv->setMode(SplitAdvancedProgram::ModeOff);
	QCOMPARE(DAY, obj_adv->getProgram());

	// confirms operations: the frame is sent
	obj_adv->apply();
	dev_adv->turnOff();
	compareClientCommand();
}

void TestSplitScenarios::testSetAdvancedProperties()
{
	// sets day program
	obj_adv->setProgram(DAY);
	QCOMPARE(DAY, obj_adv->getProgram());

	// changes mode
	ObjectTester t1(obj_adv, SIGNAL(modeChanged()));
	obj_adv->setMode(SplitAdvancedProgram::ModeFan);
	t1.checkSignals();
	QCOMPARE(SplitAdvancedProgram::ModeFan, obj_adv->getMode());

	// switches off swing
	ObjectTester t2(obj_adv, SIGNAL(swingChanged()));
	obj_adv->nextSwing();
	t2.checkSignals();
	QCOMPARE(SplitAdvancedProgram::SwingOff, obj_adv->getSwing());

	// changes set point
	ObjectTester t3(obj_adv, SIGNAL(setPointChanged()));
	obj_adv->setSetPoint(260);
	t3.checkSignals();
	QCOMPARE(260, obj_adv->getSetPoint());

	// changes speed
	ObjectTester t4(obj_adv, SIGNAL(speedChanged()));
	obj_adv->nextSpeed();
	t4.checkSignals();
	QCOMPARE(SplitAdvancedProgram::SpeedMax, obj_adv->getSpeed());

	// sets swing to on and changes the program to night: all signals must be
	// emitted
	obj_adv->nextSwing();
	ObjectTester t5(obj_adv, SignalList()
				   << SIGNAL(programChanged())
					<< SIGNAL(modeChanged())
					<< SIGNAL(speedChanged())
					<< SIGNAL(swingChanged())
					<< SIGNAL(setPointChanged()));
	obj_adv->setProgram(NIGHT);
	t5.checkSignals();
	QCOMPARE(NIGHT, obj_adv->getProgram());
}

