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

#ifndef TEST_STOPANDGO_OBJECTS_H
#define TEST_STOPANDGO_OBJECTS_H

#include "test_btobject.h"

#include <QObject>

class StopAndGo;
class StopAndGoPlus;
class StopAndGoBTest;
class StopAndGoDevice;
class StopAndGoPlusDevice;
class StopAndGoBTestDevice;


class TestStopAndGo : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(StopAndGoDevice *dev, StopAndGo *obj);

private slots:
	void initTestCase();
	void init();
	void cleanup();

	void testSendAutoReset();

	void testReceiveStatus();
	void testReceiveAutoReset();

private:
	StopAndGo *obj;
	StopAndGoDevice *dev;
};


class TestStopAndGoPlus : public TestStopAndGo
{
	Q_OBJECT

private slots:
	void init();

	void testSendDiagnostic();

	void testReceiveDiagnostic();

private:
	StopAndGoPlus *obj;
	StopAndGoPlusDevice *dev;
};


class TestStopAndGoBTest : public TestStopAndGo
{
	Q_OBJECT

private slots:
	void init();

	void testSendAutoTest();
	void testSendAutoTestFrequency();

	void testReceiveAutoTest();
	void testReceiveAutoTestFrequency();

private:
	StopAndGoBTest *obj;
	StopAndGoBTestDevice *dev;
};

#endif // TEST_STOPANDGO_OBJECTS_H
