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

#ifndef DANGERS_H
#define DANGERS_H

#include "objectinterface.h"

#include <QObject>


class ObjectModel;
class StopAndGo;


/*!
	\brief Collects and notifies data about stop&go devices

	This class collects data about stop&go devices like number of device that
	are in ok state or in ko state. This information will be used to notify
	the GUI when an alarm triggers or when a device returns to normal state of
	operation.

	The object id is \a ObjectInterface::IdDangers.
*/
class StopAndGoDangers : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Gets the number of opened devices
	*/
	Q_PROPERTY(int openedDevices READ getOpenedDevices NOTIFY openedDevicesChanged)

	/*!
		\brief Gets the number of closed devices
	*/
	Q_PROPERTY(int closedDevices READ getClosedDevices NOTIFY closedDevicesChanged)

public:
	StopAndGoDangers();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDangers;
	}

	int getOpenedDevices() const { return opened_devices; }
	int getClosedDevices() const { return closed_devices; }

signals:
	void openedDevicesChanged(int devices_open);
	void closedDevicesChanged(int devices_closed);
	void stopAndGoDeviceChanged(StopAndGo *stopGoDevice);

private slots:
	void updateDangerInfo();

private:
	ObjectModel *stop_go_model;
	int closed_devices, opened_devices;
};

#endif // DANGERS_H
