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

#include "dangers.h"
#include "objectmodel.h"
#include "stopandgoobjects.h"

#include <QDebug>


StopAndGoDangers::StopAndGoDangers()
{
	closed_devices = opened_devices = 0;

	// creates an ObjectModel to select stop&go objects
	stop_go_model = new ObjectModel(this);
	stop_go_model->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdStopAndGo
			       << ObjectModelFilters() << "objectId" << ObjectInterface::IdStopAndGoPlus
			       << ObjectModelFilters() << "objectId" << ObjectInterface::IdStopAndGoBTest);

	// connects statusChanged signal of stop&go objects to our updateDangerInfo
	// signal
	for(int i = 0; i < stop_go_model->getCount(); ++i)
	{
		ItemInterface *item = stop_go_model->getObject(i);
		StopAndGo *stopGo = qobject_cast<StopAndGo *>(item);
		Q_ASSERT_X(stopGo, __PRETTY_FUNCTION__, "Unexpected NULL object");
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

		Q_ASSERT_X(stopGo, __PRETTY_FUNCTION__, "Unexpected NULL object");

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
