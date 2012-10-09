#ifndef DANGERS_H
#define DANGERS_H

#include "objectinterface.h"

#include <QObject>


class ObjectModel;


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
	Q_PROPERTY(int opened READ getOpenedDevices NOTIFY openedDevices)

	/*!
		\brief Gets the number of closed devices
	*/
	Q_PROPERTY(int closed READ getClosedDevices NOTIFY closedDevices)

public:
	StopAndGoDangers();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDangers;
	}

	int getOpenedDevices() const { return opened_devices; }
	int getClosedDevices() const { return closed_devices; }

signals:
	void openedDevices(int devices_open);
	void closedDevices(int devices_closed);

private slots:
	void updateDangerInfo();

private:
	ObjectModel *stop_go_model;
	int closed_devices, opened_devices;
};

#endif // DANGERS_H
