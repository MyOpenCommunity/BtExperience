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

	const int ALARM_TIME = 120;
	const int POSTPONE_TIME = 5 * 60;
	const int MAX_TIME = 30 * 60;

	const int BEEP_INTERVAL = 5000;

	const int SOUND_DIFFUSION_INTERVAL = 3000;
}


QList<ObjectPair> parseAlarmClocks(const QDomNode &xml_node, QList<SourceObject *> sources, const UiiMapper &uii_map)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		AlarmClock *alarm = new AlarmClock(v.value("descr"), v.intValue("enabled"), v.intValue("type"),
						   v.intValue("days"), v.intValue("hour"), v.intValue("minutes"));

		if (alarm->getAlarmType() == AlarmClock::AlarmClockSoundSystem)
		{
			alarm->setVolume(v.intValue("volume"));
			alarm->setAmplifier(uii_map.value<Amplifier>(v.intValue("amplifier_uii")));

			SourceObject::SourceObjectType source_type;

			switch (v.intValue("source_type"))
			{
			case 0:
				source_type = SourceObject::Aux;
				break;
			case 1:
				source_type = SourceObject::RdsRadio;
				break;
			case 2:
				source_type = SourceObject::IpRadio;
				break;
			case 3:
				source_type = SourceObject::Sd;
				break;
			case 4:
				source_type = SourceObject::Usb;
				break;
			default:
				qFatal("Invalid source type for alarm clock");
			}

			foreach (SourceObject *source, sources)
			{
				if (source->getSourceType() == source_type)
				{
					alarm->setSource(source);
					break;
				}
			}
		}

		obj_list << ObjectPair(uii, alarm);
	}
	return obj_list;
}

void updateAlarmClocks(QDomNode node, AlarmClock *alarm_clock, const UiiMapper &uii_map)
{
	setAttribute(node, "descr", alarm_clock->getDescription());
	setAttribute(node, "enabled", QString::number(alarm_clock->isEnabled()));
	setAttribute(node, "type", QString::number(alarm_clock->getAlarmType()));
	setAttribute(node, "days", QString::number(alarm_clock->getDays()));
	setAttribute(node, "hour", QString::number(alarm_clock->getHour()));
	setAttribute(node, "minutes", QString::number(alarm_clock->getMinute()));

	if (alarm_clock->getAlarmType() == AlarmClock::AlarmClockSoundSystem)
	{
		setAttribute(node, "volume", QString::number(alarm_clock->getVolume()));
		setAttribute(node, "amplifier_uii", QString::number(uii_map.findUii(alarm_clock->getAmplifier())));

		int type;
		switch (alarm_clock->getSource()->getSourceType())
		{
		case SourceObject::Aux:
			type = 0;
			break;
		case SourceObject::RdsRadio:
			type = 1;
			break;
		case SourceObject::IpRadio:
			type = 2;
			break;
		case SourceObject::Sd:
			type = 3;
			break;
		case SourceObject::Usb:
			type = 4;
			break;
		default:
			qFatal("Invalid source object");
		}

		setAttribute(node, "source_type", QString::number(type));
	}
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
	amplifier = 0;
	volume = 0;
	tick_count = 0;
	timer_tick = new QTimer(this);

	timer_postpone = new QTimer(this);
	timer_postpone->setSingleShot(true);
	timer_postpone->setInterval(POSTPONE_TIME * 1000);

	connect(this, SIGNAL(alarmTypeChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(checkRequested()), this, SLOT(checkRequestManagement()));
	connect(this, SIGNAL(daysChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(enabledChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(hourChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(minuteChanged()), this, SIGNAL(persistItem()));

	connect(timer_trigger, SIGNAL(timeout()), this, SLOT(triggersIfHasTo()));
	connect(timer_tick, SIGNAL(timeout()), this, SLOT(alarmTick()));
	connect(timer_postpone, SIGNAL(timeout()), this, SLOT(restart()));

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
		QDateTime actual_date_time = QDateTime::currentDateTime();

		// gets triggering date&time
		QDateTime triggering_date_time = QDateTime(actual_date_time.date(), QTime(hour, minute));

		// computes difference in seconds between actual and candidate date&time
		int delta_seconds = actual_date_time.secsTo(triggering_date_time);

		// if difference is not positive adds 1 day to triggering date&time and recomputes delta
		if (delta_seconds <= 0)
			delta_seconds = actual_date_time.secsTo(triggering_date_time.addDays(1));

		// finally, sets trigger timer
		timer_trigger->setSingleShot(true);
		timer_trigger->start(delta_seconds * 1000);
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
	bool is_trigger_day = false;
	is_trigger_day = is_trigger_day || (isTriggerOnMondays() && (weekday == 1));
	is_trigger_day = is_trigger_day || (isTriggerOnTuesdays() && (weekday == 2));
	is_trigger_day = is_trigger_day || (isTriggerOnWednesdays() && (weekday == 3));
	is_trigger_day = is_trigger_day || (isTriggerOnThursdays() && (weekday == 4));
	is_trigger_day = is_trigger_day || (isTriggerOnFridays() && (weekday == 5));
	is_trigger_day = is_trigger_day || (isTriggerOnSaturdays() && (weekday == 6));
	is_trigger_day = is_trigger_day || (isTriggerOnSundays() && (weekday == 7));

	// eventually rings
	if (is_trigger_day)
		start();

	// reloads timer
	emit checkRequested();
}

void AlarmClock::restart()
{
	if (isRinging())
		return;
	if (start_time.secsTo(QTime::currentTime()) <= MAX_TIME)
		startRinging();
}

void AlarmClock::start()
{
	start_time = QTime::currentTime();
	startRinging();
}

void AlarmClock::startRinging()
{
	tick_count = 0;
	if (alarm_type == AlarmClockBeep)
	{
		timer_tick->setInterval(BEEP_INTERVAL);
	}
	else
	{
		if (!source || !amplifier)
		{
			qWarning() << "Invalid alarm clock setup: either no source or amplifier enabled";
			return;
		}

		timer_tick->setInterval(SOUND_DIFFUSION_INTERVAL);
	}
	timer_tick->start();
	timer_postpone->stop();
	emit ringingChanged();
}

void AlarmClock::stop()
{
	timer_tick->stop();
	timer_postpone->stop();
	emit ringingChanged();
}

void AlarmClock::postpone()
{
	if (!isRinging())
		return;

	timer_tick->stop();
	timer_postpone->start();
	emit ringingChanged();
}

void AlarmClock::setDescription(QString new_value)
{
	if (description == new_value)
		return;

	description = new_value;
	emit descriptionChanged();
}

void AlarmClock::setEnabled(bool new_value)
{
	if (enabled == new_value)
		return;

	enabled = new_value;
	emit enabledChanged();
}

void AlarmClock::setAlarmType(AlarmClockType new_value)
{
	if (alarm_type == new_value)
		return;

	alarm_type = new_value;
	emit alarmTypeChanged();
}

void AlarmClock::setDays(int new_value)
{
	if (days == new_value || new_value < 0 || new_value > 0x7F)
		return;

	days = new_value;
	emit daysChanged();
}

void AlarmClock::setHour(int new_value)
{
	if (hour == new_value || new_value < 0 || new_value > 23)
		return;

	hour = new_value;
	emit hourChanged();
}

void AlarmClock::setMinute(int new_value)
{
	if (minute == new_value || new_value < 0 || new_value > 59)
		return;

	minute = new_value;
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

void AlarmClock::setTriggerOnMondays(bool new_value)
{
	setTriggerOnWeekdays(new_value, MASK_MONDAY);
}

void AlarmClock::setTriggerOnTuesdays(bool new_value)
{
	setTriggerOnWeekdays(new_value, MASK_TUESDAY);
}

void AlarmClock::setTriggerOnWednesdays(bool new_value)
{
	setTriggerOnWeekdays(new_value, MASK_WEDNESDAY);
}

void AlarmClock::setTriggerOnThursdays(bool new_value)
{
	setTriggerOnWeekdays(new_value, MASK_THURSDAY);
}

void AlarmClock::setTriggerOnFridays(bool new_value)
{
	setTriggerOnWeekdays(new_value, MASK_FRIDAY);
}

void AlarmClock::setTriggerOnSaturdays(bool new_value)
{
	setTriggerOnWeekdays(new_value, MASK_SATURDAY);
}

void AlarmClock::setTriggerOnSundays(bool new_value)
{
	setTriggerOnWeekdays(new_value, MASK_SUNDAY);
}

void AlarmClock::setTriggerOnWeekdays(bool new_value, int day_mask)
{
	int old_days = days;

	if (new_value) // set
		old_days |= day_mask;
	else // reset
		old_days &= ~day_mask;

	if (old_days == days)
		return;

	setDays(old_days);
}

void AlarmClock::alarmTick()
{
	if (alarm_type == AlarmClockBeep)
	{
		if (tick_count == (ALARM_TIME * 1000) / BEEP_INTERVAL - 1)
			stop();
		else
			emit ringMe(this);
	}
	else
	{
		if (tick_count == 0)
		{
			bool areas[9];

			memset(areas, 0, sizeof(areas));
			source->setActive(0);
			areas[0] = true;

			int area = amplifier->getArea();

			if (!areas[area])
			{
				source->setActive(area);
				areas[area] = true;
			}
		}

		if (tick_count == (ALARM_TIME * 1000) / SOUND_DIFFUSION_INTERVAL - 1)
		{
			soundDiffusionStop();
			stop();
		}
		else
			soundDiffusionSetVolume();
	}

	++tick_count;
}

void AlarmClock::soundDiffusionStop()
{
	amplifier->setActive(false);
}

void AlarmClock::soundDiffusionSetVolume()
{
	int real_volume = 32 * volume / 10;

	if (tick_count <= real_volume)
		amplifier->setVolume(tick_count);
	if (tick_count == 0)
		amplifier->setActive(true);
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

void AlarmClock::setAmplifier(Amplifier *_amplifier)
{
	if (_amplifier == amplifier)
		return;

	amplifier = _amplifier;
	emit amplifierChanged();
}

Amplifier *AlarmClock::getAmplifier() const
{
	return amplifier;
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

bool AlarmClock::isRinging() const
{
	return timer_tick->isActive();
}
