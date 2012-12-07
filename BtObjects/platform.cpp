#include "platform.h"
#include "platform_device.h"
#include "connectiontester.h"
#include "configfile.h"

#include <QDebug>


enum
{
	LAN_CONFIG,
	LAN_ADDRESS,
	LAN_NETMASK,
	LAN_GATEWAY,
	LAN_DNS1,
	LAN_DNS2
};


PlatformSettings::PlatformSettings(PlatformDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	configurations = new ConfigFile(this);

	QDomDocument conf = configurations->getConfiguration(CONF_FILE);

	// initial values
	current[LAN_CONFIG] = getConfValue(conf, "ethernet/lan/mode").toInt() == 1 ? Dhcp : Static;
	lan_status = Disabled; // at start, we assume network is disabled

	connection_status = Testing;
	connection_tester = new ConnectionTester(this);
	connect(connection_tester, SIGNAL(testFailed()), this, SLOT(connectionDown()));
	connect(connection_tester, SIGNAL(testPassed()), this, SLOT(connectionUp()));
}

QVariant PlatformSettings::value(int id) const
{
	return to_apply.value(id, current.value(id));
}

void PlatformSettings::apply()
{
	if (to_apply.count() == 0)
		return;
	foreach (int k, to_apply.keys())
		current[k] = to_apply[k];
	to_apply.clear();

	QDomDocument conf = configurations->getConfiguration(CONF_FILE);

	setConfValue(conf, "ethernet/lan/mode", QString::number(getLanConfig() == Dhcp ? 1 : 2));
	setConfValue(conf, "ethernet/lan/addressip", getAddress());
	setConfValue(conf, "ethernet/lan/netmask", getSubnet());
	setConfValue(conf, "ethernet/lan/router", getGateway());
	setConfValue(conf, "ethernet/lan/dnspri", getDns1());
	setConfValue(conf, "ethernet/lan/dnssec", getDns2());

	configurations->saveConfiguration(CONF_FILE);
}

void PlatformSettings::reset()
{
	to_apply.clear();
}

QString PlatformSettings::getAddress() const
{
	return value(LAN_ADDRESS).toString();
}

void PlatformSettings::setAddress(QString a)
{
	if (a == getAddress())
		return;
	to_apply[LAN_ADDRESS] = a;
	emit addressChanged();
}

QString PlatformSettings::getDns1() const
{
	return value(LAN_DNS1).toString();
}

void PlatformSettings::setDns1(QString d)
{
	if (d == getDns1())
		return;
	to_apply[LAN_DNS1] = d;
	emit dns1Changed();
}

QString PlatformSettings::getDns2() const
{
	return value(LAN_DNS2).toString();
}

void PlatformSettings::setDns2(QString d)
{
	if (d == getDns2())
		return;
	to_apply[LAN_DNS2] = d;
	emit dns2Changed();
}

QString PlatformSettings::getFirmware() const
{
	return firmware;
}

QString PlatformSettings::getGateway() const
{
	return value(LAN_GATEWAY).toString();
}

void PlatformSettings::setGateway(QString g)
{
	if (g == getGateway())
		return;
	to_apply[LAN_GATEWAY] = g;
	emit gatewayChanged();
}

PlatformSettings::LanConfig PlatformSettings::getLanConfig() const
{
	return static_cast<LanConfig>(value(LAN_CONFIG).toInt());
}

void PlatformSettings::setLanConfig(LanConfig lc)
{
	if (lc == getLanConfig())
		return;
	if (lc == Dhcp)
		reset();
	to_apply[LAN_CONFIG] = lc;
	emit lanConfigChanged();
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
	return value(LAN_NETMASK).toString();
}

void PlatformSettings::setSubnet(QString s)
{
	if (s == getSubnet())
		return;
	to_apply[LAN_NETMASK] = s;
	emit subnetChanged();
}

void PlatformSettings::setConnectionStatus(InternetConnectionStatus status)
{
	if (status == connection_status)
		return;
	connection_status = status;
	emit connectionStatusChanged();
}

PlatformSettings::InternetConnectionStatus PlatformSettings::getConnectionStatus() const
{
	return connection_status;
}

void PlatformSettings::requestNetworkSettings()
{
	dev->requestStatus();
	dev->requestIp();
	dev->requestNetmask();
	dev->requestMacAddress();
	dev->requestGateway();
	dev->requestDNS1();
	dev->requestDNS2();

	if (!connection_tester->isTesting() && lan_status != Disabled)
	{
		connection_attempts = 1;
		connection_attempts_delay = 0;
		setConnectionStatus(Testing);
		connection_tester->test();
	}
}

void PlatformSettings::connectionDown()
{
	--connection_attempts;
	if (connection_attempts > 0)
		QTimer::singleShot(connection_attempts_delay, connection_tester, SLOT(test()));
	else
		setConnectionStatus(Down);
}

void PlatformSettings::connectionUp()
{
	setConnectionStatus(Up);
}

void PlatformSettings::startConnectionTest()
{
	connection_attempts = 3;
	connection_attempts_delay = 10000;
	setConnectionStatus(Testing);
	QTimer::singleShot(connection_attempts_delay, connection_tester, SLOT(test()));
}

void PlatformSettings::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case PlatformDevice::DIM_IP:
			if (it.value() != current[LAN_ADDRESS])
			{
				current[LAN_ADDRESS] = it.value();
				emit addressChanged();
			}
			break;
		case PlatformDevice::DIM_DNS1:
			if (it.value() != current[LAN_DNS1])
			{
				current[LAN_DNS1] = it.value();
				emit dns1Changed();
			}
			break;
		case PlatformDevice::DIM_DNS2:
			if (it.value() != current[LAN_DNS2])
			{
				current[LAN_DNS2] = it.value();
				emit dns2Changed();
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
			if (it.value() != current[LAN_GATEWAY])
			{
				current[LAN_GATEWAY] = it.value();
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

				if (lan_status == Enabled)
					startConnectionTest();
				else
					setConnectionStatus(Down);
			}
			break;
		case PlatformDevice::DIM_NETMASK:
			if (it.value() != current[LAN_NETMASK])
			{
				current[LAN_NETMASK] = it.value();
				emit subnetChanged();
			}
			break;
		}
		++it;
	}
}
