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

#include "test_antintrusion_object.h"
#include "../devices/antintrusion_device.h"
#include "openserver_mock.h"
#include "openclient.h"
#include "objecttester.h"

#include <QtTest/QtTest>
#include <QPair>

namespace
{
	QList<int> splitZones(QString zones)
	{
		QList<int> l;
		foreach(QString s, zones.split("."))
			l << s.toInt();
		return l;
	}
}


namespace QTest
{
	template<> char *toString(const AlarmZoneList &l)
	{
		QByteArray ba = "AlarmZoneList(";
		for (int i = 0; i < l.length(); ++i)
		{
			QPair<AntintrusionAlarm::AlarmType, int> al = l[i];
			ba += "(" + QByteArray::number(al.first) + "," + QByteArray::number(al.second) + "),";
		}
		ba = ba.left(ba.length() - 1) + ")";
		return qstrdup(ba.data());
	}
}


void TestAntintrusionSystem::init()
{
	AntintrusionDevice *d = new AntintrusionDevice;

	QList<QPair<int, QString> > zone_list;
	zone_list << qMakePair(1, QString("ingresso")) << qMakePair(2, QString("cucina")) << qMakePair(3, QString("box")) <<
		qMakePair(4, QString("bagno")) << qMakePair(5, QString("camera")) << qMakePair(6, QString("mansarda")) <<
		qMakePair(7, QString("giardino"));

	QList<AntintrusionZone *> zones;
	for (int i = 0; i < zone_list.length(); ++i)
	{
		AntintrusionZone *z = new AntintrusionZone(zone_list.at(i).first, zone_list.at(i).second);
		QObject::connect(z, SIGNAL(requestPartialization(int,bool)), d, SLOT(partializeZone(int,bool)));
		zones << z;
	}
	QList<AntintrusionScenario *> scenarios;
	scenarios << new AntintrusionScenario("notte", splitZones("1.3.5"), zones) <<
		new AntintrusionScenario("inverno", splitZones("1.2.3"), zones) <<
		new AntintrusionScenario("estate", splitZones("4.5.7"), zones);

	obj = new AntintrusionSystem(d, scenarios, zones);
	dev = new AntintrusionDevice(1);
}

void TestAntintrusionSystem::cleanup()
{
	// TODO: AntintrusionSystem doesn't have a proper dtor...
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestAntintrusionSystem::testToggleActivation()
{
	obj->toggleActivation("12345");
	dev->toggleActivation("12345");
	compareClientCommand();
}


// TODO: Simplify test creation, some points to explore are:
//  - generic creation of signal spies with variable number of arguments - maybe not needed?
void TestAntintrusionSystem::testActivateSystem()
{
	// system not active
	obj->initialized = true;
	obj->status = false;

	// simulate activation
	obj->toggleActivation("12345");
	DeviceValues v;
	v[AntintrusionDevice::DIM_SYSTEM_INSERTED] = true;

	ObjectTester t(obj, SignalList() << SIGNAL(codeAccepted()) << SIGNAL(statusChanged()));

	obj->valueReceived(v);
	QCOMPARE(obj->getStatus(), true);
	t.checkSignals();
}

void TestAntintrusionSystem::testPasswordFail()
{
	// system not active
	obj->initialized = true;
	obj->status = false;

	obj->toggleActivation("12345");
	DeviceValues v;
	v[AntintrusionDevice::DIM_SYSTEM_INSERTED] = false;

	ObjectTester t(obj, SIGNAL(codeRefused()));

	obj->valueReceived(v);
	QCOMPARE(obj->getStatus(), false);
	t.checkSignals();
}

void TestAntintrusionSystem::testIntrusionAlarm()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_INTRUSION_ALARM] = 2;

	ObjectTester t(obj, SIGNAL(alarmsChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << qMakePair(AntintrusionAlarm::Intrusion, 2));
}

void TestAntintrusionSystem::testTamperingAlarm()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_TAMPER_ALARM] = 1;

	ObjectTester t(obj, SIGNAL(alarmsChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << qMakePair(AntintrusionAlarm::Tamper, 1));
}

void TestAntintrusionSystem::testTechincalAlarm()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_TECHNICAL_ALARM] = 5;

	ObjectTester t(obj, SIGNAL(alarmsChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << qMakePair(AntintrusionAlarm::Technical, 5));
}

void TestAntintrusionSystem::testAntipanicAlarm()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_ANTIPANIC_ALARM] = 6;

	ObjectTester t(obj, SIGNAL(alarmsChanged()));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << qMakePair(AntintrusionAlarm::Antipanic, 6));
}

void TestAntintrusionSystem::testNoDoubleAlarms()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_ANTIPANIC_ALARM] = 6;
	obj->valueReceived(v);
	obj->valueReceived(v);
	QCOMPARE(obj->getAlarms()->getSize(), 1);
}

void TestAntintrusionSystem::testResetTechnicalAlarm()
{
	ObjectTester t(obj, SIGNAL(alarmsChanged()));

	DeviceValues v;
	v[AntintrusionDevice::DIM_TECHNICAL_ALARM] = 5;
	obj->valueReceived(v);
	t.checkSignals();

	v.clear();
	v[AntintrusionDevice::DIM_RESET_TECHNICAL_ALARM] = 5;
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getAlarms()->getSize(), 0);
}

void TestAntintrusionSystem::testClearAlarmsOnInsert()
{
	// init: not inserted and 1 alarm pending
	obj->initialized = true;
	obj->status = false;
	obj->alarms << new AntintrusionAlarm(AntintrusionAlarm::Intrusion,
		static_cast<const AntintrusionZone *>(obj->zones.getObject(0)), QDateTime::currentDateTime());

	ObjectTester t(obj, SIGNAL(alarmsChanged()));

	DeviceValues v;
	v[AntintrusionDevice::DIM_SYSTEM_INSERTED] = true;
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getAlarms()->getSize(), 0);
}

void TestAntintrusionSystem::testAlarmOnNotConfiguredZone()
{
	const char *sig = SIGNAL(alarmsChanged());

	ObjectTester t(obj, sig);
	DeviceValues v;
	v[AntintrusionDevice::DIM_INTRUSION_ALARM] = 8;
	obj->valueReceived(v);
	t.checkSignalCount(sig, 0);
}

void TestAntintrusionSystem::checkAlarmedZones(AlarmZoneList expected)
{
	AlarmZoneList actual;
	ObjectListModel *alarms = obj->getAlarms();
	for (int i = 0; i < alarms->getSize(); ++i)
	{
		AntintrusionAlarm *a = static_cast<AntintrusionAlarm *>(alarms->getObject(i));
		AntintrusionZone *z = static_cast<AntintrusionZone *>(a->getZone());
		actual << qMakePair(a->getType(), z->getObjectId());
	}

	QCOMPARE(actual, expected);
}
