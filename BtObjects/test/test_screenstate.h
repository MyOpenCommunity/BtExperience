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

private:
	bool filterClick();

	ScreenState *obj;
};

#endif // TEST_SCREENSTATE_H
