#include "alarmclocknotifier.h"
#include "objectmodel.h"
#include "alarmclock.h"

#include <QDebug>


AlarmClockNotifier::AlarmClockNotifier()
{
	is_one_enabled = false;
	beep_alarm_ringing = false;

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

bool AlarmClockNotifier::isEnabled() const
{
	return is_one_enabled;
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

void AlarmClockNotifier::updateAlarmClocksInfo()
{
	bool _is_one_enabled = false;

	// cycles over all alarm clocks objects to check if any is enabled
	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		AlarmClock *alarm = qobject_cast<AlarmClock *>(alarm_clocks_model->getObject(i));
		if (alarm->isEnabled())
		{
			_is_one_enabled = true;
			break;
		}
	}

	if (_is_one_enabled == is_one_enabled)
		return;

	is_one_enabled = _is_one_enabled;
	emit enabledChanged();
}

void AlarmClockNotifier::updateAlarmClocksRinging()
{
	bool ringing = false;

	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		AlarmClock *alarm = qobject_cast<AlarmClock *>(alarm_clocks_model->getObject(i));
		if (alarm->isRinging() && alarm->getAlarmType() == AlarmClock::AlarmClockBeep)
		{
			ringing = true;
			break;
		}
	}

	if (ringing == beep_alarm_ringing)
		return;

	beep_alarm_ringing = ringing;
	emit beepAlarmActiveChanged();
}

void AlarmClockNotifier::emitAlarmStarted()
{
	AlarmClock *alarm = qobject_cast<AlarmClock*>(sender());
	Q_ASSERT_X(alarm, "AlarmClockNotifier::emitAlarmStarted", "Invalid alarm object");
	if (alarm->isRinging())
		emit alarmStarted(alarm);
}
