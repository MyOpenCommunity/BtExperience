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

	Q_PROPERTY(int clocks READ getClocks NOTIFY clocksChanged)

	Q_PROPERTY(bool alarmActive READ isAlarmActive NOTIFY alarmActiveChanged)

	Q_PROPERTY(bool beepAlarmActive READ isBeepAlarmActive NOTIFY beepAlarmActiveChanged)

public:
	AlarmClockNotifier();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAlarmClockNotifier;
	}

	void addAlarmClockConnections(AlarmClock *alarm);

	int getClocks() const;

	bool isAlarmActive() const;

	bool isBeepAlarmActive() const;

signals:
	void clocksChanged();
	void alarmActiveChanged();
	void beepAlarmActiveChanged();
	void alarmStarted(AlarmClock *alarmClock);
	void ringAlarmClock(AlarmClock *alarmClock);

public slots:
	void reemitAlarmStarted();

private slots:
	void emitAlarmStarted();
	void updateAlarmClocksInfo();
	void updateAlarmClocksRinging();

private:
	ObjectModel *alarm_clocks_model;
	bool beep_alarm_ringing, alarm_ringing;
	int clocks;
};

#endif // ALARM_CLOCK_NOTIFIER_H
