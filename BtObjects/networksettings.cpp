#include "networksettings.h"
#include "platform_device.h"

#include <QDebug>


NetworkSettings::NetworkSettings(PlatformDevice *d)
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

QString NetworkSettings::getObjectKey() const
{
	return "";
}

QString NetworkSettings::getName() const
{
	return "";
}

QString NetworkSettings::getAddress() const
{
	return address;
}

void NetworkSettings::setAddress(QString a)
{
	qDebug() << QString("NetworkSettings::setAddress(%1)").arg(a);
	// TODO set the value on the device
	address = a;
}

QString NetworkSettings::getDns() const
{
	return dns;
}

void NetworkSettings::setDns(QString d)
{
	qDebug() << QString("NetworkSettings::setDns(%1)").arg(d);
	// TODO set the value on the device
	dns = d;
}

QString NetworkSettings::getGateway() const
{
	return gateway;
}

void NetworkSettings::setGateway(QString g)
{
	qDebug() << QString("NetworkSettings::setGateway(%1)").arg(g);
	// TODO set the value on the device
	gateway = g;
}

QString NetworkSettings::getMac() const
{
	return mac;
}

QString NetworkSettings::getSubnet() const
{
	return subnet;
}

void NetworkSettings::setSubnet(QString s)
{
	qDebug() << QString("NetworkSettings::setSubnet(%1)").arg(s);
	// TODO set the value on the device
	subnet = s;
}

void NetworkSettings::valueReceived(const DeviceValues &values_list)
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
