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


Q_DECLARE_METATYPE(AntintrusionAlarm *)


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
			AlarmInfo al = l[i];
			ba += "(" + QByteArray::number(al.type) + "," + QByteArray::number(al.number) +  "," + al.name.toAscii() + "),";
		}
		ba = ba.left(ba.length() - 1) + ")";
		return qstrdup(ba.data());
	}
}


void TestAntintrusionSystem::initTestCase()
{
	qRegisterMetaType<AntintrusionAlarm *>();
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
		zones << new AntintrusionZone(zone_list.at(i).first, zone_list.at(i).second);

	QList<AntintrusionScenario *> scenarios;
	scenarios << new AntintrusionScenario("notte", splitZones("1.3.5"), zones) <<
		new AntintrusionScenario("inverno", splitZones("1.2.3"), zones) <<
		new AntintrusionScenario("estate", splitZones("4.5.7"), zones);

	QList<AntintrusionAlarmSource *> aux;
	aux << new AntintrusionAlarmSource(5, "fire") <<
		new AntintrusionAlarmSource(12, "freezer");

	obj = new AntintrusionSystem(d, scenarios, aux, zones);
	dev = new AntintrusionDevice(1);
	foreach (AntintrusionZone *z, zones)
		dev->partializeZone(z->getNumber(), !z->getSelected());
}

void TestAntintrusionSystem::cleanup()
{
	// TODO: AntintrusionSystem doesn't have a proper dtor...
	delete obj->dev;
	delete obj;
	delete dev;
}

void TestAntintrusionSystem::compareClientCommand()
{
	flushCompressedFrames(dev);
	flushCompressedFrames(obj->dev);
	TestBtObject::compareClientCommand();
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
	setSystemActive(false);

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
	setSystemActive(false);

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

	ObjectTester t(obj, SIGNAL(newAlarm(AntintrusionAlarm *)));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << AlarmInfo(AntintrusionAlarm::Intrusion, 2, "cucina"));
}

void TestAntintrusionSystem::testTamperingAlarm()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_TAMPER_ALARM] = 12;

	ObjectTester t(obj, SIGNAL(newAlarm(AntintrusionAlarm *)));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << AlarmInfo(AntintrusionAlarm::Tamper, 12, ""));

	v[AntintrusionDevice::DIM_TAMPER_ALARM] = 2;
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << AlarmInfo(AntintrusionAlarm::Tamper, 12, "") << AlarmInfo(AntintrusionAlarm::Tamper, 2, "cucina"));
}

void TestAntintrusionSystem::testTechnicalAlarm()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_TECHNICAL_ALARM] = 12;

	ObjectTester t(obj, SIGNAL(newAlarm(AntintrusionAlarm *)));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << AlarmInfo(AntintrusionAlarm::Technical, 12, "freezer"));
}

void TestAntintrusionSystem::testAntipanicAlarm()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_ANTIPANIC_ALARM] = 9;

	ObjectTester t(obj, SIGNAL(newAlarm(AntintrusionAlarm *)));
	obj->valueReceived(v);
	t.checkSignals();
	checkAlarmedZones(AlarmZoneList() << AlarmInfo(AntintrusionAlarm::Antipanic, 9, ""));

	v[AntintrusionDevice::DIM_ANTIPANIC_ALARM] = 2;

	obj->valueReceived(v);
	t.checkNoSignals();
	checkAlarmedZones(AlarmZoneList() << AlarmInfo(AntintrusionAlarm::Antipanic, 9, ""));
}

void TestAntintrusionSystem::testNoDoubleAlarms()
{
	DeviceValues v;
	v[AntintrusionDevice::DIM_ANTIPANIC_ALARM] = 9;
	obj->valueReceived(v);
	obj->valueReceived(v);
	QCOMPARE(obj->getAlarms()->getCount(), 1);
}

void TestAntintrusionSystem::testResetTechnicalAlarm()
{
	ObjectTester t(obj, SIGNAL(newAlarm(AntintrusionAlarm *)));

	DeviceValues v;
	v[AntintrusionDevice::DIM_TECHNICAL_ALARM] = 12;
	obj->valueReceived(v);
	t.checkSignals();
	QCOMPARE(obj->getAlarms()->getCount(), 1);

	v.clear();
	v[AntintrusionDevice::DIM_RESET_TECHNICAL_ALARM] = 12;
	obj->valueReceived(v);
	t.checkNoSignals();
	QCOMPARE(obj->getAlarms()->getCount(), 0);

	obj->valueReceived(v);
	t.checkNoSignals();
	QCOMPARE(obj->getAlarms()->getCount(), 0);
}

void TestAntintrusionSystem::testClearAlarmsOnInsert()
{
	// init: not inserted and 1 alarm pending
	setSystemActive(false);
	obj->alarms << new AntintrusionAlarm(AntintrusionAlarm::Intrusion,
		static_cast<const AntintrusionZone *>(obj->zones.getObject(0)), 1, QDateTime::currentDateTime());

	ObjectTester t(obj, SIGNAL(newAlarm(AntintrusionAlarm *)));

	DeviceValues v;
	v[AntintrusionDevice::DIM_SYSTEM_INSERTED] = true;
	obj->valueReceived(v);
	t.checkNoSignals();
	QCOMPARE(obj->getAlarms()->getCount(), 0);
}

void TestAntintrusionSystem::testAlarmOnNotConfiguredZone()
{
	const char *sig = SIGNAL(newAlarm(AntintrusionAlarm *));

	ObjectTester t(obj, sig);
	DeviceValues v;
	v[AntintrusionDevice::DIM_INTRUSION_ALARM] = 8;
	obj->valueReceived(v);
	t.checkSignalCount(sig, 0);
	QCOMPARE(obj->getAlarms()->getCount(), 0);
}

void TestAntintrusionSystem::testTechnicalAlarmOnNotConfiguredZone()
{
	const char *sig = SIGNAL(newAlarm(AntintrusionAlarm *));

	ObjectTester t(obj, sig);
	DeviceValues v;
	v[AntintrusionDevice::DIM_TECHNICAL_ALARM] = 13;
	obj->valueReceived(v);
	t.checkSignalCount(sig, 0);
	QCOMPARE(obj->getAlarms()->getCount(), 0);
}

void TestAntintrusionSystem::testModifyPartializationWithRightCode()
{
	setSystemActive(false);
	setZonesInserted();
	unselectFirstTwoZones();

	// some cleanup
	clearAllClients();

	// partialization request
	obj->requestPartialization("12345");

	// what we expect
	dev->partializeZone(1, true);
	dev->partializeZone(2, true);
	dev->sendPartializationFrame("12345");

	// checks everything is fine
	compareClientCommand();

	checkWaitingResponse(true);

	ObjectTester t(obj, SIGNAL(codeAccepted()));

	// now, first 2 zones are partialized
	DeviceValues v;
	for (int i = 1; i <= 7; ++i)
	{
		int k = AntintrusionDevice::DIM_ZONE_INSERTED;
		if (i <= 2)
			k = AntintrusionDevice::DIM_ZONE_PARTIALIZED;
		v[k] = i;
		obj->valueReceived(v);
		v.clear();
	}

	// checks first 2 zones are really partialized
	ObjectDataModel *zones = obj->getZones();
	for (int i = 0; i < 7; ++i)
	{
		AntintrusionZone *z = static_cast<AntintrusionZone *>(zones->getObject(i));
		bool actual = z->getSelected();
		bool expected = ((i + 1) <= 2) ? false : true;
		QString msg = QString("Zone %1 - Actual partialization: %2 Expected partialization: %3").arg(i + 1).arg(actual).arg(expected);
		QVERIFY2(expected == actual, qPrintable(msg));
	}

	t.checkSignals();
}

void TestAntintrusionSystem::testModifyPartializationWithWrongCode()
{
	setSystemActive(false);
	setZonesInserted();
	unselectFirstTwoZones();

	obj->requestPartialization("11111");

	ObjectTester t(obj, SIGNAL(codeRefused()));

	checkWaitingResponse(true);

	// all zones are inserted (simulates wrong code)
	DeviceValues v;
	for (int i = 1; i <= 7; ++i)
	{
		int k = AntintrusionDevice::DIM_ZONE_INSERTED;
		v[k] = i;
		obj->valueReceived(v);
		v.clear();
	}

	// checks all zones are inserted
	ObjectDataModel *zones = obj->getZones();
	for (int i = 0; i < 7; ++i)
	{
		AntintrusionZone *z = static_cast<AntintrusionZone *>(zones->getObject(i));
		bool actual = z->getSelected();
		bool expected = true;
		QString msg = QString("Zone %1 - Actual partialization: %2 Expected partialization: %3").arg(i + 1).arg(actual).arg(expected);
		QVERIFY2(expected == actual, qPrintable(msg));
	}

	t.checkSignals();
}

void TestAntintrusionSystem::testPartializationWithoutModification()
{
	setSystemActive(false);
	setZonesInserted();

	// in reality we want to check that no signal is emitted, but ObjectTester
	// ctor wants a signal so we pass it a random one
	ObjectTester t(obj, SIGNAL(codeRefused()));

	obj->requestPartialization("11111");

	checkWaitingResponse(false);

	t.checkNoSignals();
}

void TestAntintrusionSystem::testPartializationWithSystemInserted()
{
	setSystemActive(true);
	setZonesInserted();
	unselectFirstTwoZones();

	// in reality we want to check that no signal is emitted, but ObjectTester
	// ctor wants a signal so we pass it a random one
	ObjectTester t(obj, SIGNAL(codeRefused()));

	obj->requestPartialization("11111");

	checkWaitingResponse(false);

	t.checkNoSignals();
}

void TestAntintrusionSystem::checkAlarmedZones(AlarmZoneList expected)
{
	AlarmZoneList actual;
	ObjectDataModel *alarms = obj->getAlarms();
	for (int i = 0; i < alarms->getCount(); ++i)
	{
		AntintrusionAlarm *a = static_cast<AntintrusionAlarm *>(alarms->getObject(i));
		actual << AlarmInfo(a->getType(), a->getNumber(), a->getName());
	}

	QCOMPARE(actual, expected);
}

void TestAntintrusionSystem::setSystemActive(bool active)
{
	obj->initialized = true;
	obj->status = active;
	obj->waiting_response = false;
}

void TestAntintrusionSystem::setZonesInserted()
{
	DeviceValues v;
	for (int i = 1; i <= 7; ++i)
	{
		v[AntintrusionDevice::DIM_ZONE_INSERTED] = i;
		obj->valueReceived(v);
		v.clear();
	}
}

void TestAntintrusionSystem::unselectFirstTwoZones()
{
	ObjectDataModel *zones = obj->getZones();
	for (int i = 0; i < 2; ++i)
	{
		AntintrusionZone *z = static_cast<AntintrusionZone *>(zones->getObject(i));
		z->setSelected(false);
	}
}

void TestAntintrusionSystem::checkWaitingResponse(bool waiting_response)
{
	QString msg = QString("Waiting response value (%1) is not as expected (%2)").arg(obj->waiting_response).arg(waiting_response);
	QVERIFY2(waiting_response == obj->waiting_response, qPrintable(msg));
}
