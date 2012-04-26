#include "energyload.h"

#include "loads_device.h"

namespace
{
	EnergyLoadDiagnostic::LoadStatus mapLoad(int level)
	{
		switch (level)
		{
		case LoadsDevice::LOAD_OK:
			return EnergyLoadDiagnostic::Ok;
		case LoadsDevice::LOAD_WARNING:
			return EnergyLoadDiagnostic::Warning;
		case LoadsDevice::LOAD_CRITICAL:
			return EnergyLoadDiagnostic::Critical;
		default:
			return EnergyLoadDiagnostic::Unknown;
		}
	}
}


EnergyLoadDiagnostic::EnergyLoadDiagnostic(LoadsDevice *_dev, QString _name)
{
	dev = _dev;
	name = _name;
	status = Unknown;

	connect(dev, SIGNAL(valueReceived(DeviceValues)),
		this, SLOT(valueReceived(DeviceValues)));
}

EnergyLoadDiagnostic::LoadStatus EnergyLoadDiagnostic::getStatus() const
{
	return status;
}

void EnergyLoadDiagnostic::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case LoadsDevice::DIM_LOAD:
			if (mapLoad(it.value().toInt()) != status)
			{
				status = mapLoad(it.value().toInt());
				emit statusChanged();
			}
			break;
		}
		++it;
	}
}
