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

#include "alarmclocknotifier.h"
#include "objectmodel.h"
#include "alarmclock.h"

#include <QDebug>


AlarmClockNotifier::AlarmClockNotifier()
{
	clocks = 0;
	beep_alarm_ringing = false;
	alarm_ringing = false;

	// creates an ObjectModel to select alarm clocks objects
	alarm_clocks_model = new ObjectModel(this);
	alarm_clocks_model->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdAlarmClock);

	// connects various alarm clocks signals to our slots
	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		AlarmClock *alarm = qobject_cast<AlarmClock *>(alarm_clocks_model->getObject(i));
		Q_ASSERT_X(alarm, __PRETTY_FUNCTION__, "Unexpected NULL object");
		addAlarmClockConnections(alarm);
	}

	// called at startup by the filter above
	connect(alarm_clocks_model, SIGNAL(modelReset()), this, SLOT(updateAlarmClocksInfo()));
}

bool AlarmClockNotifier::isAlarmActive() const
{
	return alarm_ringing;
}

bool AlarmClockNotifier::isBeepAlarmActive() const
{
	return beep_alarm_ringing;
}

void AlarmClockNotifier::addAlarmClockConnections(AlarmClock *alarm)
{
	connect(alarm, SIGNAL(enabledChanged()), this, SLOT(updateAlarmClocksInfo()));
	connect(alarm, SIGNAL(ringingChanged()), this, SLOT(updateAlarmClocksRinging()));
	connect(alarm, SIGNAL(ringingChanged()), this, SLOT(emitAlarmStarted()));
	connect(alarm, SIGNAL(ringMe(AlarmClock*)), this, SIGNAL(ringAlarmClock(AlarmClock*)));
}

int AlarmClockNotifier::getClocks() const
{
	return clocks;
}

void AlarmClockNotifier::updateAlarmClocksInfo()
{
	int counter = 0;

	// cycles over all alarm clocks objects to check if any is enabled
	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		AlarmClock *alarm = qobject_cast<AlarmClock *>(alarm_clocks_model->getObject(i));
		if (alarm->isEnabled())
		{
			++counter;
		}
	}

	if (counter == clocks)
		return;

	clocks = counter;
	emit clocksChanged();
}

void AlarmClockNotifier::updateAlarmClocksRinging()
{
	bool ringing = false, beep_ringing = false;

	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		AlarmClock *alarm = qobject_cast<AlarmClock *>(alarm_clocks_model->getObject(i));
		if (alarm->isRinging())
		{
			ringing = true;

			if (alarm->getAlarmType() == AlarmClock::AlarmClockBeep)
			{
				beep_ringing = true;
				break;
			}
		}
	}

	if (ringing != alarm_ringing)
	{
		alarm_ringing = ringing;
		emit alarmActiveChanged();
	}

	if (beep_ringing != beep_alarm_ringing)
	{
		beep_alarm_ringing = beep_ringing;
		emit beepAlarmActiveChanged();
	}
}

void AlarmClockNotifier::reemitAlarmStarted()
{
	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		AlarmClock *alarm = qobject_cast<AlarmClock *>(alarm_clocks_model->getObject(i));
		if (alarm->isRinging())
			emit alarmStarted(alarm);
	}
}

void AlarmClockNotifier::emitAlarmStarted()
{
	AlarmClock *alarm = qobject_cast<AlarmClock*>(sender());
	Q_ASSERT_X(alarm, "AlarmClockNotifier::emitAlarmStarted", "Invalid alarm object");
	if (alarm->isRinging())
		emit alarmStarted(alarm);
}
