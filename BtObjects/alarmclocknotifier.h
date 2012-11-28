#ifndef ALARM_CLOCK_NOTIFIER_H
#define ALARM_CLOCK_NOTIFIER_H

#include "objectinterface.h"

#include <QObject>


class ObjectModel;
class AlarmClock;


/*!
	\brief Collects and notifies data about alarm clocks.

	This class collects data about alarm clocks and notifies about alarms
	enabled/disabled, triggered.

	The object id is \a ObjectInterface::IdAlarmClockNotifier.
*/
class AlarmClockNotifier : public ObjectInterface
{
	Q_OBJECT

	Q_PROPERTY(bool enabled READ isEnabled NOTIFY enabledChanged)

	Q_PROPERTY(bool alarmActive READ isAlarmActive NOTIFY alarmActiveChanged)

	Q_PROPERTY(bool beepAlarmActive READ isBeepAlarmActive NOTIFY beepAlarmActiveChanged)

public:
	AlarmClockNotifier();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAlarmClockNotifier;
	}

	void addAlarmClockConnections(AlarmClock *alarm);

	bool isEnabled() const;

	bool isAlarmActive() const;

	bool isBeepAlarmActive() const;

signals:
	void enabledChanged();
	void alarmActiveChanged();
	void beepAlarmActiveChanged();
	void alarmStarted(AlarmClock *alarmClock);
	void ringAlarmClock(AlarmClock *alarmClock);

private slots:
	void updateAlarmClocksInfo();
	void updateAlarmClocksRinging();
	void emitAlarmStarted();

private:
	ObjectModel *alarm_clocks_model;
	bool is_one_enabled, beep_alarm_ringing, alarm_ringing;
};

#endif // ALARM_CLOCK_NOTIFIER_H
