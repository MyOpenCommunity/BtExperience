#include "thermalprobes.h"
#include "scaleconversion.h" // bt2Celsius
#include "probe_device.h"
#include "thermal_device.h" // for min/max manual temps
#include "xmlobject.h"
#include "devices_cache.h"

#include <QDebug>


QList<ObjectPair> parseExternalNonControlledProbes(const QDomNode &obj, ObjectInterface::ObjectId type)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);
	NonControlledProbeDevice::ProbeType probe_type = type == ObjectInterface::IdThermalExternalProbe ? NonControlledProbeDevice::EXTERNAL : NonControlledProbeDevice::INTERNAL;

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		NonControlledProbeDevice *d = bt_global::add_device_to_cache(new NonControlledProbeDevice(v.value("where"), probe_type));
		obj_list << ObjectPair(uii, new ThermalNonControlledProbe(v.value("descr"), "", type, d));
	}
	return obj_list;
}

ThermalNonControlledProbe::ThermalNonControlledProbe(QString _name, QString _key, ObjectId _object_id, NonControlledProbeDevice *_dev)
{
	name = _name;
	key = _key;
	object_id = _object_id;
	dev = _dev;

	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));
}

QString ThermalNonControlledProbe::getObjectKey() const
{
	return key;
}

int ThermalNonControlledProbe::getTemperature() const
{
	return bt2Celsius(temperature);
}

void ThermalNonControlledProbe::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == NonControlledProbeDevice::DIM_TEMPERATURE)
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


ThermalControlledProbe::ThermalControlledProbe(QString _name, QString _key, CentralType _central_type, ControlledProbeDevice *d)
{
	name = _name;
	key = _key;
	plant_status = Unknown;
	local_status = Normal;
	temperature = local_offset = 0;
	central_type = _central_type;
	// TODO for now, min/max manual temps are retrieved by fake devices
	if (central_type == CentralUnit99Zones)
	{
		ThermalDevice99Zones cu("0");
		minimumManualTemperature = cu.minimumTemp();
		maximumManualTemperature = cu.maximumTemp();
	}
	else
	{
		ThermalDevice4Zones cu("0#1");
		minimumManualTemperature = cu.minimumTemp();
		maximumManualTemperature = cu.maximumTemp();
	}
	setpoint = (minimumManualTemperature + maximumManualTemperature) / 2;
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
	if ((sp < getMinimumManualTemperature()) || (sp > getMaximumManualTemperature()))
		dev->setManual(setpoint);
	else
		dev->setManual(celsius2Bt(sp));
}

int ThermalControlledProbe::getLocalOffset() const
{
	return local_offset;
}

ThermalControlledProbe::CentralType ThermalControlledProbe::getCentralType() const
{
	return central_type;
}

int ThermalControlledProbe::getTemperature() const
{
	return bt2Celsius(temperature);
}

int ThermalControlledProbe::getMinimumManualTemperature() const
{
	return bt2Celsius(minimumManualTemperature);
}

int ThermalControlledProbe::getMaximumManualTemperature() const
{
	return bt2Celsius(maximumManualTemperature);
}

void ThermalControlledProbe::valueReceived(const DeviceValues &values_list)
{
	ProbeStatus old_status = getProbeStatus();

	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == ControlledProbeDevice::DIM_STATUS)
		{
			if (plant_status != it.value().toInt())
			{
				plant_status = static_cast<ProbeStatus>(it.value().toInt());
			}
		}
		else if (it.key() == ControlledProbeDevice::DIM_LOCAL_STATUS)
		{
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


ThermalControlledProbeFancoil::ThermalControlledProbeFancoil(QString _name, QString _key, CentralType central_type, ControlledProbeDevice *d) :
	ThermalControlledProbe(_name, _key, central_type, d)
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
