#include "dangers.h"
#include "objectmodel.h"
#include "stopandgoobjects.h"

#include <QDebug>


StopAndGoDangers::StopAndGoDangers()
{
	closed_devices = opened_devices = 0;

	// creates an ObjectModel to select stop&go objects
	stop_go_model = new ObjectModel();
	QVariantList filters;
	QVariantMap filter;

	// sets filters to select stop&go objects
	filter["objectId"] = ObjectInterface::IdStopAndGo;
	filters << filter;
	filter.clear();
	filter["objectId"] = ObjectInterface::IdStopAndGoPlus;
	filters << filter;
	filter.clear();
	filter["objectId"] = ObjectInterface::IdStopAndGoBTest;
	filters << filter;
	filter.clear();

	// filters
	stop_go_model->setFilters(filters);

	// connects statusChanged signal of stop&go objects to our updateDangerInfo
	// signal
	for(int i = 0; i < stop_go_model->getCount(); ++i)
	{
		ItemInterface *item = stop_go_model->getObject(i);
		StopAndGo *stopGo = qobject_cast<StopAndGo *>(item);
		if (!stopGo)
			continue;
		connect(stopGo, SIGNAL(statusChanged(StopAndGo *)), this, SLOT(updateDangerInfo()));
		connect(stopGo, SIGNAL(statusChanged(StopAndGo *)), this, SIGNAL(stopAndGoDeviceChanged(StopAndGo *)));
	}

	// inits everything
	updateDangerInfo();
}

void StopAndGoDangers::updateDangerInfo()
{
	int closed = 0;
	int opened = 0;

	// cycles over all stop&go objects and computes opened and closed devices
	for(int i = 0; i < stop_go_model->getCount(); ++i)
	{
		ItemInterface *item = stop_go_model->getObject(i);
		StopAndGo *stopGo = qobject_cast<StopAndGo *>(item);

		if (!stopGo)
			continue;

		StopAndGo::Status st = stopGo->getStatus();
		if (st == StopAndGo::Closed || st == StopAndGo::Unknown)
			++closed;
		else
			++opened;
	}

	if (closed_devices != closed)
	{
		closed_devices = closed;
		emit closedDevicesChanged(closed_devices);
	}

	if (opened_devices != opened)
	{
		opened_devices = opened;
		emit openedDevicesChanged(opened_devices);
	}
}
