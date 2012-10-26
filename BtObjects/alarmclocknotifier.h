#ifndef ALARM_CLOCK_NOTIFIER_H
#define ALARM_CLOCK_NOTIFIER_H

#include "objectinterface.h"

#include <QObject>


class ObjectModel;


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

public:
	AlarmClockNotifier();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAlarmClockNotifier;
	}

	bool isEnabled() const { return is_one_enabled; }

signals:
	void enabledChanged();

private slots:
	void updateAlarmClocksInfo();

private:
	ObjectModel *alarm_clocks_model;
	bool is_one_enabled;
};

#endif // ALARM_CLOCK_NOTIFIER_H
