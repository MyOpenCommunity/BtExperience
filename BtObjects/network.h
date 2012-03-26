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

public:
	Network(PlatformDevice *d);
	
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
	QString getMac() const;
	QString getSubnet() const;
	void setSubnet(QString s);

signals:
	void addressChanged();
	void dnsChanged();
	void gatewayChanged();
	void subnetChanged();
	void macChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString address;
	QString dns;
	QString gateway;
	QString mac;
	QString subnet;

private:
	PlatformDevice *dev;
};

#endif // NETWORK_H
