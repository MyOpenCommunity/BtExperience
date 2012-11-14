#ifndef PLATFORM_H
#define PLATFORM_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>

class PlatformDevice;
class ConnectionTester;


/*!
	\ingroup Platform
	\brief Manages platform information and network settings

	Class to provide services to read and write network settings.
	Be aware network settings are writable only for static configuration.
	MAC address is always read-only.
	This class also provides information about the platform.
	In general, this class read and write settings independent from hardware.
	Settings in this file need a device to be managed.

	The object id is \a ObjectInterface::IdPlatformSettings.
*/
class PlatformSettings : public ObjectInterface
{
	friend class TestPlatformSettings;

	Q_OBJECT

	/*!
		\brief Sets and gets the IP address
	*/
	Q_PROPERTY(QString address READ getAddress WRITE setAddress NOTIFY addressChanged)

	/*!
		\brief Sets and gets the DNS address
	*/
	Q_PROPERTY(QString dns READ getDns WRITE setDns NOTIFY dnsChanged)

	/*!
		\brief Gets the firmware version.
	*/
	Q_PROPERTY(QString firmware READ getFirmware NOTIFY firmwareChanged)

	/*!
		\brief Sets and gets the gateway address
	*/
	Q_PROPERTY(QString gateway READ getGateway WRITE setGateway NOTIFY gatewayChanged)

	/*!
		\brief Gets the mac address
	*/
	Q_PROPERTY(QString mac READ getMac NOTIFY macChanged)

	/*!
		\brief Gets the serial number.
	*/
	Q_PROPERTY(QString serialNumber READ getSerialNumber NOTIFY serialNumberChanged)

	/*!
		\brief Gets the software version.
	*/
	Q_PROPERTY(QString software READ getSoftware NOTIFY softwareChanged)

	/*!
		\brief Sets and gets the subnet mask
	*/
	Q_PROPERTY(QString subnet READ getSubnet WRITE setSubnet NOTIFY subnetChanged)

	/*!
		\brief Sets or gets the configuration type of the LAN (DHCP, static IP)
	*/
	Q_PROPERTY(LanConfig lanConfig READ getLanConfig WRITE setLanConfig NOTIFY lanConfigChanged)

	/*!
		\brief Sets or gets the status of the network adapter
	*/
	Q_PROPERTY(LanStatus lanStatus READ getLanStatus WRITE setLanStatus NOTIFY lanStatusChanged)

	/*!
		\brief Sets or gets the status of the internet connection
	*/
	Q_PROPERTY(InternetConnectionStatus connectionStatus READ getConnectionStatus WRITE setConnectionStatus NOTIFY connectionStatusChanged)

	Q_ENUMS(LanConfig)
	Q_ENUMS(LanStatus)
	Q_ENUMS(InternetConnectionStatus)

public:
	PlatformSettings(PlatformDevice *d);

	enum LanConfig
	{
		Unknown,    /*!< No config received yet (only during initialization). */
		Dhcp,       /*!< Platform is configured by DHCP. */
		Static      /*!< Platform is statically configured. */
	};

	enum LanStatus
	{
		Disabled,   /*!< Platform adapter is disabled. */
		Enabled     /*!< Platform adapter is enabled. */
	};

	enum InternetConnectionStatus
	{
		Testing,    /*!< Unknown status. */
		Down,       /*!< Internet not reachable. */
		Up          /*!< Internet reachable. */
	};

	virtual int getObjectId() const
	{
		return ObjectInterface::IdPlatformSettings;
	}

	QString getAddress() const;
	void setAddress(QString a);
	QString getDns() const;
	void setDns(QString d);
	QString getFirmware() const;
	QString getGateway() const;
	void setGateway(QString g);
	LanConfig getLanConfig() const;
	void setLanConfig(LanConfig lc);
	LanStatus getLanStatus() const;
	void setLanStatus(LanStatus ls);
	QString getMac() const;
	QString getSerialNumber() const;
	QString getSoftware() const;
	QString getSubnet() const;
	void setSubnet(QString s);
	void setConnectionStatus(InternetConnectionStatus status);
	InternetConnectionStatus getConnectionStatus() const;

	Q_INVOKABLE void requestNetworkSettings();

signals:
	void addressChanged();
	void dnsChanged();
	void firmwareChanged();
	void gatewayChanged();
	void lanConfigChanged();
	void lanStatusChanged();
	void macChanged();
	void serialNumberChanged();
	void softwareChanged();
	void subnetChanged();
	void connectionStatusChanged();

private slots:
	void valueReceived(const DeviceValues &values_list);
	void connectionUp();
	void connectionDown();

private:
	void startConnectionTest();

	QString address;
	QString dns;
	QString firmware;
	QString gateway;
	LanConfig lan_config;
	LanStatus lan_status;
	QString mac;
	QString serial_number;
	QString software;
	QString subnet;
	PlatformDevice *dev;

	int connection_attempts;
	int connection_attempts_delay;
	InternetConnectionStatus connection_status;
	ConnectionTester *connection_tester;
};

#endif // PLATFORM_H
