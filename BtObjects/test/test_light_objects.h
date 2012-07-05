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

#ifndef TEST_LIGHT_OBJECT_H
#define TEST_LIGHT_OBJECT_H

#include "test_btobject.h"

class Light;
class LightingDevice;
class Dimmer;
class DimmerDevice;
class Dimmer100;
class Dimmer100Device;


class TestLight : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(LightingDevice *dev, Light *obj, Light *obj_ftime);

private slots:
	void init();
	void cleanup();

	virtual void testSetStatus();
	void testReceiveStatus();
	virtual void testSetTiming();
	void testSetHours();
	void testSetMinutes();
	void testSetSeconds();
	void testTurnOnWithFTimeDisabled();

private:
	Light *obj;
	Light *obj_ftime;
	LightingDevice *dev;
};


class TestDimmer : public TestLight
{
	Q_OBJECT

protected:
	void initObjects(DimmerDevice *dev, Dimmer *obj, Dimmer *obj_ftime);

private slots:
	void init();

	void testLevelUp();
	void testLevelDown();
	void testTurnOnWithFTimeDisabled();

	virtual void testReceiveLevel();

private:
	Dimmer *obj;
	Dimmer *obj_ftime;
	DimmerDevice *dev;
};


class TestDimmer100 : public TestDimmer
{
	Q_OBJECT

private slots:
	void init();

	void testLevelUp100();
	void testLevelDown100();

	void testOnSpeed();
	void testOffSpeed();
	void testStepSpeed();
	void testStepAmount();
	void testOnSpeedNotUsed();
	void testTurnOnWithFTimeDisabled();

private:
	virtual void testSetStatus();
	virtual void testSetTiming();
	virtual void testReceiveLevel();

	Dimmer100 *obj;
	Dimmer100 *obj_ftime;
	Dimmer100Device *dev;
};

#endif // TEST_LIGHT_OBJECT_H
