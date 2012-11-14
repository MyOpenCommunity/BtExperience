#include "platform.h"
#include "platform_device.h"
#include "connectiontester.h"
#include "configfile.h"

#include <QDebug>

#if defined(BT_HARDWARE_X11)
#define CONF_FILE "conf.xml"
#else
#define CONF_FILE "/var/tmp/conf.xml"
#endif


namespace {
	QString unknown = QString("UNKNOWN"); // maybe empty string?
}

PlatformSettings::PlatformSettings(PlatformDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	configurations = new ConfigFile(this);

	QDomDocument conf = configurations->getConfiguration(CONF_FILE);

	// initial values
	address = unknown;
	dns = unknown;
	firmware = unknown;
	gateway = unknown;
	lan_config = getConfValue(conf, "ethernet/lan/mode").toInt() == 1 ? Dhcp : Static;
	lan_status = Disabled; // at start, we assume network is disabled
	mac = unknown;
	serial_number = unknown;
	software = unknown;
	subnet = unknown;

	connection_status = Testing;
	connection_tester = new ConnectionTester(this);
	connect(connection_tester, SIGNAL(testFailed()), this, SLOT(connectionDown()));
	connect(connection_tester, SIGNAL(testPassed()), this, SLOT(connectionUp()));
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
	lan_config = lc;
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
	return subnet;
}

void PlatformSettings::setSubnet(QString s)
{
	qDebug() << QString("PlatformSettings::setSubnet(%1)").arg(s);
	// TODO set the value on the device
	subnet = s;
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

				if (lan_status == Enabled)
					startConnectionTest();
				else
					setConnectionStatus(Down);
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
