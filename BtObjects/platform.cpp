#include "platform.h"
#include "platform_device.h"

#include <QDebug>


Platform::Platform(PlatformDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	// initial values
	address = "UNKNOWN";
	dns = "UNKNOWN";
	firmware = "UNKNOWN";
	gateway = "UNKNOWN";
	lan_config = Unknown;
	lan_status = Disabled; // at start, we assume network is disabled
	mac = "UNKNOWN";
	subnet = "UNKNOWN";
	connect(this, SIGNAL(addressChanged()), this, SIGNAL(dataChanged()));
}

QString Platform::getAddress() const
{
	return address;
}

void Platform::setAddress(QString a)
{
	qDebug() << QString("Platform::setAddress(%1)").arg(a);
	// TODO set the value on the device
	address = a;
}

QString Platform::getDns() const
{
	return dns;
}

void Platform::setDns(QString d)
{
	qDebug() << QString("Platform::setDns(%1)").arg(d);
	// TODO set the value on the device
	dns = d;
}

QString Platform::getFirmware() const
{
	return firmware;
}

QString Platform::getGateway() const
{
	return gateway;
}

void Platform::setGateway(QString g)
{
	qDebug() << QString("Platform::setGateway(%1)").arg(g);
	// TODO set the value on the device
	gateway = g;
}

Platform::LanConfig Platform::getLanConfig() const
{
	return lan_config;
}

void Platform::setLanConfig(LanConfig lc)
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

Platform::LanStatus Platform::getLanStatus() const
{
	return lan_status;
}

void Platform::setLanStatus(LanStatus ls)
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

QString Platform::getMac() const
{
	return mac;
}

QString Platform::getSubnet() const
{
	return subnet;
}

void Platform::setSubnet(QString s)
{
	qDebug() << QString("Platform::setSubnet(%1)").arg(s);
	// TODO set the value on the device
	subnet = s;
}

void Platform::valueReceived(const DeviceValues &values_list)
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
				firmware= it.value().toString();
				emit firmwareChanged();
			}
			break;
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
