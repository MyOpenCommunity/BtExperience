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

struct AlarmInfo
{
	AntintrusionAlarm::AlarmType type;
	int number;
	QString name;

	AlarmInfo(AntintrusionAlarm::AlarmType _type, int _number, QString _name)
	{
		type = _type;
		number = _number;
		name = _name;
	}
};

inline bool operator==(const AlarmInfo &first, const AlarmInfo &second)
{
	return first.type == second.type && first.number == second.number && first.name == second.name;
}

inline bool operator!=(const AlarmInfo &first, const AlarmInfo &second)
{
	return !(first == second);
}


typedef QList<AlarmInfo> AlarmZoneList;

class TestAntintrusionSystem : public TestBtObject
{
Q_OBJECT
private slots:
	void initTestCase();
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
	void testModifyPartializationWithRightCode();
	void testModifyPartializationWithWrongCode();
	void testPartializationWithoutModification();
	void testPartializationWithSystemInserted();

protected:
	void compareClientCommand();

private:
	void checkAlarmedZones(AlarmZoneList l);
	void setSystemActive(bool active);
	void setZonesInserted();
	void unselectFirstTwoZones();
	void checkWaitingResponse(bool waiting_response);
	AntintrusionSystem *obj;
	AntintrusionDevice *dev;
};

#endif
