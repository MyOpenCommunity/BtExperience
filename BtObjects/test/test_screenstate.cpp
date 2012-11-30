#include "test_screenstate.h"
#include "screenstate.h"
#include "objecttester.h"

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

void TestScreenState::testFreezeNormal()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);

	obj->startFreeze();
	QCOMPARE(obj->getState(), ScreenState::Freeze);
	QVERIFY(obj->freeze_timer->isActive());

	obj->stopFreeze();

	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->freeze_timer->isActive());
}

void TestScreenState::testFreezePasswordCheck()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::PasswordCheck);

	obj->startFreeze();
	QCOMPARE(obj->getState(), ScreenState::Freeze);
	QVERIFY(obj->freeze_timer->isActive());

	obj->stopFreeze();

	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
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

void TestScreenState::testScreenOffLockedClick()
{
	ObjectTester t(obj, SIGNAL(displayPasswordCheck()));

	obj->setPasswordEnabled(true);
	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	QVERIFY(filterClick());
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->screensaver_timer->isActive());
	t.checkSignals();
}

void TestScreenState::testFreezeLockedClick()
{
	ObjectTester t(obj, SIGNAL(displayPasswordCheck()));

	obj->setPasswordEnabled(true);
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::Freeze);
	QCOMPARE(obj->getState(), ScreenState::Freeze);

	QVERIFY(filterClick());
	QCOMPARE(obj->getState(), ScreenState::Freeze);
	QVERIFY(!obj->screensaver_timer->isActive());
	t.checkSignals();
}

void TestScreenState::testForceNormalLockedClick()
{
	ObjectTester t(obj, SIGNAL(displayPasswordCheck()));

	obj->setPasswordEnabled(true);
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::ForcedNormal);
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);

	QVERIFY(filterClick());
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);
	QVERIFY(!obj->screensaver_timer->isActive());
	t.checkSignals();
}

void TestScreenState::testPasswordCheckLockedClick()
{
	ObjectTester t(obj, SIGNAL(displayPasswordCheck()));

	obj->setPasswordEnabled(true);
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);

	QVERIFY(!filterClick());
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(obj->screensaver_timer->isActive());
	t.checkNoSignals();
}

void TestScreenState::testUnlockSequence()
{
	ObjectTester t(obj, SIGNAL(displayPasswordCheck()));

	obj->setPasswordEnabled(true);
	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	// user click

	QVERIFY(filterClick());
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->screensaver_timer->isActive());
	t.checkSignals();

	// GUI displays unlock screen

	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(obj->screensaver_timer->isActive());

	QVERIFY(!filterClick());
	QVERIFY(obj->screensaver_timer->isActive());
	t.checkNoSignals();

	// timeout -> freeze and turn off screen again

	obj->startFreeze();
	QCOMPARE(obj->getState(), ScreenState::Freeze);

	obj->stopFreeze();

	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	// user click

	QVERIFY(filterClick());
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->screensaver_timer->isActive());
	t.checkSignals();

	// GUI re-displays unlock screen

	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(obj->screensaver_timer->isActive());

	QVERIFY(!filterClick());
	QVERIFY(obj->screensaver_timer->isActive());
	t.checkNoSignals();

	// screen unlock -> normal mode

	obj->unlockScreen();
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());

	QVERIFY(!filterClick());
	QVERIFY(obj->screensaver_timer->isActive());
	t.checkNoSignals();

}
