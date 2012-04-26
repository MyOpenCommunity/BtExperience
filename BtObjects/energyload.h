#ifndef ENERGYLOAD_H
#define ENERGYLOAD_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

class LoadsDevice;


/*!
	\ingroup EnergyManagement
	\brief Reads the electricity load status of a monitored object

	The monitored object can be consuming a normal amount of power, an higher than
	normal amount of power and a critical/fault status.

	The object id is \a ObjectInterface::IdEnergyLoad, the object key is empty.
*/
class EnergyLoadManagement : public ObjectInterface
{
	friend class TestEnergyLoadManagement;

	Q_OBJECT

	/*!
		\brief The ok/warning/critical status of the device
	*/
	Q_PROPERTY(LoadStatus status READ getStatus NOTIFY statusChanged)

	Q_ENUMS(LoadStatus)

public:
	enum LoadStatus
	{
		Unknown = 0,
		Ok = 1,
		Warning,
		Critical
	};

	EnergyLoadManagement(LoadsDevice *dev, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdEnergyLoad;
	}

	virtual QString getObjectKey() const
	{
		return QString();
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::EnergyManagement;
	}

	virtual QString getName() const
	{
		return name;
	}

	LoadStatus getStatus() const;

signals:
	void statusChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	LoadsDevice *dev;
	QString name;
	LoadStatus status;
};

#endif
