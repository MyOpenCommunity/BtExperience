#ifndef ENERGYLOAD_H
#define ENERGYLOAD_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

class LoadsDevice;


class EnergyLoadDiagnostic : public ObjectInterface
{
	friend class TestEnergyLoadDiagnostic;

	Q_OBJECT
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

	EnergyLoadDiagnostic(LoadsDevice *dev, QString name);

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
