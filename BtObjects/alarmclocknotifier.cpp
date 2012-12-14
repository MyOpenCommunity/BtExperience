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

	// inits everything
	updateAlarmClocksInfo();
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
			break;
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

void AlarmClockNotifier::emitAlarmStarted()
{
	AlarmClock *alarm = qobject_cast<AlarmClock*>(sender());
	Q_ASSERT_X(alarm, "AlarmClockNotifier::emitAlarmStarted", "Invalid alarm object");
	if (alarm->isRinging())
		emit alarmStarted(alarm);
}
