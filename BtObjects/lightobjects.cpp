#include "lightobjects.h"
#include "lighting_device.h"
#include "xml_functions.h"
#include "devices_cache.h"

#include <QDebug>

QList<ObjectPair> parseDimmer(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");
	int def_pul = getIntAttribute(obj, "pul");
	QString def_ftime = getAttribute(obj, "ftime");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		QString ftime = getAttribute(ist, "ftime", def_ftime);

		DimmerDevice *d = bt_global::add_device_to_cache(new DimmerDevice(where, pul));
		obj_list << ObjectPair(uii, new Dimmer(descr, where, d));
	}
	return obj_list;
}

QList<ObjectPair> parseLight(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");
	int def_pul = getIntAttribute(obj, "pul");
	QString def_ftime = getAttribute(obj, "ftime");
	QString def_ctime = getAttribute(obj, "ctime");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		QString ftime = getAttribute(ist, "ftime", def_ftime);
		QString ctime = getAttribute(ist, "ctime", def_ctime);

		LightingDevice *d = bt_global::add_device_to_cache(new LightingDevice(where, pul));
		obj_list << ObjectPair(uii, new Light(descr, where, d));
	}
	return obj_list;
}


Light::Light(QString _name, QString _key, LightingDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	key = _key;
	name = _name;
	category = ObjectInterface::Unassigned;
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

void Light::setCategory(ObjectInterface::ObjectCategory _category)
{
	category = _category;
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
