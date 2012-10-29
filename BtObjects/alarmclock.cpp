#include "alarmclock.h"
#include "mediamodel.h"
#include "mediaobjects.h"
#include "xml_functions.h"
#include "xmlobject.h"


#include <QFile>
#include <QtDebug>
#include <QTimer>


namespace
{
	// based on old touchscreen code, days bits are as follows:
	// mtwtfss, with least significant bit to be sundays and
	// more significant bit to be mondays
	const int MASK_MONDAY = 0x40;
	const int MASK_TUESDAY = 0x20;
	const int MASK_WEDNESDAY = 0x10;
	const int MASK_THURSDAY = 0x8;
	const int MASK_FRIDAY = 0x4;
	const int MASK_SATURDAY = 0x2;
	const int MASK_SUNDAY = 0x1;

	const int SOUND_DIFFUSION_INTERVAL = 3000;
	const int MAX_SOUND_DIFFUSION_TICK = 39;
}


QList<ObjectPair> parseAlarmClocks(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	QString def_descr = getAttribute(xml_node, "descr", "Alarm clock");
	int def_enabled = getIntAttribute(xml_node, "enabled", 0);
	int def_type = getIntAttribute(xml_node, "type", 0);
	int def_days = getIntAttribute(xml_node, "days", 0);
	int def_hour = getIntAttribute(xml_node, "hour", 0);
	int def_minutes = getIntAttribute(xml_node, "minutes", 0);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);

		int uii = getIntAttribute(ist, "uii");

		QString descr = getAttribute(ist, "descr", def_descr);
		int enabled = getIntAttribute(ist, "enabled", def_enabled);
		int type = getIntAttribute(ist, "type", def_type);
		int days = getIntAttribute(ist, "days", def_days);
		int hour = getIntAttribute(ist, "hour", def_hour);
		int minutes = getIntAttribute(ist, "minutes", def_minutes);

		obj_list << ObjectPair(uii, new AlarmClock(descr, enabled != 0, type, days, hour, minutes));
	}
	return obj_list;
}

void updateAlarmClocks(QDomNode node, AlarmClock *alarmClock)
{
	setAttribute(node, "descr", alarmClock->getDescription());
	setAttribute(node, "enabled", QString::number(alarmClock->isEnabled()));
	setAttribute(node, "type", QString::number(alarmClock->getAlarmType()));
	setAttribute(node, "days", QString::number(alarmClock->getDays()));
	setAttribute(node, "hour", QString::number(alarmClock->getHour()));
	setAttribute(node, "minutes", QString::number(alarmClock->getMinute()));
}

AlarmClock::AlarmClock(QString _description, bool _enabled, int _type, int _days, int _hour, int _minute, QObject *parent)
	: ObjectInterface(parent)
{
	timer_trigger = new QTimer(this);
	description = _description;
	switch(_type)
	{
	case 1:
		alarm_type = AlarmClockSoundSystem;
		break;
	default:
		alarm_type = AlarmClockBeep;
		break;
	}
	days = _days;
	hour = _hour;
	minute = _minute;
	enabled = false; // starting from a well known state
	source = 0;
	volume = 0;
	tick_count = 0;
	tick = new QTimer(this);

	connect(this, SIGNAL(alarmTypeChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(checkRequested()), this, SLOT(checkRequestManagement()));
	connect(this, SIGNAL(daysChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(enabledChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(hourChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(minuteChanged()), this, SIGNAL(persistItem()));

	connect(timer_trigger, SIGNAL(timeout()), this, SLOT(triggersIfHasTo()));
	connect(tick, SIGNAL(timeout()), this, SLOT(alarmTick()));

	connect(this, SIGNAL(enabledChanged()), this, SIGNAL(checkRequested()));
	connect(this, SIGNAL(daysChanged()), this, SIGNAL(checkRequested()));
	connect(this, SIGNAL(hourChanged()), this, SIGNAL(checkRequested()));
	connect(this, SIGNAL(minuteChanged()), this, SIGNAL(checkRequested()));

	setEnabled(_enabled); // sets real value
}

void AlarmClock::checkRequestManagement()
{
	if (enabled)
	{
		// gets actual date&time
		QDateTime actualDateTime = QDateTime::currentDateTime();

		// gets triggering date&time
		QDateTime triggeringDateTime = QDateTime(actualDateTime.date(), QTime(hour, minute));

		// computes difference in seconds between actual and candidate date&time
		int deltaSeconds = actualDateTime.secsTo(triggeringDateTime);

		// if difference is not positive adds 1 day to triggering date&time and recomputes delta
		if (deltaSeconds <= 0)
			deltaSeconds = actualDateTime.secsTo(triggeringDateTime.addDays(1));

		// finally, sets trigger timer
		timer_trigger->setSingleShot(true);
		timer_trigger->start(deltaSeconds * 1000);
	}
	else
	{
		timer_trigger->stop();
	}
}

void AlarmClock::triggersIfHasTo()
{
	if (days == 0)
	{
		// once alarm: ring and disable
		start();
		setEnabled(false);
		return;
	}

	// computes day of week (1 = Monday .. 7 = Sunday)
	int weekday = QDateTime::currentDateTime().date().dayOfWeek();

	// checks if it is a trigger day
	bool isTriggerDay = false;
	isTriggerDay = isTriggerDay || (isTriggerOnMondays() && (weekday == 1));
	isTriggerDay = isTriggerDay || (isTriggerOnTuesdays() && (weekday == 2));
	isTriggerDay = isTriggerDay || (isTriggerOnWednesdays() && (weekday == 3));
	isTriggerDay = isTriggerDay || (isTriggerOnThursdays() && (weekday == 4));
	isTriggerDay = isTriggerDay || (isTriggerOnFridays() && (weekday == 5));
	isTriggerDay = isTriggerDay || (isTriggerOnSaturdays() && (weekday == 6));
	isTriggerDay = isTriggerDay || (isTriggerOnSundays() && (weekday == 7));

	// eventually rings
	if (isTriggerDay)
		start();

	// reloads timer
	emit checkRequested();
}

void AlarmClock::start()
{
	tick_count = 0;
	if (alarm_type == AlarmClockBeep)
		; // TODO
	else
		tick->setInterval(SOUND_DIFFUSION_INTERVAL);
	tick->start();
	emit ringMe(this);
}

void AlarmClock::stop()
{
	// TODO stops alarm if ringing
	qDebug() << __PRETTY_FUNCTION__;
	qDebug() << "+++++++++++++++++++++++++++++++++++++++++++++++ Alarm stopped";
	tick->stop();
}

void AlarmClock::postpone()
{
	// TODO postpones alarm if ringing
	qDebug() << __PRETTY_FUNCTION__;
	qDebug() << "+++++++++++++++++++++++++++++++++++++++++++++++ Alarm postponed";
}

void AlarmClock::setDescription(QString newValue)
{
	if (description == newValue)
		return;

	description = newValue;
	emit descriptionChanged();
}

void AlarmClock::setEnabled(bool newValue)
{
	if (enabled == newValue)
		return;

	enabled = newValue;
	emit enabledChanged();
}

void AlarmClock::setAlarmType(AlarmClockType newValue)
{
	if (alarm_type == newValue)
		return;

	alarm_type = newValue;
	emit alarmTypeChanged();
}

void AlarmClock::setDays(int newValue)
{
	if (days == newValue || newValue < 0 || newValue > 0x7F)
		return;

	days = newValue;
	emit daysChanged();
}

void AlarmClock::setHour(int newValue)
{
	if (hour == newValue || newValue < 0 || newValue > 23)
		return;

	hour = newValue;
	emit hourChanged();
}

void AlarmClock::setMinute(int newValue)
{
	if (minute == newValue || newValue < 0 || newValue > 59)
		return;

	minute = newValue;
	emit minuteChanged();
}

bool AlarmClock::isTriggerOnMondays() const
{
	return ((days & MASK_MONDAY) > 0);
}

bool AlarmClock::isTriggerOnTuesdays() const
{
	return ((days & MASK_TUESDAY) > 0);
}

bool AlarmClock::isTriggerOnWednesdays() const
{
	return ((days & MASK_WEDNESDAY) > 0);
}

bool AlarmClock::isTriggerOnThursdays() const
{
	return ((days & MASK_THURSDAY) > 0);
}

bool AlarmClock::isTriggerOnFridays() const
{
	return ((days & MASK_FRIDAY) > 0);
}

bool AlarmClock::isTriggerOnSaturdays() const
{
	return ((days & MASK_SATURDAY) > 0);
}

bool AlarmClock::isTriggerOnSundays() const
{
	return ((days & MASK_SUNDAY) > 0);
}

void AlarmClock::setTriggerOnMondays(bool newValue)
{
	setTriggerOnWeekdays(newValue, MASK_MONDAY);
}

void AlarmClock::setTriggerOnTuesdays(bool newValue)
{
	setTriggerOnWeekdays(newValue, MASK_TUESDAY);
}

void AlarmClock::setTriggerOnWednesdays(bool newValue)
{
	setTriggerOnWeekdays(newValue, MASK_WEDNESDAY);
}

void AlarmClock::setTriggerOnThursdays(bool newValue)
{
	setTriggerOnWeekdays(newValue, MASK_THURSDAY);
}

void AlarmClock::setTriggerOnFridays(bool newValue)
{
	setTriggerOnWeekdays(newValue, MASK_FRIDAY);
}

void AlarmClock::setTriggerOnSaturdays(bool newValue)
{
	setTriggerOnWeekdays(newValue, MASK_SATURDAY);
}

void AlarmClock::setTriggerOnSundays(bool newValue)
{
	setTriggerOnWeekdays(newValue, MASK_SUNDAY);
}

void AlarmClock::setTriggerOnWeekdays(bool newValue, int dayMask)
{
	int old_days = days;

	if (newValue) // set
		old_days |= dayMask;
	else // reset
		old_days &= ~dayMask;

	if (old_days == days)
		return;

	setDays(old_days);
}

void AlarmClock::alarmTick()
{
	++tick_count;

	if (alarm_type == AlarmClockBeep)
	{
		// TODO
	}
	else
	{
		if (tick_count == 0)
		{
			bool areas[9];

			memset(areas, 0, sizeof(areas));
			source->setActive(0);
			areas[0] = true;

			foreach (Amplifier *a, enabled_amplifiers)
			{
				int area = a->getArea();

				if (!areas[area])
				{
					source->setActive(area);
					areas[area] = true;
				}
			}
		}

		if (tick_count == MAX_SOUND_DIFFUSION_TICK)
		{
			soundDiffusionStop();
			tick->stop();
		}
		else
			soundDiffusionSetVolume();
	}
}

void AlarmClock::soundDiffusionStop()
{
	foreach (Amplifier *a, enabled_amplifiers)
		a->setActive(false);
}

void AlarmClock::soundDiffusionSetVolume()
{
	int real_volume = 32 * volume / 100;

	foreach (Amplifier *a, enabled_amplifiers)
	{
		if (tick_count <= real_volume)
			a->setVolume(tick_count);
		if (tick_count == 0)
			a->setActive(true);
	}
}

void AlarmClock::setAmplifierEnabled(Amplifier *amplifier, bool enabled)
{
	if (!enabled && enabled_amplifiers.contains(amplifier))
		enabled_amplifiers.remove(amplifier);
	else if (enabled && !enabled_amplifiers.contains(amplifier))
		enabled_amplifiers.insert(amplifier);
}

bool AlarmClock::isAmplifierEnabled(Amplifier *amplifier) const
{
	return enabled_amplifiers.contains(amplifier);
}

void AlarmClock::setSource(SourceObject *_source)
{
	if (_source == source)
		return;

	source = _source;
	emit sourceChanged();
}

SourceObject *AlarmClock::getSource() const
{
	return source;
}

void AlarmClock::setVolume(int _volume)
{
	if (_volume == volume)
		return;

	volume = _volume;
	emit volumeChanged();
}

int AlarmClock::getVolume() const
{
	return volume;
}
