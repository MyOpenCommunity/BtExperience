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
	mac = "UNKNOWN";
	subnet = "UNKNOWN";
	connect(this, SIGNAL(addressChanged()), this, SIGNAL(dataChanged()));
}

QString Network::getObjectKey() const
{
	return "";
}

QString Network::getName() const
{
	return "";
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
	DeviceValues::const_iterator it = values_list.begin();
	while (it != values_list.constEnd())
	{
		QString s = it.value().toString();
		switch (it.key())
		{
		case PlatformDevice::DIM_IP:
			if (s != address)
			{
				address = s;
				emit addressChanged();
			}
			break;
		case PlatformDevice::DIM_DNS1:
			if (s != dns)
			{
				dns = s;
				emit dnsChanged();
			}
			break;
		case PlatformDevice::DIM_GATEWAY:
			if (s != gateway)
			{
				gateway = s;
				emit gatewayChanged();
			}
			break;
		case PlatformDevice::DIM_MACADDR:
			if (s != mac)
			{
				mac = s;
				emit macChanged();
			}
			break;
		case PlatformDevice::DIM_NETMASK:
			if (s != subnet)
			{
				subnet = s;
				emit subnetChanged();
			}
			break;
		}
		++it;
	}
}
