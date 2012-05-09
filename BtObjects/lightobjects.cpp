#include "lightobjects.h"
#include "lighting_device.h"
#include "xml_functions.h"
#include "devices_cache.h"

#include <QDebug>

// default values
#define DIMMER100_STEP 5
#define DIMMER100_SPEED 255


QList<ObjectPair> parseDimmer100(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");
	int def_pul = getIntAttribute(obj, "pul");
	int def_sstart = getIntAttribute(obj, "sstart");
	int def_sstop = getIntAttribute(obj, "sstop");
	QString def_ftime = getAttribute(obj, "ftime");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		int sstart = getIntAttribute(obj, "sstart", def_sstart);
		int sstop = getIntAttribute(obj, "sstop", def_sstop);
		QString ftime = getAttribute(ist, "ftime", def_ftime);

		Dimmer100Device *d = bt_global::add_device_to_cache(new Dimmer100Device(where, pul));
		obj_list << ObjectPair(uii, new Dimmer100(descr, where, d, sstart, sstop));
	}
	return obj_list;
}

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
	percentage = 0; // initial value
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


Dimmer100::Dimmer100(QString name, QString key, Dimmer100Device *d, int onspeed, int offspeed) :
	Dimmer(name, key, d)
{
	dev = d;
	on_speed = onspeed;
	off_speed = offspeed;
	step_speed = DIMMER100_SPEED;
	step_amount = DIMMER100_STEP;
}

void Dimmer100::setOnSpeed(int speed)
{
	if (speed == on_speed)
		return;

	on_speed = speed;
	emit onSpeedChanged();
}

int Dimmer100::getOnSpeed() const
{
	return on_speed;
}

void Dimmer100::setOffSpeed(int speed)
{
	if (speed == off_speed)
		return;

	off_speed = speed;
	emit offSpeedChanged();
}

int Dimmer100::getOffSpeed() const
{
	return off_speed;
}

void Dimmer100::setStepSpeed(int speed)
{
	if (speed == step_speed)
		return;

	step_speed = speed;
	emit stepSpeedChanged();
}

int Dimmer100::getStepSpeed() const
{
	return step_speed;
}

void Dimmer100::setStepAmount(int amount)
{
	if (amount == step_amount)
		return;

	step_amount = amount;
	emit stepAmountChanged();
}

int Dimmer100::getStepAmount() const
{
	return step_amount;
}

void Dimmer100::setActive(bool st)
{
	if (st)
		dev->turnOn(on_speed);
	else
		dev->turnOff(off_speed);
}

void Dimmer100::increaseLevel100()
{
	dev->increaseLevel100(step_amount, step_speed);
}

void Dimmer100::decreaseLevel100()
{
	dev->decreaseLevel100(step_amount, step_speed);
}

void Dimmer100::valueReceived(const DeviceValues &values_list)
{
	// we do not call Dimmer::valueReceived to avoid emitting percentageChanged() twice, once
	// for DIM_DIMMER_LEVEL and again for DIM_DIMMER100_LEVEL
	Light::valueReceived(values_list);
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == LightingDevice::DIM_DIMMER100_LEVEL)
		{
			int val = it.value().toInt();
			if (percentage != val)
			{
				percentage = val;
				emit percentageChanged();
			}
		}
		++it;
	}
}
