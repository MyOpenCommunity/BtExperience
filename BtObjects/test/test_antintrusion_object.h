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

#ifndef TEST_ANTINTRUSION_DEVICE_H
#define TEST_ANTINTRUSION_DEVICE_H

#include "test_btobject.h"
#include "antintrusionsystem.h"

#include <QObject>

typedef QList<QPair<AntintrusionAlarm::AlarmType, int> > AlarmZoneList;

class TestAntintrusionSystem : public TestBtObject
{
Q_OBJECT
private slots:
	void init();
	void cleanup();

	void testToggleActivation();
	void testActivateSystem();
	void testPasswordFail();
	void testIntrusionAlarm();
	void testTamperingAlarm();
	void testTechnicalAlarm();
	void testAntipanicAlarm();
	void testNoDoubleAlarms();
	void testResetTechnicalAlarm();
	void testClearAlarmsOnInsert();
	void testAlarmOnNotConfiguredZone();
	void testTechnicalAlarmOnNotConfiguredZone();

private:
	void checkAlarmedZones(AlarmZoneList l);
	AntintrusionSystem *obj;
	AntintrusionDevice *dev;
};

#endif
