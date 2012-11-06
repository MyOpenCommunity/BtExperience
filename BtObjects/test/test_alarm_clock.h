#ifndef TEST_ALARM_CLOCK_H
#define TEST_ALARM_CLOCK_H

#include "test_btobject.h"

class AlarmClock;
class AmplifierDevice;
class SourceDevice;
class Amplifier;
class SourceObject;


class TestAlarmClockSoundDiffusion : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testEnableDisableAmplifier();

	void testStart();
	void testTick();
	void testStop();

private:
	AlarmClock *obj;
	QList<AmplifierDevice *> amplifier_dev;
	SourceDevice *source_dev;
	QList<Amplifier *> amplifiers;
	SourceObject *source;
};

#endif // TEST_ALARM_CLOCK_H
