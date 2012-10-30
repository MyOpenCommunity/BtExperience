#ifndef ALARMCLOCK_H
#define ALARMCLOCK_H

#include "objectinterface.h"

#include <QHash>
#include <QSet>


class MediaDataModel;
class AlarmClock;
class QTimer;
class Amplifier;
class SourceObject;


QList<ObjectPair> parseAlarmClocks(const QDomNode &xml_node);
void updateAlarmClocks(QDomNode node, AlarmClock *alarm_clock);


/*!
	\brief An alarm clock setting
*/
class AlarmClock : public ObjectInterface
{
	friend class TestAlarmClockSoundDiffusion;

	Q_OBJECT

	/*!
		\brief The alarm clock description
	*/
	Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)

	/*!
		\brief Is the alarm clock enabled?
	*/
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

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
		\brief The alarm clock sound diffusion volume
	*/
	Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)

	Q_ENUMS(AlarmClockType)

public:
	AlarmClock(QString description, bool enabled, int alarm_type, int days, int hour, int minute, QObject *parent = 0);

	enum AlarmClockType
	{
		AlarmClockBeep,
		AlarmClockSoundSystem
	};

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAlarmClock;
	}

	Q_INVOKABLE void stop();
	Q_INVOKABLE void postpone();

	Q_INVOKABLE void setAmplifierEnabled(Amplifier *amplifier, bool enabled);
	Q_INVOKABLE bool isAmplifierEnabled(Amplifier *amplifier) const;

	QString getDescription() const { return description; }
	void setDescription(QString new_value);
	bool isEnabled() const { return enabled; }
	void setEnabled(bool new_value);
	AlarmClockType getAlarmType() const { return alarm_type; }
	void setAlarmType(AlarmClockType new_value);
	int getDays() const { return days; }
	void setDays(int new_value);
	int getHour() const { return hour; }
	void setHour(int new_value);
	int getMinute() const { return minute; }
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
	void setSource(SourceObject *source);
	SourceObject *getSource() const;
	void setVolume(int volume);
	int getVolume() const;

	static void addSource(SourceObject *source);
	static void addAmplifier(Amplifier *amplifier);

signals:
	void alarmTypeChanged();
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
	void volumeChanged();

private slots:
	void checkRequestManagement();
	void triggersIfHasTo();
	void alarmTick();

private:
	void start();
	void setTriggerOnWeekdays(bool new_value, int day_mask);
	void soundDiffusionStop();
	void soundDiffusionSetVolume();

	AlarmClockType alarm_type;
	QString description;
	bool enabled;
	int days, hour, minute;
	QTimer *timer_trigger;
	QTimer *tick;
	int tick_count;

	// sound diffusion alarm clock
	QSet<Amplifier *> enabled_amplifiers;
	SourceObject *source;
	int volume;

	// used when loading/saving configurations
	static QHash<int, Amplifier *> amplififers;
	static QHash<int, SourceObject *> sources;
};

#endif // ALARMCLOCK_H
