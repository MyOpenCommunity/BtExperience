#include "thermalprobes.h"
#include "scaleconversion.h" // bt2Celsius
#include "probe_device.h"

#include <QDebug>


ThermalControlledProbe::ThermalControlledProbe(QString _name, QString _key, ControlledProbeDevice *d)
{
	name = _name;
	key = _key;
	probe_status = Unknown;
	temperature = 0;
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
	return probe_status;
}

void ThermalControlledProbe::setProbeStatus(ProbeStatus st)
{
	if (st == probe_status)
		return;

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

int ThermalControlledProbe::getTemperature() const
{
	return bt2Celsius(temperature);
}

void ThermalControlledProbe::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == ControlledProbeDevice::DIM_STATUS)
		{
			qDebug() << "ThermalControlledProbe status changed: " << it.value().toInt();
			if (probe_status != it.value().toInt())
			{
				probe_status = static_cast<ProbeStatus>(it.value().toInt());
				emit probeStatusChanged();
			}
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
