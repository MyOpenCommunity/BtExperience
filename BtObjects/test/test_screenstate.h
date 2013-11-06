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

#ifndef TEST_SCREENSTATE_H
#define TEST_SCREENSTATE_H

#include "test_btobject.h"

class ScreenState;


class TestScreenState : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testScreensaverTimers();
	void testFreezeNormal();
	void testFreezePasswordCheck();

	void testInvalidClick();
	void testScreenOffClick();
	void testNormalClick();
	void testFreezeClick();
	void testForceNormalClick();
	void testPasswordCheckClick();
	void testCalibrationClick();

	void testScreenOffLockedClick();
	void testFreezeLockedClick();
	void testForceNormalLockedClick();
	void testPasswordCheckLockedClick();

	void testUnlockSequence();
	void testNoScreensaverOnPress();

private:
	bool filterRelease();
	bool filterPress();

	ScreenState *obj;
};

#endif // TEST_SCREENSTATE_H
