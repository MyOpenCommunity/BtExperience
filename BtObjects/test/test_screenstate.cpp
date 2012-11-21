#include "test_screenstate.h"
#include "screenstate.h"

#include <QMouseEvent>
#include <QtTest>


void TestScreenState::init()
{
	obj = new ScreenState();
}

void TestScreenState::cleanup()
{
	delete obj;
}

bool TestScreenState::filterClick()
{
	QEvent ev(QEvent::MouseButtonPress);

	return obj->eventFilter(this, &ev);
}

void TestScreenState::testScreensaverTimers()
{
	QCOMPARE(obj->getState(), ScreenState::Invalid);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());

	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());

	obj->enableState(ScreenState::Normal);
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());

	obj->enableState(ScreenState::Freeze);
	QCOMPARE(obj->getState(), ScreenState::Freeze);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(obj->freeze_timer->isActive());

	obj->enableState(ScreenState::ForcedNormal);
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());

	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());

	obj->enableState(ScreenState::Calibration);
	QCOMPARE(obj->getState(), ScreenState::Calibration);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());
}

void TestScreenState::testFreeze()
{
	const int max_ticks = 10000; // arbitrary high number

	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->freeze_tick = 2;

	obj->startFreeze();
	QCOMPARE(obj->getState(), ScreenState::Freeze);
	QCOMPARE(obj->freeze_tick, 0);
	QVERIFY(obj->freeze_timer->isActive());

	int i;
	for (i = 0; i < max_ticks && obj->getState() == ScreenState::Freeze; ++i)
		obj->freezeTick();

	QVERIFY(i != max_ticks);
	QCOMPARE((int)obj->getState(), (int)ScreenState::ScreenOff);
	QVERIFY(!obj->freeze_timer->isActive());
}

void TestScreenState::testInvalidClick()
{
	QCOMPARE(obj->getState(), ScreenState::Invalid);

	QVERIFY(!filterClick());
	QCOMPARE(obj->getState(), ScreenState::Invalid);
	QVERIFY(!obj->screensaver_timer->isActive());
}

void TestScreenState::testScreenOffClick()
{
	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	QVERIFY(filterClick());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
}

void TestScreenState::testNormalClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	QCOMPARE(obj->getState(), ScreenState::Normal);

	QVERIFY(!filterClick());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
}

void TestScreenState::testFreezeClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::Freeze);
	QCOMPARE(obj->getState(), ScreenState::Freeze);

	QVERIFY(filterClick());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
}

void TestScreenState::testForceNormalClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::ForcedNormal);
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);

	QVERIFY(!filterClick());
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);
	QVERIFY(!obj->screensaver_timer->isActive());
}

void TestScreenState::testPasswordCheckClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);

	QVERIFY(!filterClick());
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(obj->screensaver_timer->isActive());
}

void TestScreenState::testCalibrationClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::Calibration);
	QCOMPARE(obj->getState(), ScreenState::Calibration);

	QVERIFY(!filterClick());
	QCOMPARE(obj->getState(), ScreenState::Calibration);
	QVERIFY(!obj->screensaver_timer->isActive());
}
