#ifndef LIGHTOBJECTS_H
#define LIGHTOBJECTS_H

#include <QObject>

#include "objectinterface.h"
#include "device.h" // DeviceValues

class LightingDevice;
class DimmerDevice;


class Light : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(bool status READ getStatus WRITE setStatus NOTIFY statusChanged)

public:
	Light(QString name, QString key, LightingDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdLight;
	}

	virtual QString getObjectKey() const;

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Lighting;
	}

	virtual QString getName() const;
	virtual bool getStatus() const;
	virtual void setStatus(bool st);

signals:
	void statusChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString name;
	QString key;
	bool status;

private:
	LightingDevice *dev;
};


class Dimmer : public Light
{
	Q_OBJECT
	Q_PROPERTY(int percentage READ getPercentage WRITE setPercentage NOTIFY percentageChanged)

public:
	Dimmer(QString name, QString key, DimmerDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDimmer;
	}

	virtual int getPercentage() const;
	virtual void setPercentage(int val);

signals:
	void percentageChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	int percentage;

private:
	DimmerDevice *dev;
};


#endif // LIGHTOBJECTS_H

