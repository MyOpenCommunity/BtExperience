#include "platform.h"
#include "platform_device.h"

#include <QDebug>


namespace {
	QString unknown = QString("UNKNOWN"); // maybe empty string?
}

PlatformSettings::PlatformSettings(PlatformDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	// initial values
	address = unknown;
	dns = unknown;
	firmware = unknown;
	gateway = unknown;
	lan_config = Unknown;
	lan_status = Disabled; // at start, we assume network is disabled
	mac = unknown;
	serial_number = unknown;
	software = unknown;
	subnet = unknown;
}

QString PlatformSettings::getAddress() const
{
	return address;
}

void PlatformSettings::setAddress(QString a)
{
	qDebug() << QString("PlatformSettings::setAddress(%1)").arg(a);
	// TODO set the value on the device
	address = a;
}

QString PlatformSettings::getDns() const
{
	return dns;
}

void PlatformSettings::setDns(QString d)
{
	qDebug() << QString("PlatformSettings::setDns(%1)").arg(d);
	// TODO set the value on the device
	dns = d;
}

QString PlatformSettings::getFirmware() const
{
	return firmware;
}

QString PlatformSettings::getGateway() const
{
	return gateway;
}

void PlatformSettings::setGateway(QString g)
{
	qDebug() << QString("PlatformSettings::setGateway(%1)").arg(g);
	// TODO set the value on the device
	gateway = g;
}

PlatformSettings::LanConfig PlatformSettings::getLanConfig() const
{
	return lan_config;
}

void PlatformSettings::setLanConfig(LanConfig lc)
{
	if (lc == lan_config)
		return;

	// TODO set the value on the device
	switch (lc)
	{
	case Dhcp:
		break;
	case Static:
		break;
	case Unknown:
		qWarning() << "Are you sure you want to set config to Unknown?";
		break;
	default:
		qWarning() << "Unhandled config: " << lc;
	}
	lan_config = lc;
}

PlatformSettings::LanStatus PlatformSettings::getLanStatus() const
{
	return lan_status;
}

void PlatformSettings::setLanStatus(LanStatus ls)
{
	if (ls == lan_status)
		return;

	switch (ls)
	{
	case Enabled:
		dev->enableLan(true);
		break;
	case Disabled:
		dev->enableLan(false);
		break;
	default:
		qWarning() << "Unhandled status: " << ls;
	}
}

QString PlatformSettings::getMac() const
{
	return mac;
}

QString PlatformSettings::getSerialNumber() const
{
	return serial_number;
}

QString PlatformSettings::getSoftware() const
{
	return software;
}

QString PlatformSettings::getSubnet() const
{
	return subnet;
}

void PlatformSettings::setSubnet(QString s)
{
	qDebug() << QString("PlatformSettings::setSubnet(%1)").arg(s);
	// TODO set the value on the device
	subnet = s;
}

void PlatformSettings::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case PlatformDevice::DIM_IP:
			if (it.value().toString() != address)
			{
				address = it.value().toString();
				emit addressChanged();
			}
			break;
		case PlatformDevice::DIM_DNS1:
			if (it.value().toString() != dns)
			{
				dns = it.value().toString();
				emit dnsChanged();
			}
			break;
		case PlatformDevice::DIM_FW_VERS:
			if (it.value().toString() != firmware)
			{
				firmware = it.value().toString();
				emit firmwareChanged();
			}
			break;
		// TODO kernel == software is a guess of mine: check it is right!
		case PlatformDevice::DIM_KERN_VERS:
			if (it.value().toString() != software)
			{
				software = it.value().toString();
				emit softwareChanged();
			}
			break;
		// TODO discover how to retrieve serial number information
//		case PlatformDevice::DIM_PIC_VERS:
//			if (it.value().toString() != serial_number)
//			{
//				serial_number = it.value().toString();
//				emit serialNumberChanged();
//			}
//			break;
		case PlatformDevice::DIM_GATEWAY:
			if (it.value().toString() != gateway)
			{
				gateway = it.value().toString();
				emit gatewayChanged();
			}
			break;
		case PlatformDevice::DIM_MACADDR:
			if (it.value().toString() != mac)
			{
				mac = it.value().toString();
				emit macChanged();
			}
			break;
		case PlatformDevice::DIM_STATUS:
			if (it.value().toInt() != lan_status)
			{
				lan_status = static_cast<LanStatus>(it.value().toInt());
				emit lanStatusChanged();
			}
			break;
		// TODO use the right value (when defined)
		//case PlatformDevice::DIM_CONFIG:
		case 111111:
			if (it.value().toInt() != lan_config)
			{
				lan_config = static_cast<LanConfig>(it.value().toInt());
				emit lanConfigChanged();
			}
			break;
		case PlatformDevice::DIM_NETMASK:
			if (it.value().toString() != subnet)
			{
				subnet = it.value().toString();
				emit subnetChanged();
			}
			break;
		}
		++it;
	}
}
