#ifndef TEST_ALARM_CLOCK_H
#define TEST_ALARM_CLOCK_H

#include "test_btobject.h"

class AlarmClock;
class AmplifierDevice;
class SourceDevice;
class Amplifier;
class SourceObject;
class ObjectDataModel;


class TestAlarmClockBeep : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testStart();
	void testStop();
	void testPostpone();
	void testRestart();
	void testRestartExpired();

	void testFirstTick();
	void testTick();
	void testLastTick();

private:
	AlarmClock *obj;
};


class TestAlarmClockSoundDiffusion : public TestBtObject
{
	Q_OBJECT

private slots:
	void initTestCase();
	void cleanupTestCase();

	void init();
	void cleanup();

	void testStart();
	void testStop();
	void testPostpone();
	void testRestart();
	void testRestartExpired();

	void testFirstTick();
	void testTick();
	void testLastTick();

private:
	ObjectDataModel *dummy;
	AlarmClock *obj;
	QList<AmplifierDevice *> amplifier_dev;
	SourceDevice *source_dev;
	QList<Amplifier *> amplifiers;
	SourceObject *source;
};

#endif // TEST_ALARM_CLOCK_H
