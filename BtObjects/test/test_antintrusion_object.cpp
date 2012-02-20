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
#include "antintrusionsystem.h"
#include "../devices/antintrusion_device.h"
#include "openserver_mock.h"
#include "openclient.h"
#include "objecttester.h"

#include <QtTest/QtTest>
#include <QPair>

namespace {
	QList<int> splitZones(QString zones)
	{
		QList<int> l;
		foreach(QString s, zones.split("."))
			l << s.toInt();
		return l;
	}
}

void TestAntintrusionSystem::init()
{
	AntintrusionDevice *d = new AntintrusionDevice;

	QList<QPair<int, QString> > zone_list;
	zone_list << qMakePair(1, QString("ingresso")) << qMakePair(2, QString("cucina")) << qMakePair(3, QString("box")) <<
		qMakePair(4, QString("bagno")) << qMakePair(5, QString("camera")) << qMakePair(6, QString("mansarda")) <<
		qMakePair(7, QString("giardino")) << qMakePair(8, QString("piscina"));

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
	t.checkSignalCount(SIGNAL(codeAccepted()), 1);
	t.checkSignalCount(SIGNAL(statusChanged()), 1);
}

void TestAntintrusionSystem::testPasswordFail()
{
	// system not active
	obj->initialized = true;
	obj->status = false;

	obj->toggleActivation("12345");
	DeviceValues v;
	v[AntintrusionDevice::DIM_SYSTEM_INSERTED] = false;

	ObjectTester t(obj, SignalList() << SIGNAL(codeRefused()));

	obj->valueReceived(v);
	QCOMPARE(obj->getStatus(), false);
	t.checkSignalCount(SIGNAL(codeRefused()), 1);
}
