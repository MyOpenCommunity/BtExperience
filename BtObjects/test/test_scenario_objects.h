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

#ifndef TEST_SCENARIO_OBJECTS_H
#define TEST_SCENARIO_OBJECTS_H

#include "test_btobject.h"

class ScenarioModule;
class ScenarioDevice;

class TestScenarioModule : public TestBtObject
{
	Q_OBJECT
private slots:
	void init();
	void cleanup();

	void testReceiveLock();
	void testReceiveLock_data();
	void testReceiveUnlock();
	void testReceiveUnlock_data();
	void testReceiveStart();
	void testReceiveStart_data();
	void testReceiveStartOtherScenario();
	void testReceiveStartOtherScenario_data();
	void testReceiveStop();
	void testReceiveStop_data();

private:
	void checkMethod();
	ScenarioModule *scen;
	ScenarioDevice *dev;
};

#endif // TEST_SCENARIO_OBJECTS_H
