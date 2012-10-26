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

public:
	AlarmClockNotifier();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAlarmClockNotifier;
	}

private slots:
	void updateAlarmClocksInfo();

private:
	ObjectModel *alarm_clocks_model;
};

#endif // ALARM_CLOCK_NOTIFIER_H
