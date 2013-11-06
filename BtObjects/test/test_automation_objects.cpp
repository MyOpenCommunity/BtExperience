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

#include "test_automation_objects.h"
#include "automationobjects.h"
#include "automation_device.h"
#include "objecttester.h"
#include "bt_global_config.h"

#include <QtTest>


void TestAutomation3::init()
{
	bt_global::config = new QHash<GlobalField, QString>();
	(*bt_global::config)[TS_NUMBER] = 2;

	AutomationDevice *d = new AutomationDevice("3", NOT_PULL);

	obj = new Automation3("", "", -1, d);
	dev = new AutomationDevice("3", NOT_PULL, 1);
}

void TestAutomation3::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;

	delete bt_global::config;
	bt_global::config = NULL;
}

void TestAutomation3::testUpDownStop()
{
	obj->stop();
	dev->stop();
	compareClientCommand();

	obj->goUp();
	dev->goUp();
	compareClientCommand();

	obj->goDown();
	dev->goDown();
	compareClientCommand();
}

void TestAutomation3::testSetStatus()
{
	obj->setStatus(0);
	dev->stop();
	compareClientCommand();

	obj->setStatus(1);
	dev->goUp();
	compareClientCommand();

	obj->setStatus(2);
	dev->goDown();
	compareClientCommand();
}

void TestAutomation3::testReceiveStatus()
{
	ObjectTester t(obj, SIGNAL(statusChanged()));
	DeviceValues v;

	v[AutomationDevice::DIM_UP] = true;
	obj->valueReceived(v);
	v.clear();
	t.checkSignals();
	QCOMPARE(obj->getStatus(), 1);

	v[AutomationDevice::DIM_UP] = true;
	obj->valueReceived(v);
	v.clear();
	t.checkNoSignals();
	QCOMPARE(obj->getStatus(), 1);

	v[AutomationDevice::DIM_DOWN] = true;
	obj->valueReceived(v);
	v.clear();
	t.checkSignals();
	QCOMPARE(obj->getStatus(), 2);

	v[AutomationDevice::DIM_STOP] = true;
	obj->valueReceived(v);
	v.clear();
	t.checkSignals();
	QCOMPARE(obj->getStatus(), 0);
}
