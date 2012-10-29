#include "alarmclocknotifier.h"
#include "objectmodel.h"
#include "alarmclock.h"

#include <QDebug>


AlarmClockNotifier::AlarmClockNotifier()
{
	is_one_enabled = false;

	// creates an ObjectModel to select alarm clocks objects
	alarm_clocks_model = new ObjectModel(this);
	QVariantList filters;
	QVariantMap filter;

	// sets filters to select alarm clocks objects
	filter["objectId"] = ObjectInterface::IdAlarmClock;
	filters << filter;

	// actually filters
	alarm_clocks_model->setFilters(filters);

	// connects various alarm clocks signals to our slots
	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		ItemInterface *item = alarm_clocks_model->getObject(i);
		AlarmClock *alarm = qobject_cast<AlarmClock *>(item);
		Q_ASSERT_X(alarm, __PRETTY_FUNCTION__, "Unexpected NULL object");
		addAlarmClockConnections(alarm);
	}

	// inits everything
	updateAlarmClocksInfo();
}

void AlarmClockNotifier::addAlarmClockConnections(AlarmClock *alarm)
{
	connect(alarm, SIGNAL(enabledChanged()), this, SLOT(updateAlarmClocksInfo()));
	connect(alarm, SIGNAL(ringMe(AlarmClock*)), this, SIGNAL(ringAlarmClock(AlarmClock*)));
}

void AlarmClockNotifier::updateAlarmClocksInfo()
{
	bool _is_one_enabled = false;

	// cycles over all alarm clocks objects to check if any is enabled
	for (int i = 0; i < alarm_clocks_model->getCount(); ++i)
	{
		ItemInterface *item = alarm_clocks_model->getObject(i);
		AlarmClock *alarm = qobject_cast<AlarmClock *>(item);
		Q_ASSERT_X(alarm, __PRETTY_FUNCTION__, "Unexpected NULL object");
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
