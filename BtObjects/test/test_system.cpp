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


#include "test_system.h"
#include "openserver_mock.h"
#include "openclient.h"
#include "device.h"

#include <frame_classes.h>

#include <QVariant>
#include <QMetaType>
#include <QDebug>
#include <QtTest>


TestBtObject::TestBtObject()
{
	// To use DeviceValues in signal/slots and watch them through QSignalSpy
	qRegisterMetaType<DeviceValues>("DeviceValues");
	server = new OpenServerMock;
	server_compare = new OpenServerMock;
}

void TestBtObject::initTestSystem()
{
	client_command = server->connectCommand();
	client_request = server->connectRequest();
	client_monitor = server->connectMonitor();

	ClientReader *mon2 = server_compare->connectMonitor();
	client_command_compare = server_compare->connectCommand();
	ClientWriter *req2 = server_compare->connectRequest();

	QHash<int, ClientReader*> monitors;
	monitors[0] = client_monitor;
	monitors[1] = mon2;
	FrameReceiver::setClientsMonitor(monitors);

	QHash<int, Clients> clients;
	clients[0].command = client_command;
	clients[1].command = client_command_compare;
	clients[0].request = client_request;
	clients[1].request = req2;
	FrameSender::setClients(clients);
}

TestBtObject::~TestBtObject()
{
	delete server;
	delete server_compare;
}

void TestBtObject::compareClientCommand()
{
	client_command->flush();
	client_command_compare->flush();
	QCOMPARE(server->frameCommand(), server_compare->frameCommand());
}
