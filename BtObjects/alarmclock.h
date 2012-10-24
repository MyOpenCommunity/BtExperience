#ifndef ALARMCLOCK_H
#define ALARMCLOCK_H


#include "objectinterface.h"


class MediaDataModel;
class AlarmClock;


QList<ObjectPair> parseAlarmClocks(const QDomNode &xml_node);
void updateAlarmClocks(QDomNode node, AlarmClock *alarmClock);


/*!
	\brief An alarm clock setting
*/
class AlarmClock : public ObjectInterface
{
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

	/*!
		\brief The alarm clock minute [0-59] at which alarm triggers
	*/
	Q_PROPERTY(int minute READ getMinute WRITE setMinute NOTIFY minuteChanged)

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

	Q_ENUMS(AlarmClockType)

public:
	AlarmClock(QString description, bool enabled, int alarmType, int days, int hour, int minute, QObject *parent = 0);

	enum AlarmClockType
	{
		AlarmClockBeep,
		AlarmClockSoundSystem
	};

	QString getDescription() const { return description; }
	void setDescription(QString newValue);
	bool isEnabled() const { return enabled; }
	void setEnabled(bool newValue);
	AlarmClockType getAlarmType() const { return alarmType; }
	void setAlarmType(AlarmClockType newValue);
	int getDays() const { return days; }
	void setDays(int newValue);
	int getHour() const { return hour; }
	void setHour(int newValue);
	int getMinute() const { return minute; }
	void setMinute(int newValue);
	bool isTriggerOnMondays() const;
	bool isTriggerOnTuesdays() const;
	bool isTriggerOnWednesdays() const;
	bool isTriggerOnThursdays() const;
	bool isTriggerOnFridays() const;
	bool isTriggerOnSaturdays() const;
	bool isTriggerOnSundays() const;
	void setTriggerOnMondays(bool newValue);
	void setTriggerOnTuesdays(bool newValue);
	void setTriggerOnWednesdays(bool newValue);
	void setTriggerOnThursdays(bool newValue);
	void setTriggerOnFridays(bool newValue);
	void setTriggerOnSaturdays(bool newValue);
	void setTriggerOnSundays(bool newValue);

signals:
	void alarmTypeChanged();
	void daysChanged();
	void descriptionChanged();
	void enabledChanged();
	void hourChanged();
	void minuteChanged();
	void triggerOnMondaysChanged();
	void triggerOnTuesdaysChanged();
	void triggerOnWednesdaysChanged();
	void triggerOnThursdaysChanged();
	void triggerOnFridaysChanged();
	void triggerOnSaturdaysChanged();
	void triggerOnSundaysChanged();

private:
	void setTriggerOnWeekdays(bool newValue, int dayMask);

	AlarmClockType alarmType;
	QString description;
	bool enabled;
	int days, hour, minute;
};

#endif // ALARMCLOCK_H
