#include "thermalprobes.h"
#include "scaleconversion.h" // bt2Celsius
#include "probe_device.h"

#include <QDebug>


ThermalControlledProbe::ThermalControlledProbe(QString _name, QString _key, ControlledProbeDevice *d)
{
	name = _name;
	key = _key;
	plant_status = Unknown;
	local_status = Normal;
	temperature = local_offset = 0;
	setpoint = 0;
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

QString ThermalControlledProbe::getObjectKey() const
{
	return key;
}

ThermalControlledProbe::ProbeStatus ThermalControlledProbe::getProbeStatus() const
{
	return local_status == Normal ? plant_status : local_status;
}

ThermalControlledProbe::ProbeStatus ThermalControlledProbe::getLocalProbeStatus() const
{
	return local_status;
}

void ThermalControlledProbe::setProbeStatus(ProbeStatus st)
{
	switch (st)
	{
	case Manual:
		dev->setManual(setpoint);
		break;
	case Auto:
		dev->setAutomatic();
		break;
	case Antifreeze:
		dev->setProtection();
		break;
	case Off:
		dev->setOff();
		break;
	default:
		qWarning() << "Unhandled status: " << st;
	}
}

int ThermalControlledProbe::getSetpoint() const
{
	return bt2Celsius(setpoint);
}

void ThermalControlledProbe::setSetpoint(int sp)
{
	if (celsius2Bt(sp) != static_cast<unsigned>(setpoint))
		dev->setManual(celsius2Bt(sp));
}

int ThermalControlledProbe::getLocalOffset() const
{
	return bt2Celsius(local_offset);
}

int ThermalControlledProbe::getTemperature() const
{
	return bt2Celsius(temperature);
}

void ThermalControlledProbe::valueReceived(const DeviceValues &values_list)
{
	ProbeStatus old_status = getProbeStatus();

	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == ControlledProbeDevice::DIM_STATUS)
		{
			qDebug() << "ThermalControlledProbe status changed: " << it.value().toInt();
			if (plant_status != it.value().toInt())
			{
				plant_status = static_cast<ProbeStatus>(it.value().toInt());
			}
		}
		else if (it.key() == ControlledProbeDevice::DIM_LOCAL_STATUS)
		{
			qDebug() << "ThermalControlledProbe local status changed: " << it.value().toInt();
			int old_offset = local_offset;

			if (it.value().toInt() == Normal)
				local_offset = values_list[ControlledProbeDevice::DIM_OFFSET].toInt();
			else
				local_offset = 0;

			if (local_status != it.value().toInt())
			{
				local_status = static_cast<ProbeStatus>(it.value().toInt());
				emit localProbeStatusChanged();
			}

			if (old_offset != local_offset)
				emit localOffsetChanged();
		}
		else if (it.key() == ControlledProbeDevice::DIM_SETPOINT)
		{
			if (setpoint != it.value().toInt())
			{
				setpoint = it.value().toInt();
				emit setpointChanged();
			}
		}
		else if (it.key() == ControlledProbeDevice::DIM_TEMPERATURE)
		{
			if (temperature != it.value().toInt())
			{
				temperature = it.value().toInt();
				emit temperatureChanged();
			}
		}

		++it;
	}

	if (old_status != getProbeStatus())
		emit probeStatusChanged();
}


ThermalControlledProbeFancoil::ThermalControlledProbeFancoil(QString _name, QString _key, ControlledProbeDevice *d) :
	ThermalControlledProbe(_name, _key, d)
{
	fancoil_speed = FancoilAuto;
}

void ThermalControlledProbeFancoil::setFancoil(FancoilSpeed s)
{
	dev->setFancoilSpeed(static_cast<int>(s));
}

ThermalControlledProbeFancoil::FancoilSpeed ThermalControlledProbeFancoil::getFancoil() const
{
	return fancoil_speed;
}

void ThermalControlledProbeFancoil::valueReceived(const DeviceValues &values_list)
{
	ThermalControlledProbe::valueReceived(values_list);

	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == ControlledProbeDevice::DIM_FANCOIL_STATUS)
		{
			if (fancoil_speed != it.value().toInt())
			{
				fancoil_speed = static_cast<FancoilSpeed>(it.value().toInt());
				emit fancoilChanged();
			}
		}

		++it;
	}
}
