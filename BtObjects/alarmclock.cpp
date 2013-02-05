#include "alarmclock.h"
#include "mediamodel.h"
#include "mediaobjects.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "shared_functions.h"
#include "devices_cache.h"
#include "platform_device.h"
#include "qmlcache.h"


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

	const int ALARM_TIME = 2 * 60;
	const int POSTPONE_TIME = 5 * 60;
	const int MAX_TIME = 30 * 60;

	const int BEEP_INTERVAL = 5000;

	const int SOUND_DIFFUSION_INTERVAL = 3000;

	const QString ALARM_NO_NAME(AlarmClock::tr("new alarm clock"));

	// constants for QMLCache
	const int QML_ALARM_TYPE = 1;
	const int QML_DESCRIPTION = 2;
	const int QML_DAYS = 3;
	const int QML_HOUR = 4;
	const int QML_MINUTE = 5;
	const int QML_VOLUME = 6;
	const int QML_SOURCE = 7;
	const int QML_AMPLIFIER = 8;
	const int QML_AMBIENT = 9;
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

		alarm->setVolume(v.intValue("volume") * 10);

		int amplifier_uii = v.intValue("amplifier_uii");
		if (amplifier_uii > 0) // uii must be positive
		{
			Amplifier *amplifier = uii_map.value<Amplifier>(amplifier_uii);
			AmplifierGroup *amplifierGroup = uii_map.value<AmplifierGroup>(amplifier_uii);
			if (amplifier)
				alarm->setAmplifier(amplifier);
			else if (amplifierGroup)
				alarm->setAmplifier(amplifierGroup);
			else
				qFatal("Invalid amplifier object for amplifier_uii %d", amplifier_uii);
		}

		SourceObject::SourceObjectType source_type;

		int t = v.intValue("source_type");
		switch (t)
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
			qFatal("Invalid source type for alarm clock (%d)", t);
		}

		foreach (SourceObject *source, sources)
		{
			if (source->getSourceType() == source_type)
			{
				alarm->setSource(source);
				break;
			}
		}

		// we have set values with set methods; applies modifications to object
		// and make them persistent (original values will be set to right ones)
		alarm->apply();

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
	setAttribute(node, "volume", QString::number(alarm_clock->getVolume() / 10));

	if (alarm_clock->getAlarmType() == AlarmClock::AlarmClockSoundSystem)
	{
		int amplifier_uii = -1;
		Amplifier *amplifier = dynamic_cast<Amplifier *>(alarm_clock->getAmplifier());
		AmplifierGroup *amplifierGroup = dynamic_cast<AmplifierGroup *>(alarm_clock->getAmplifier());
		if (amplifier)
			amplifier_uii = uii_map.findUii(amplifier);
		else if (amplifierGroup)
			amplifier_uii = uii_map.findUii(amplifierGroup);

		if (amplifier_uii > 0) // uii must be positive
		{
			setAttribute(node, "amplifier_uii", QString::number(amplifier_uii));

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
}

AlarmClock::AlarmClock(QString description, bool _enabled, int type, int days, int hour, int minute, QObject *parent)
	: ObjectInterface(parent)
{
	PlatformDevice *dev = bt_global::add_device_to_cache(new PlatformDevice);

	cache = new QMLCache(this);

	timer_trigger = new QTimer(this);

	switch(type)
	{
	case 1:
		cache->setOriginalValue(QML_ALARM_TYPE, AlarmClockSoundSystem);
		break;
	default:
		cache->setOriginalValue(QML_ALARM_TYPE, AlarmClockBeep);
		break;
	}
	cache->setOriginalValue(QML_DESCRIPTION, description.isEmpty() ? ALARM_NO_NAME : description);
	cache->setOriginalValue(QML_DAYS, days);
	cache->setOriginalValue(QML_HOUR, hour);
	cache->setOriginalValue(QML_MINUTE, minute);
	cache->setOriginalValue(QML_VOLUME, 0);
	cache->setOriginalValue(QML_AMBIENT, 0);
	cache->setOriginalValue(QML_AMPLIFIER, Converter<QObject>::asQVariant(0));
	cache->setOriginalValue(QML_SOURCE, Converter<SourceObject>::asQVariant(0));

	enabled = false; // starting from a well known state
	tick_count = 0;
	timer_tick = new QTimer(this);

	timer_postpone = new QTimer(this);
	timer_postpone->setSingleShot(true);
	timer_postpone->setInterval(POSTPONE_TIME * 1000);

	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));

	connect(this, SIGNAL(enabledChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(amplifierChanged()), this, SLOT(updateAmbient()));
	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(validityStatusChanged()));

	connect(timer_trigger, SIGNAL(timeout()), this, SLOT(triggersIfHasTo()));
	connect(timer_tick, SIGNAL(timeout()), this, SLOT(alarmTick()));
	connect(timer_postpone, SIGNAL(timeout()), this, SLOT(restart()));

	connect(this, SIGNAL(enabledChanged()), this, SIGNAL(checkRequested()));
	connect(this, SIGNAL(daysChanged()), this, SIGNAL(checkRequested()));
	connect(this, SIGNAL(hourChanged()), this, SIGNAL(checkRequested()));
	connect(this, SIGNAL(minuteChanged()), this, SIGNAL(checkRequested()));

	connect(this, SIGNAL(checkRequested()), this, SLOT(checkRequestManagement()));

	connect(cache, SIGNAL(qmlValueChanged(int,QVariant)), this, SLOT(qmlValueChanged(int,QVariant)));
	connect(cache, SIGNAL(persistItemRequested()), this, SIGNAL(persistItem()));

	setEnabled(_enabled); // sets real value
}

void AlarmClock::reset()
{
	cache->reset();
}

AlarmClock::AlarmClockApplyResult AlarmClock::getValidityStatus()
{
	if (getAlarmType() == AlarmClock::AlarmClockSoundSystem)
	{
		if (getAmplifier() == 0)
			return AlarmClockApplyResultNoAmplifier;
		if (getSource() == 0)
			return AlarmClockApplyResultNoSource;
	}

	if (getDescription() == ALARM_NO_NAME)
		return AlarmClockApplyResultNoName;

	return AlarmClockApplyResultOk;
}

void AlarmClock::apply()
{
	cache->apply();
}

void AlarmClock::qmlValueChanged(int key, QVariant value)
{
	Q_UNUSED(value);

	switch(key)
	{
	case QML_ALARM_TYPE:
		emit alarmTypeChanged();
		break;
	case QML_DESCRIPTION:
		emit descriptionChanged();
		break;
	case QML_DAYS:
		emit daysChanged();
		break;
	case QML_HOUR:
		emit hourChanged();
		break;
	case QML_MINUTE:
		emit minuteChanged();
		break;
	case QML_VOLUME:
		emit volumeChanged();
		break;
	case QML_AMPLIFIER:
		emit amplifierChanged();
		break;
	case QML_SOURCE:
		emit sourceChanged();
		break;
	case QML_AMBIENT:
		emit ambientChanged();
		break;
	default:
		qWarning() << __PRETTY_FUNCTION__ << "an unknown key (" << key << ") has arrived";
	}
}

void AlarmClock::valueReceived(const DeviceValues &values_list)
{
	if (values_list.contains(PlatformDevice::DIM_DATE) ||
	    values_list.contains(PlatformDevice::DIM_TIME))
		checkRequestManagement();
}

void AlarmClock::checkRequestManagement()
{
	if (enabled)
	{
		// gets actual date&time
		QDateTime actual_date_time = QDateTime::currentDateTime();

		// gets triggering date&time
		QDateTime triggering_date_time = QDateTime(actual_date_time.date(), QTime(getHour(), getMinute()));

		// computes difference in seconds between actual and candidate date&time
		int delta_seconds = actual_date_time.secsTo(triggering_date_time);

		// if difference is not positive adds 1 day to triggering date&time and recomputes delta
		if (delta_seconds <= 0)
			delta_seconds = actual_date_time.secsTo(triggering_date_time.addDays(1));

		// finally, sets trigger timer
		qDebug("(re)starting timer with interval of msecs = %d", delta_seconds * 1000);
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
	if (getDays() == 0)
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
	actual_type = getAlarmType();
	start_time = QTime::currentTime();
	startRinging();
}

void AlarmClock::startRinging()
{
	tick_count = 0;
	if (actual_type == AlarmClockBeep)
	{
		timer_tick->setInterval(BEEP_INTERVAL);
	}
	else
	{
		if (!getSource() || !getAmplifier())
		{
			qWarning() << "Invalid alarm clock setup: either no source or amplifier enabled";
			return;
		}

		timer_tick->setInterval(SOUND_DIFFUSION_INTERVAL);
	}

	timer_tick->start();
	timer_postpone->stop();
	emit ringingChanged();

	if (actual_type == AlarmClockSoundSystem)
	{
		SourceMedia *media = qobject_cast<SourceMedia *>(getSource());

		if (media)
		{
			connect(media, SIGNAL(firstMediaContentStatus(bool)),
					this, SLOT(mediaSourcePlaybackStatus(bool)));
			media->playFirstMediaContent();
		}
	}
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
	if (actual_type == AlarmClockSoundSystem)
		soundDiffusionStop();

	timer_tick->stop();
	timer_postpone->start();
	emit ringingChanged();
}

void AlarmClock::setEnabled(bool new_value)
{
	if (enabled == new_value)
		return;

	enabled = new_value;
	emit enabledChanged();
}

bool AlarmClock::isTriggerOnMondays() const
{
	return ((getDays() & MASK_MONDAY) > 0);
}

bool AlarmClock::isTriggerOnTuesdays() const
{
	return ((getDays() & MASK_TUESDAY) > 0);
}

bool AlarmClock::isTriggerOnWednesdays() const
{
	return ((getDays() & MASK_WEDNESDAY) > 0);
}

bool AlarmClock::isTriggerOnThursdays() const
{
	return ((getDays() & MASK_THURSDAY) > 0);
}

bool AlarmClock::isTriggerOnFridays() const
{
	return ((getDays() & MASK_FRIDAY) > 0);
}

bool AlarmClock::isTriggerOnSaturdays() const
{
	return ((getDays() & MASK_SATURDAY) > 0);
}

bool AlarmClock::isTriggerOnSundays() const
{
	return ((getDays() & MASK_SUNDAY) > 0);
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
	int old_days = getDays();

	if (new_value) // set
		old_days |= day_mask;
	else // reset
		old_days &= ~day_mask;

	setDays(old_days);
}

void AlarmClock::alarmTick()
{
	if (actual_type == AlarmClockBeep)
	{
		if (tick_count == (ALARM_TIME * 1000) / BEEP_INTERVAL - 1)
			stop();
		else
			emit ringMe(this);
	}
	else
	{
		if (tick_count == 0)
			getAmplifierInterface()->setActiveOnSource(getSource());

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

void AlarmClock::mediaSourcePlaybackStatus(bool status)
{
	disconnect(getSource(), SIGNAL(firstMediaContentStatus(bool)),
			   this, SLOT(mediaSourcePlaybackStatus(bool)));

	if (!isRinging())
		return;

	if (!status)
	{
		qDebug("Unable to start local source, fallback to beep");

		actual_type = AlarmClockBeep;
		soundDiffusionStop();
		startRinging();
	}
}

void AlarmClock::soundDiffusionStop()
{
	if (getAmplifier())
		getAmplifierInterface()->setActive(false);
}

void AlarmClock::soundDiffusionSetVolume()
{
	int real_volume = 32 * getVolume() / 10;

	if (tick_count <= real_volume)
		getAmplifierInterface()->setVolume(tick_count);
	if (tick_count == 0)
		getAmplifierInterface()->setActive(true);
}

void AlarmClock::incrementVolume()
{
	int desired = getVolume() + 10;
	if (desired > 100)
		desired = 100;
	desired = desired - desired % 10;
	setVolume(desired);
}

void AlarmClock::decrementVolume()
{
	int desired = getVolume() - 10;
	if (desired < 10)
		desired = 10;
	desired = desired - desired % 10;
	setVolume(desired);
}

void AlarmClock::incrementAmbient()
{
	int index = ambientList.indexOf(getAmbient()) + 1;
	if (index < ambientList.count())
		cache->setQMLValue(QML_AMBIENT, index);
}

void AlarmClock::decrementAmbient()
{
	int index = ambientList.indexOf(getAmbient()) - 1;
	if (index >= 0)
		cache->setQMLValue(QML_AMBIENT, index);
}

bool AlarmClock::isRinging() const
{
	return timer_tick->isActive();
}

void AlarmClock::updateAmbient()
{
	int ambient_index = 0;

	AmplifierInterface *amplifier_interface = getAmplifierInterface();

	// loop through all ambients to look for the one containing this amplifier
	ambientList.clear();
	QScopedPointer<ObjectModel> ambientModel(new ObjectModel());
	ambientModel->setFilters(
				ObjectModelFilters() << "objectId" << ObjectInterface::IdMultiChannelSpecialAmbient
				<< ObjectModelFilters() << "objectId" << ObjectInterface::IdMultiChannelSoundAmbient
				<< ObjectModelFilters() << "objectId" << ObjectInterface::IdMonoChannelSoundAmbient
				<< ObjectModelFilters() << "objectId" << ObjectInterface::IdMultiGeneral);
	for (int i = 0; i < ambientModel->getCount(); ++i)
	{
		ItemInterface *item = ambientModel->getObject(i);
		SoundAmbientBase *ambient = qobject_cast<SoundAmbientBase *>(item);
		Q_ASSERT_X(ambient, __PRETTY_FUNCTION__, "Unexpected NULL object");
		if (ambient)
		{
			ambientList << ambient;
			if (amplifier_interface && amplifier_interface->belongsToAmbient(ambient))
			{
				ambient_index = i;
				break;
			}
		}
	}

	cache->setQMLValue(QML_AMBIENT, ambient_index);
}

AlarmClock::AlarmClockType AlarmClock::getAlarmType() const
{
	return static_cast<AlarmClock::AlarmClockType>(cache->getQMLValue(QML_ALARM_TYPE).toInt());
}

void AlarmClock::setAlarmType(AlarmClockType new_value)
{
	if (getAlarmType() != new_value)
		cache->setQMLValue(QML_ALARM_TYPE, new_value);
}

int AlarmClock::getDays() const
{
	return cache->getQMLValue(QML_DAYS).toInt();
}

void AlarmClock::setDays(int new_value)
{
	// checks if new value is in permitted range
	if (new_value < 0 || new_value > 0x7F)
		return;

	if (getDays() != new_value)
		cache->setQMLValue(QML_DAYS, new_value);
}

int AlarmClock::getHour() const
{
	return cache->getQMLValue(QML_HOUR).toInt();
}

void AlarmClock::setHour(int new_value)
{
	QTime t(getHour(), getMinute());
	QTime new_time = addHours(t, new_value);

	if (new_time.hour() != getHour())
		cache->setQMLValue(QML_HOUR, new_time.hour());
}

int AlarmClock::getMinute() const
{
	return cache->getQMLValue(QML_MINUTE).toInt();
}

void AlarmClock::setMinute(int new_value)
{
	QTime t(getHour(), getMinute());
	QTime new_time = addMinutes(t, new_value);

	if (new_time.minute() != getMinute())
		cache->setQMLValue(QML_MINUTE, new_time.minute());
	if (new_time.hour() != getHour())
		cache->setQMLValue(QML_HOUR, new_time.hour());
}

int AlarmClock::getVolume() const
{
	return cache->getQMLValue(QML_VOLUME).toInt();
}

void AlarmClock::setVolume(int new_value)
{
	if (getVolume() != new_value)
		cache->setQMLValue(QML_VOLUME, new_value);
}

QString AlarmClock::getDescription() const
{
	return cache->getQMLValue(QML_DESCRIPTION).toString();
}

void AlarmClock::setDescription(QString new_value)
{
	if (getDescription() != new_value)
		cache->setQMLValue(QML_DESCRIPTION, new_value);
}

SourceObject *AlarmClock::getSource() const
{
	return Converter<SourceObject>::asPointer(cache->getQMLValue(QML_SOURCE));
}

void AlarmClock::setSource(SourceObject *new_value)
{
	if (getSource() != new_value)
		cache->setQMLValue(QML_SOURCE, Converter<SourceObject>::asQVariant(new_value));
}

AmplifierInterface *AlarmClock::getAmplifierInterface()
{
	return dynamic_cast<AmplifierInterface *>(getAmplifier());
}

QObject *AlarmClock::getAmplifier() const
{
	return Converter<QObject>::asPointer(cache->getQMLValue(QML_AMPLIFIER));
}

void AlarmClock::setAmplifier(QObject *new_value)
{
	if (getAmplifier() != new_value)
		cache->setQMLValue(QML_AMPLIFIER, Converter<QObject>::asQVariant(new_value));
}

QObject *AlarmClock::getAmbient()
{
	// ambients are parsed after alarm clocks parsing, so checks if ambientList
	// is empty and updates ambientList
	if (ambientList.count() == 0)
		updateAmbient();
	int index = cache->getQMLValue(QML_AMBIENT).toInt();
	if (index >= 0 && index < ambientList.count())
		return ambientList.at(index);
	return 0;
}
