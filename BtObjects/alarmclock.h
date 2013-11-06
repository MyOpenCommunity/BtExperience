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

#ifndef ALARMCLOCK_H
#define ALARMCLOCK_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QHash>
#include <QTime>
#include <QVariant>


class MediaDataModel;
class AlarmClock;
class QTimer;
class AmplifierInterface;
class SourceObject;
class UiiMapper;
class QMLCache;


QList<ObjectPair> parseAlarmClocks(const QDomNode &xml_node, QList<SourceObject *> sources, const UiiMapper &uii_map);
void updateAlarmClocks(QDomNode node, AlarmClock *alarm_clock, const UiiMapper &uii_map);


/*!
	\brief An alarm clock setting

	Each alarm clock can be configured to either use the internal beeper or to
	use the sound diffusion system.
	You can set the volume of the alarm clock; the volume will be gradually
	increased until it reaches the target volume.
	You can set which amplifier or amplifier group will play the alarm clock.
	You can postpone the alarm clock with \ref AlarmClock::postpone().
*/
class AlarmClock : public ObjectInterface
{
	friend class TestAlarmClockBeep;
	friend class TestAlarmClockSoundDiffusion;

	Q_OBJECT

	/*!
		\brief The alarm clock description
	*/
	Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)

	/*!
		\brief Checks if object is valid to be permanently saved
	*/
	Q_PROPERTY(AlarmClockApplyResult validityStatus READ getValidityStatus NOTIFY validityStatusChanged)

	/*!
		\brief Is the alarm clock enabled?
	*/
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

	/*!
		\brief Is the alarm clock ringing?
	*/
	Q_PROPERTY(bool ringing READ isRinging NOTIFY ringingChanged)

	/*!
		\brief The alarm clock type
	*/
	Q_PROPERTY(AlarmClockType alarmType READ getAlarmType WRITE setAlarmType NOTIFY alarmTypeChanged)

	/*!
		\brief The alarm clock hour [0-23] at which alarm triggers
	*/
	Q_PROPERTY(int hour READ getHour WRITE setHour NOTIFY hourChanged)
	Q_PROPERTY(int hours READ getHour WRITE setHour NOTIFY hourChanged)

	/*!
		\brief The alarm clock minute [0-59] at which alarm triggers
	*/
	Q_PROPERTY(int minute READ getMinute WRITE setMinute NOTIFY minuteChanged)
	Q_PROPERTY(int minutes READ getMinute WRITE setMinute NOTIFY minuteChanged)

	/*!
		\brief Does the alarm clock trigger on a specific weekday?
	*/
	Q_PROPERTY(bool triggerOnMondays READ isTriggerOnMondays WRITE setTriggerOnMondays NOTIFY triggerOnMondaysChanged)
	Q_PROPERTY(bool triggerOnTuesdays READ isTriggerOnTuesdays WRITE setTriggerOnTuesdays NOTIFY triggerOnTuesdaysChanged)
	Q_PROPERTY(bool triggerOnWednesdays READ isTriggerOnWednesdays WRITE setTriggerOnWednesdays NOTIFY triggerOnWednesdaysChanged)
	Q_PROPERTY(bool triggerOnThursdays READ isTriggerOnThursdays WRITE setTriggerOnThursdays NOTIFY triggerOnThursdaysChanged)
	Q_PROPERTY(bool triggerOnFridays READ isTriggerOnFridays WRITE setTriggerOnFridays NOTIFY triggerOnFridaysChanged)
	Q_PROPERTY(bool triggerOnSaturdays READ isTriggerOnSaturdays WRITE setTriggerOnSaturdays NOTIFY triggerOnSaturdaysChanged)
	Q_PROPERTY(bool triggerOnSundays READ isTriggerOnSundays WRITE setTriggerOnSundays NOTIFY triggerOnSundaysChanged)
	Q_PROPERTY(int trigger READ getDays NOTIFY daysChanged) // used for updates in QML

	/*!
		\brief The alarm clock sound diffusion source
	*/
	Q_PROPERTY(SourceObject* source READ getSource WRITE setSource NOTIFY sourceChanged)

	/*!
		\brief The alarm clock sound diffusion amplifier (may be a group of amplifiers)
	*/
	Q_PROPERTY(QObject* amplifier READ getAmplifier WRITE setAmplifier NOTIFY amplifierChanged)

	/*!
		\brief The alarm clock sound diffusion volume
	*/
	Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)

	/*!
		\brief The ambient relative to the amplifier set if any, otherwise is NULL
	*/
	Q_PROPERTY(QObject *ambient READ getAmbient NOTIFY ambientChanged)

	Q_ENUMS(AlarmClockType AlarmClockApplyResult)

public:
	AlarmClock(QString description, bool enabled, int alarm_type, int days, int hour, int minute, QObject *parent = 0);

	enum AlarmClockType
	{
		AlarmClockBeep,
		AlarmClockSoundSystem
	};

	enum AlarmClockApplyResult
	{
		AlarmClockApplyResultOk = 0,
		AlarmClockApplyResultNoSource,
		AlarmClockApplyResultNoAmplifier,
		AlarmClockApplyResultNoName
	};

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAlarmClock;
	}

	Q_INVOKABLE void reset();
	Q_INVOKABLE void apply();

	Q_INVOKABLE void stop();
	/// Postpones the alarm by the preconfigured amount of time (5 minutes)
	Q_INVOKABLE void postpone();
	Q_INVOKABLE void incrementVolume();
	Q_INVOKABLE void decrementVolume();
	Q_INVOKABLE void incrementAmbient();
	Q_INVOKABLE void decrementAmbient();

	QString getDescription() const;
	void setDescription(QString new_value);
	bool isEnabled() const { return enabled; }
	void setEnabled(bool new_value);
	AlarmClockType getAlarmType() const;
	void setAlarmType(AlarmClockType new_value);
	int getDays() const;
	void setDays(int new_value);
	int getHour() const;
	void setHour(int new_value);
	int getMinute() const;
	void setMinute(int new_value);
	bool isTriggerOnMondays() const;
	bool isTriggerOnTuesdays() const;
	bool isTriggerOnWednesdays() const;
	bool isTriggerOnThursdays() const;
	bool isTriggerOnFridays() const;
	bool isTriggerOnSaturdays() const;
	bool isTriggerOnSundays() const;
	void setTriggerOnMondays(bool new_value);
	void setTriggerOnTuesdays(bool new_value);
	void setTriggerOnWednesdays(bool new_value);
	void setTriggerOnThursdays(bool new_value);
	void setTriggerOnFridays(bool new_value);
	void setTriggerOnSaturdays(bool new_value);
	void setTriggerOnSundays(bool new_value);
	void setSource(SourceObject *new_value);
	SourceObject *getSource() const;
	void setAmplifier(QObject *new_value);
	QObject *getAmplifier() const;
	void setVolume(int volume);
	int getVolume() const;
	bool isRinging() const;
	QObject *getAmbient();
	AlarmClockApplyResult getValidityStatus();

signals:
	void alarmTypeChanged();
	void ambientChanged();
	void checkRequested();
	void daysChanged();
	void descriptionChanged();
	void enabledChanged();
	void hourChanged();
	void minuteChanged();
	void ringMe(AlarmClock *alarm_clock);
	void triggerOnMondaysChanged();
	void triggerOnTuesdaysChanged();
	void triggerOnWednesdaysChanged();
	void triggerOnThursdaysChanged();
	void triggerOnFridaysChanged();
	void triggerOnSaturdaysChanged();
	void triggerOnSundaysChanged();
	void sourceChanged();
	void amplifierChanged();
	void volumeChanged();
	void ringingChanged();
	void validityStatusChanged();

private slots:
	void checkRequestManagement();
	void triggersIfHasTo();
	void alarmTick();
	void restart();
	void mediaSourcePlaybackStatus(bool status);
	void qmlValueChanged(int key, QVariant value);
	void updateAmbient();
	void valueReceived(const DeviceValues &values_list);

private:
	void start();
	void startRinging();
	void setTriggerOnWeekdays(bool new_value, int day_mask);
	void soundDiffusionStop();
	void soundDiffusionSetVolume();
	AmplifierInterface *getAmplifierInterface();

	QMLCache *cache;

	AlarmClockType actual_type;
	bool enabled;
	QTimer *timer_trigger;
	QTimer *timer_tick;
	QTimer *timer_postpone;
	int tick_count;
	QTime start_time;
	QList<QObject *> ambientList;
};

#endif // ALARMCLOCK_H
