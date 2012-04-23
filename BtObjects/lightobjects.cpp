#include "lightobjects.h"
#include "lighting_device.h"

#include <QDebug>


Light::Light(QString _name, QString _key, LightingDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	key = _key;
	name = _name;
	active = false; // initial value
	connect(this, SIGNAL(activeChanged()), this, SIGNAL(dataChanged()));
}

QString Light::getObjectKey() const
{
	return key;
}

QString Light::getName() const
{
	return name;
}

bool Light::isActive() const
{
	return active;
}

void Light::setActive(bool st)
{
	qDebug() << "Light::setActive";
	if (st)
		dev->turnOn();
	else
		dev->turnOff();
}

void Light::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == LightingDevice::DIM_DEVICE_ON)
		{
			if (it.value().toBool() != active)
			{
				active = it.value().toBool() == true;

				emit activeChanged();
				break;
			}
		}
		++it;
	}
}


Dimmer::Dimmer(QString name, QString key, DimmerDevice *d) : Light(name, key, d)
{
	dev = d;
	percentage = 50; // initial value
	connect(this, SIGNAL(percentageChanged()), this, SIGNAL(dataChanged()));
}

int Dimmer::getPercentage() const
{
	return percentage;
}

void Dimmer::decreaseLevel()
{
	dev->decreaseLevel();
}

void Dimmer::increaseLevel()
{
	dev->increaseLevel();
}

void Dimmer::valueReceived(const DeviceValues &values_list)
{
	Light::valueReceived(values_list);
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == LightingDevice::DIM_DIMMER_LEVEL)
		{
			int val = dimmerLevelTo100(it.value().toInt());
			if (percentage != val)
			{
				percentage = val;
				emit percentageChanged();
			}
		}
		++it;
	}
}
