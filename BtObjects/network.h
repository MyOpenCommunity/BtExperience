#ifndef NETWORK_H
#define NETWORK_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>

class PlatformDevice;


/*!
	\ingroup Network
	\brief Manages network settings

	Class to provide services to read and write network settings.
	Be aware network settings are writable only for static configuration.
	MAC address is always read-only.

	The object id is \a ObjectInterface::IdNetwork.
*/
class Network : public ObjectInterface
{
	friend class TestNetwork;

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
		\brief Sets and gets the gateway address
	*/
	Q_PROPERTY(QString gateway READ getGateway WRITE setGateway NOTIFY gatewayChanged)

	/*!
		\brief Gets the mac address
	*/
	Q_PROPERTY(QString mac READ getMac NOTIFY macChanged)

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

	Q_ENUMS(LanConfig)
	Q_ENUMS(LanStatus)

public:
	Network(PlatformDevice *d);

	enum LanConfig
	{
		Unknown,    /*!< No config received yet (only during initialization). */
		Dhcp,       /*!< Network is configured by DHCP. */
		Static      /*!< Network is statically configured. */
	};

	enum LanStatus
	{
		Unknown,    /*!< No state received yet (only during initialization). */
		Enabled,    /*!< Network adapter is enabled. */
		Disabled    /*!< Network adapter is disabled. */
	};

	virtual int getObjectId() const
	{
		return ObjectInterface::IdNetwork;
	}

	virtual QString getObjectKey() const
	{
		return QString();
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Settings;
	}

	virtual QString getName() const
	{
		return QString();
	}

	QString getAddress() const;
	void setAddress(QString a);
	QString getDns() const;
	void setDns(QString d);
	QString getGateway() const;
	void setGateway(QString g);
	LanConfig getLanConfig() const;
	void setLanConfig(LanConfig lc);
	LanStatus getLanStatus() const;
	void setLanStatus(LanStatus ls);
	QString getMac() const;
	QString getSubnet() const;
	void setSubnet(QString s);

signals:
	void addressChanged();
	void dnsChanged();
	void gatewayChanged();
	void lanConfigChanged();
	void lanStatusChanged();
	void macChanged();
	void subnetChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString address;
	QString dns;
	QString gateway;
	LanStatus lan_config;
	LanStatus lan_status;
	QString mac;
	QString subnet;

private:
	PlatformDevice *dev;
};

#endif // NETWORK_H
