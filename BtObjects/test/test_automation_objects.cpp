#include "test_automation_objects.h"
#include "automationobjects.h"
#include "automation_device.h"
#include "objecttester.h"
#include "main.h" // bt_global::config

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
