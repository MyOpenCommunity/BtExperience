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

bool TestScreenState::filterPress()
{
	QEvent ev(QEvent::MouseButtonPress);

	return obj->eventFilter(this, &ev);
}

bool TestScreenState::filterRelease()
{
	QEvent ev(QEvent::MouseButtonRelease);

	return obj->eventFilter(this, &ev);
}

void TestScreenState::testScreensaverTimers()
{
	QCOMPARE(obj->getState(), ScreenState::Invalid);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());

	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());

	obj->enableState(ScreenState::Normal);
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());

	obj->enableState(ScreenState::Freeze);
	QCOMPARE(obj->getState(), ScreenState::Freeze);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(obj->freeze_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());

	obj->enableState(ScreenState::ForcedNormal);
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());

	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());
	QVERIFY(obj->password_timer->isActive());

	obj->enableState(ScreenState::Calibration);
	QCOMPARE(obj->getState(), ScreenState::Calibration);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->freeze_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());
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

	QVERIFY(!filterRelease());
	QCOMPARE(obj->getState(), ScreenState::Invalid);
	QVERIFY(!obj->screensaver_timer->isActive());
}

void TestScreenState::testScreenOffClick()
{
	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	QVERIFY(filterRelease());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
}

void TestScreenState::testNormalClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	QCOMPARE(obj->getState(), ScreenState::Normal);

	QVERIFY(!filterRelease());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
}

void TestScreenState::testFreezeClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::Freeze);
	QCOMPARE(obj->getState(), ScreenState::Freeze);

	QVERIFY(filterRelease());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
}

void TestScreenState::testForceNormalClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::ForcedNormal);
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);

	QVERIFY(!filterRelease());
	QCOMPARE(obj->getState(), ScreenState::ForcedNormal);
	QVERIFY(!obj->screensaver_timer->isActive());
}

void TestScreenState::testPasswordCheckClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);

	QVERIFY(!filterRelease());
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(obj->password_timer->isActive());
}

void TestScreenState::testCalibrationClick()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	obj->enableState(ScreenState::Calibration);
	QCOMPARE(obj->getState(), ScreenState::Calibration);

	QVERIFY(!filterRelease());
	QCOMPARE(obj->getState(), ScreenState::Calibration);
	QVERIFY(!obj->screensaver_timer->isActive());
}

void TestScreenState::testScreenOffLockedClick()
{
	ObjectTester t(obj, SIGNAL(displayPasswordCheck()));

	obj->setPasswordEnabled(true);
	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	QVERIFY(filterRelease());
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

	QVERIFY(filterRelease());
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

	QVERIFY(filterRelease());
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

	QVERIFY(!filterRelease());
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(obj->password_timer->isActive());
	t.checkNoSignals();
}

void TestScreenState::testUnlockSequence()
{
	ObjectTester t(obj, SIGNAL(displayPasswordCheck()));

	obj->setPasswordEnabled(true);
	obj->enableState(ScreenState::ScreenOff);
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	// user click

	QVERIFY(filterRelease());
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());
	t.checkSignals();

	// GUI displays unlock screen

	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(obj->password_timer->isActive());

	QVERIFY(!filterRelease());
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(obj->password_timer->isActive());
	t.checkNoSignals();

	// timeout -> freeze and turn off screen again

	obj->startFreeze();
	QCOMPARE(obj->getState(), ScreenState::Freeze);

	obj->stopFreeze();

	QCOMPARE(obj->getState(), ScreenState::ScreenOff);

	// user click

	QVERIFY(filterRelease());
	QCOMPARE(obj->getState(), ScreenState::ScreenOff);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());
	t.checkSignals();

	// GUI re-displays unlock screen

	obj->enableState(ScreenState::PasswordCheck);
	QCOMPARE(obj->getState(), ScreenState::PasswordCheck);
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(obj->password_timer->isActive());

	QVERIFY(!filterRelease());
	QVERIFY(!obj->screensaver_timer->isActive());
	QVERIFY(obj->password_timer->isActive());
	t.checkNoSignals();

	// screen unlock -> normal mode

	obj->unlockScreen();
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());

	QVERIFY(!filterRelease());
	QVERIFY(obj->screensaver_timer->isActive());
	QVERIFY(!obj->password_timer->isActive());
	t.checkNoSignals();
}

void TestScreenState::testNoScreensaverOnPress()
{
	obj->enableState(ScreenState::ScreenOff);
	obj->enableState(ScreenState::Normal);
	QCOMPARE(obj->getState(), ScreenState::Normal);

	QVERIFY(!filterPress());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(!obj->screensaver_timer->isActive());

	QVERIFY(!filterRelease());
	QCOMPARE(obj->getState(), ScreenState::Normal);
	QVERIFY(obj->screensaver_timer->isActive());
}
