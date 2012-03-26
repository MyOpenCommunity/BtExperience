#include "network.h"
#include "platform_device.h"

#include <QDebug>


Network::Network(PlatformDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	// initial values
	address = "UNKNOWN";
	dns = "UNKNOWN";
	gateway = "UNKNOWN";
	lan_config = Unknown;
	lan_status = Unknown;
	mac = "UNKNOWN";
	subnet = "UNKNOWN";
	connect(this, SIGNAL(addressChanged()), this, SIGNAL(dataChanged()));
}

QString Network::getAddress() const
{
	return address;
}

void Network::setAddress(QString a)
{
	qDebug() << QString("Network::setAddress(%1)").arg(a);
	// TODO set the value on the device
	address = a;
}

QString Network::getDns() const
{
	return dns;
}

void Network::setDns(QString d)
{
	qDebug() << QString("Network::setDns(%1)").arg(d);
	// TODO set the value on the device
	dns = d;
}

QString Network::getGateway() const
{
	return gateway;
}

void Network::setGateway(QString g)
{
	qDebug() << QString("Network::setGateway(%1)").arg(g);
	// TODO set the value on the device
	gateway = g;
}

Network::LanConfig Network::getLanConfig() const
{
	return lan_config;
}

void Network::setLanConfig(LanConfig lc)
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

Network::LanStatus Network::getLanStatus() const
{
	return lan_status;
}

void Network::setLanStatus(LanStatus ls)
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
	case Unknown:
		qWarning() << "Are you sure you want to set status to Unknown?";
		break;
	default:
		qWarning() << "Unhandled status: " << ls;
	}
}

QString Network::getMac() const
{
	return mac;
}

QString Network::getSubnet() const
{
	return subnet;
}

void Network::setSubnet(QString s)
{
	qDebug() << QString("Network::setSubnet(%1)").arg(s);
	// TODO set the value on the device
	subnet = s;
}

void Network::valueReceived(const DeviceValues &values_list)
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
		case PlatformDevice::DIM_STATUS:
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
