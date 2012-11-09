#include "test_alarm_clock.h"

#include "media_device.h"
#include "mediaobjects.h"
#include "alarmclock.h"

#include <QtTest>


void TestAlarmClockSoundDiffusion::init()
{
	amplifier_dev.append(AmplifierDevice::createDevice("11", 1));
	amplifier_dev.append(AmplifierDevice::createDevice("12", 1));
	amplifier_dev.append(AmplifierDevice::createDevice("21", 1));
	amplifier_dev.append(AmplifierDevice::createDevice("31", 1));
	source_dev = new SourceDevice("3", 1);

	amplifiers.append(new Amplifier(1, "", AmplifierDevice::createDevice("11")));
	amplifiers.append(new Amplifier(1, "", AmplifierDevice::createDevice("12")));
	amplifiers.append(new Amplifier(2, "", AmplifierDevice::createDevice("21")));
	amplifiers.append(new Amplifier(3, "", AmplifierDevice::createDevice("31")));
	source = new SourceObject("", new SourceAux(new SourceDevice("3")), SourceObject::Aux);

	obj = new AlarmClock("", false, AlarmClock::AlarmClockBeep, 0, 0, 0);
	obj->setVolume(8);
	obj->setSource(source);
	obj->setAmplifier(amplifiers[1]);
}

void TestAlarmClockSoundDiffusion::cleanup()
{
	delete source_dev;
	delete obj;
}

void TestAlarmClockSoundDiffusion::testStart()
{
	obj->setAlarmType(AlarmClock::AlarmClockSoundSystem);
	obj->tick_count = 0;
	obj->alarmTick();

	source_dev->turnOn("0");
	source_dev->turnOn("1");
	amplifier_dev[1]->setVolume(0);
	amplifier_dev[1]->turnOn();

	compareClientCommand();
}

void TestAlarmClockSoundDiffusion::testTick()
{
	obj->setAlarmType(AlarmClock::AlarmClockSoundSystem);
	obj->tick_count = 10;
	obj->alarmTick();

	amplifier_dev[1]->setVolume(10);

	compareClientCommand();
}

void TestAlarmClockSoundDiffusion::testStop()
{
	obj->setAlarmType(AlarmClock::AlarmClockSoundSystem);
	obj->tick_count = 39;
	obj->alarmTick();

	amplifier_dev[1]->turnOff();

	compareClientCommand();
}
