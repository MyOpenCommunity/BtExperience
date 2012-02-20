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
	foreach(QSignalSpy *spy, spy_list)
		delete spy;
	spy_list.clear();
}


// TODO: Simplify test creation, some points to explore are:
//  - generic creation of signal spies with variable number of arguments
//  - check of emitted signals and arguments
//  - move such methods into TestSystem base class
void TestAntintrusionSystem::testActivateSystem()
{
	// system not active
	obj->initialized = true;
	obj->status = false;

	obj->toggleActivation("12345");
	client_command->flush();
	dev->toggleActivation("12345");
	client_command_compare->flush();
	QCOMPARE(server->frameCommand(), server_compare->frameCommand());

	DeviceValues v;
	v[AntintrusionDevice::DIM_SYSTEM_INSERTED] = true;
	prepareChecks(obj, QList<const char *>() << SIGNAL(codeAccepted()) << SIGNAL(statusChanged()));

	obj->valueReceived(v);
	QCOMPARE(obj->status, true);
	checkSignalCount(0, 1);
	checkSignalCount(1, 1);
}

void TestAntintrusionSystem::testPasswordFail()
{
	// system not active
	obj->initialized = true;
	obj->status = false;

	obj->toggleActivation("1234");
	dev->toggleActivation("12345");
	client_command->flush();
	client_command_compare->flush();
	QEXPECT_FAIL("", "Passwords are different", Continue);
	QCOMPARE(server->frameCommand(), server_compare->frameCommand());

	DeviceValues v;
	v[AntintrusionDevice::DIM_SYSTEM_INSERTED] = false;
	prepareChecks(obj, QList<const char *>() << SIGNAL(codeRefused()));

	obj->valueReceived(v);
	QCOMPARE(obj->status, false);
	checkSignalCount(0, 1);
}

void TestAntintrusionSystem::prepareChecks(QObject *obj, QList<const char *> sigs)
{
	foreach (const char *sig, sigs)
		spy_list << new QSignalSpy(obj, sig);
}

void TestAntintrusionSystem::checkSignalCount(int idx, int compare)
{
	QCOMPARE(spy_list.at(idx)->count(), compare);
}
