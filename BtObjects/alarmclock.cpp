#include "alarmclock.h"
#include "mediamodel.h"
#include "xml_functions.h"
#include "xmlobject.h"


#include <QFile>
#include <QtDebug>


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
	description = _description;
	enabled = _enabled;
	switch(_type)
	{
	case 1:
		alarmType = AlarmClockSoundSystem;
		break;
	default:
		alarmType = AlarmClockBeep;
		break;
	}
	days = _days;
	hour = _hour;
	minute = _minute;

	connect(this, SIGNAL(alarmTypeChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(daysChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(enabledChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(hourChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(minuteChanged()), this, SIGNAL(persistItem()));
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
	if (alarmType == newValue)
		return;

	alarmType = newValue;
	emit alarmTypeChanged();
}

void AlarmClock::setDays(int newValue)
{
	if (days == newValue)
		return;

	days = newValue;
	emit daysChanged();
}

void AlarmClock::setHour(int newValue)
{
	if (hour == newValue)
		return;

	hour = newValue;
	emit hourChanged();
}

void AlarmClock::setMinute(int newValue)
{
	if (minute == newValue)
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
	int d = days;

	if (newValue) // set
		d |= dayMask;
	else // reset
		d &= ~dayMask;

	if (d == days)
		return;

	days = d;
	emit daysChanged();
}
