/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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


#ifndef TEST_DEVICE_H
#define TEST_DEVICE_H

#include <QObject>

class OpenServerMock;
class ClientWriter;
class ClientReader;
class device;


/**
 * The base class for all tests about device.
 *
 * The derived class should define tests using the following rules:
 * 1. receive* -> verify that the data structure built from the parsing of incoming frames
 *    from the server is correct.
 * 2. send* -> verify that the frame to be sent to the server is correctly created.
 * 3. test* -> tests that cannot be included in 1. & 2.
 */
class TestBtObject : public QObject
{
public:
	TestBtObject();
	void initTestSystem();
	virtual ~TestBtObject();

protected:
	void compareClientCommand(int timeout = 0);
	void compareClientRequest(int timeout = 0);
	void flushCompressedFrames(device *dev);
	void clearDeviceCache();
	void clearAllClients();

	OpenServerMock *server;
	OpenServerMock *server_compare;
	ClientWriter *client_command;
	ClientWriter *client_request;
	ClientReader *client_monitor;

	ClientWriter *client_command_compare;
	ClientWriter *client_request_compare;
};


#endif // TEST_DEVICE_H
