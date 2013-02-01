#include "platform.h"
#include "platform_device.h"
#include "connectiontester.h"
#include "configfile.h"

#include <QDebug>
#include <QDate>


enum
{
	LAN_CONFIG,
	LAN_ADDRESS,
	LAN_NETMASK,
	LAN_GATEWAY,
	LAN_DNS1,
	LAN_DNS2,
	BT_TIME,
	BT_DATE
};


PlatformSettings::PlatformSettings(PlatformDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	current[BT_DATE] = QDate::currentDate();
	QVariant v;
	BtTime bt(QTime::currentTime());
	v.setValue(bt);
	current[BT_TIME] = v;

	configurations = new ConfigFile(this);

	QDomDocument conf = configurations->getConfiguration(CONF_FILE);

	// initial values
	current[LAN_CONFIG] = getConfValue(conf, "ethernet/lan/mode").toInt() == 1 ? Dhcp : Static;
	lan_status = Disabled; // at start, we assume network is disabled

	connection_status = Testing;
	connection_tester = new ConnectionTester(this);
	connect(connection_tester, SIGNAL(testFailed()), this, SLOT(connectionDown()));
	connect(connection_tester, SIGNAL(testPassed()), this, SLOT(connectionUp()));

	to_apply = current;
}

void PlatformSettings::apply()
{
	// when applying changes to date and time order is important!
	// applying date before time (when both need updating) leads to only
	// the date to be applied; applying changes in order time->date works
	// as expected
	if (to_apply[BT_TIME] != current[BT_TIME])
	{
		BtTime t = to_apply[BT_TIME].value<BtTime>();
		t = t.addSecond(-t.second()); // resetting seconds to zero
		dev->setTime(t);
	}

	if (to_apply[BT_DATE] != current[BT_DATE])
		dev->setDate(to_apply[BT_DATE].toDate());

	current = to_apply;

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
	to_apply = current;
	current[BT_DATE] = QDate::currentDate();
	current[BT_TIME].setValue(BtTime(QTime::currentTime()));

	emit addressChanged();
	emit dns1Changed();
	emit dns2Changed();
	emit gatewayChanged();
	emit lanConfigChanged();
	emit subnetChanged();
	emit connectionStatusChanged();
	emit hoursChanged();
	emit minutesChanged();
	emit secondsChanged();
	emit daysChanged();
	emit monthsChanged();
	emit yearsChanged();
}

QString PlatformSettings::getAddress() const
{
	return to_apply[LAN_ADDRESS].toString();
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
	return to_apply[LAN_DNS1].toString();
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
	return to_apply[LAN_DNS2].toString();
}

void PlatformSettings::setDns2(QString d)
{
	if (d == getDns2())
		return;
	to_apply[LAN_DNS2] = d;
	emit dns2Changed();
}

QString PlatformSettings::getFirmwareVersion() const
{
	return firmware_version;
}

QString PlatformSettings::getGateway() const
{
	return to_apply[LAN_GATEWAY].toString();
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
	return static_cast<LanConfig>(to_apply[LAN_CONFIG].toInt());
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

QString PlatformSettings::getKernelVersion() const
{
	return kernel_version;
}

QString PlatformSettings::getSubnet() const
{
	return to_apply[LAN_NETMASK].toString();
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
				to_apply[LAN_ADDRESS] = current[LAN_ADDRESS] = it.value();
				emit addressChanged();
			}
			break;
		case PlatformDevice::DIM_DNS1:
			if (it.value() != current[LAN_DNS1])
			{
				to_apply[LAN_DNS1] = current[LAN_DNS1] = it.value();
				emit dns1Changed();
			}
			break;
		case PlatformDevice::DIM_DNS2:
			if (it.value() != current[LAN_DNS2])
			{
				to_apply[LAN_DNS2] = current[LAN_DNS2] = it.value();
				emit dns2Changed();
			}
			break;
		case PlatformDevice::DIM_FW_VERS:
			if (it.value().toString() != firmware_version)
			{
				firmware_version = it.value().toString();
				emit firmwareVersionChanged();
			}
			break;
		case PlatformDevice::DIM_KERN_VERS:
			if (it.value().toString() != kernel_version)
			{
				kernel_version = it.value().toString();
				emit kernelVersionChanged();
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
				to_apply[LAN_GATEWAY] = current[LAN_GATEWAY] = it.value();
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
				to_apply[LAN_NETMASK] = current[LAN_NETMASK] = it.value();
				emit subnetChanged();
			}
			break;
		}
		++it;
	}

	if (values_list.contains(PlatformDevice::DIM_DATE) ||
		values_list.contains(PlatformDevice::DIM_TIME))
		emit systemTimeChanged();
}

void PlatformSettings::emitDateSignals(QDate oldDate, QDate newDate)
{
	if (!oldDate.isValid() && newDate.isValid())
	{
		emit daysChanged();
		emit monthsChanged();
		emit yearsChanged();
		return;
	}
	if (oldDate.day() != newDate.day())
		emit daysChanged();
	if (oldDate.month() != newDate.month())
		emit monthsChanged();
	if (oldDate.year() != newDate.year())
		emit yearsChanged();
}

void PlatformSettings::emitTimeSignals(QVariant oldTime, QVariant newTime)
{
	BtTime oldBtTime, newBtTime;
	oldBtTime = oldTime.value<BtTime>();
	newBtTime = newTime.value<BtTime>();

	if (oldBtTime.hour() != newBtTime.hour())
		emit hoursChanged();
	if (oldBtTime.minute() != newBtTime.minute())
		emit minutesChanged();
	if (oldBtTime.second() != newBtTime.second())
		emit secondsChanged();
}

int PlatformSettings::toHours(const QVariant &btTime) const
{
	BtTime t;
	t = btTime.value<BtTime>();
	return t.hour();
}

int PlatformSettings::toMinutes(const QVariant &btTime) const
{
	BtTime t;
	t = btTime.value<BtTime>();
	return t.minute();
}

int PlatformSettings::toSeconds(const QVariant &btTime) const
{
	BtTime t;
	t = btTime.value<BtTime>();
	return t.second();
}

int PlatformSettings::getHours() const
{
	return toHours(to_apply[BT_TIME]);
}

void PlatformSettings::setHours(int newValue)
{
	int oldValue = getHours();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;

	QVariant time = to_apply[BT_TIME];
	to_apply[BT_TIME].setValue(to_apply[BT_TIME].value<BtTime>().addSecond(diff * 60 * 60));

	emitTimeSignals(time, to_apply[BT_TIME]);
}

int PlatformSettings::getMinutes() const
{
	return toMinutes(to_apply[BT_TIME]);
}

void PlatformSettings::setMinutes(int newValue)
{
	int oldValue = getMinutes();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;

	QVariant time = to_apply[BT_TIME];
	to_apply[BT_TIME].setValue(to_apply[BT_TIME].value<BtTime>().addSecond(diff * 60));

	emitTimeSignals(time, to_apply[BT_TIME]);
}

int PlatformSettings::getSeconds() const
{
	return toSeconds(to_apply[BT_TIME]);
}

void PlatformSettings::setSeconds(int newValue)
{
	int oldValue = getSeconds();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;

	QVariant time = to_apply[BT_TIME];
	to_apply[BT_TIME].setValue(to_apply[BT_TIME].value<BtTime>().addSecond(diff));

	emitTimeSignals(time, to_apply[BT_TIME]);
}

int PlatformSettings::getDays() const
{
	const QDate &date = to_apply[BT_DATE].toDate();
	return date.day();
}

void PlatformSettings::setDays(int newValue)
{
	QDate date = to_apply[BT_DATE].toDate();
	int oldValue = date.day();
	if ((newValue - oldValue) == 0)
		return;
	QDate newDate = date.addDays(newValue - oldValue);
	to_apply[BT_DATE] = newDate;
	emitDateSignals(date, newDate);
}

int PlatformSettings::getMonths() const
{
	const QDate &date = to_apply[BT_DATE].toDate();
	return date.month();
}

void PlatformSettings::setMonths(int newValue)
{
	QDate date = to_apply[BT_DATE].toDate();
	int oldValue = date.month();
	if ((newValue - oldValue) == 0)
		return;
	QDate newDate = date.addMonths(newValue - oldValue);
	to_apply[BT_DATE] = newDate;
	emitDateSignals(date, newDate);
}

int PlatformSettings::getYears() const
{
	const QDate &date = to_apply[BT_DATE].toDate();
	return date.year();
}

void PlatformSettings::setYears(int newValue)
{
	QDate date = to_apply[BT_DATE].toDate();
	int oldValue = date.year();
	if ((newValue - oldValue) == 0)
		return;
	QDate newDate = date.isValid() ? date.addYears(newValue - oldValue) : QDate(newValue, 1, 1);
	to_apply[BT_DATE] = newDate;
	emitDateSignals(date, newDate);
}
