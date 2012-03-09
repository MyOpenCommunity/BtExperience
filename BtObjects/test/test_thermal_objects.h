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

#ifndef TEST_THERMAL_OBJECT_H
#define TEST_THERMAL_OBJECT_H

#include "test_btobject.h"
#include "thermal_device.h"

#include <QObject>

class ThermalControlUnit;
class ThermalControlUnitObject;
class ThermalControlUnit99Zones;
class ThermalControlUnitManual;
class ThermalControlUnitScenario;
class ThermalControlUnitProgram;
class ThermalControlUnitTimedProgram;


class TestThermalControlUnit : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(ThermalDevice *dev, ThermalControlUnit *obj);

	template<class T>
	void testChangeModality(ThermalDevice::Status status, int object_id, T **result = NULL);

private slots:
	void testSetSeason();

	void testReceiveSeason();

	void testModalityManual();
	void testModalityOff();
	void testModalityAntifreeze();
	void testModalityProgram();
	void testModalityVacation();
	void testModalityHoliday();

private:
	ThermalDevice *dev;
	ThermalControlUnit *obj;
};


class TestThermalControlUnit99Zones : public TestThermalControlUnit
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testModalityScenarios();

private:
	ThermalDevice99Zones *dev;
	ThermalControlUnit99Zones *obj;
};


class TestThermalControlUnitObject : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(ThermalDevice *dev, ThermalControlUnit *cu, ThermalControlUnitObject *obj);
	void cleanup();

private slots:
	// this is virtual so it's called only once in derived classes
	virtual void testApply() = 0;

private:
	ThermalDevice *dev;
	ThermalControlUnit *cu;
	ThermalControlUnitObject *obj;
};


class TestThermalControlUnitManual : public TestThermalControlUnitObject
{
	Q_OBJECT

private slots:
	void init();

	void testSetTemperature();
	void testReceiveTemperature();

private:
	virtual void testApply();

	ThermalDevice *dev;
	ThermalControlUnitManual *obj;
};


class TestThermalControlUnitScenario : public TestThermalControlUnitObject
{
	Q_OBJECT

private slots:
	void init();

	void testSetScenarioIndex();
	void testReceiveScenarioId();

private:
	virtual void testApply();

	ThermalDevice99Zones *dev;
	ThermalControlUnitScenario *obj;
};


class TestThermalControlUnitProgram : public TestThermalControlUnitObject
{
	Q_OBJECT

private slots:
	void init();

	void testSetProgramIndex();
	void testReceiveProgramId();

protected:
	virtual void testApply();

	ThermalDevice *dev;
	ThermalControlUnitProgram *obj;
};


class TestThermalControlUnitTimedProgram : public TestThermalControlUnitProgram
{
	Q_OBJECT

private slots:
	void testSetDate();
	void testSetTime();

protected:
	void initProgram(int object_id);

	ThermalControlUnitTimedProgram *obj;
};


class TestThermalControlUnitVacation : public TestThermalControlUnitTimedProgram
{
	Q_OBJECT

private slots:
	void init();

private:
	virtual void testApply();
};


class TestThermalControlUnitHoliday : public TestThermalControlUnitTimedProgram
{
	Q_OBJECT

private slots:
	void init();

private:
	virtual void testApply();
};

#endif // TEST_THERMAL_OBJECT_H
