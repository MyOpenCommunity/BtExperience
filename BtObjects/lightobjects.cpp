#include "lightobjects.h"
#include "lighting_device.h"
#include "xml_functions.h"
#include "devices_cache.h"
#include "uiimapper.h"

#include <QDebug>
#include <QStringList>

// default values
#define DIMMER100_STEP 5
#define DIMMER100_SPEED 255


namespace
{
	int findDumberObject(int first, int second)
	{
		if (first == ObjectInterface::IdLightCustom || second == ObjectInterface::IdLightCustom
			|| first == ObjectInterface::IdLightFixed || second == ObjectInterface::IdLightFixed)
			return ObjectInterface::IdLightFixed;
		if (first == ObjectInterface::IdLightCommand || second == ObjectInterface::IdLightCommand)
			return ObjectInterface::IdLightFixed;
		if (first == ObjectInterface::IdDimmerFixed || second == ObjectInterface::IdDimmerFixed)
			return ObjectInterface::IdDimmerFixed;
		if (first == ObjectInterface::IdDimmer100Custom || second == ObjectInterface::IdDimmer100Custom
			|| first == ObjectInterface::IdDimmer100Fixed || second == ObjectInterface::IdDimmer100Fixed)
			return ObjectInterface::IdDimmer100Fixed;

		Q_ASSERT_X(false, "findDumberObject", "Invalid light types in light group");

		return -1;
	}

	template<class Tr, class Ts>
	QList<Tr> convertQObjectList(QList<Ts> list)
	{
		QList<Tr> res;

		foreach (Ts i, list)
		{
			Tr r = qobject_cast<Tr>(i);

			Q_ASSERT_X(r, "convertQObjectList", "Invalid object type");

			if (r)
				res.append(r);
		}

		return res;
	}
}

QList<ObjectPair> parseDimmer100(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");
	int def_pul = getIntAttribute(obj, "pul");
	int def_sstart = getIntAttribute(obj, "sstart");
	int def_sstop = getIntAttribute(obj, "sstop");
	QTime def_ctime = getTimeAttribute(obj, "ctime");
	Light::FixedTimingType def_ftime = static_cast<Light::FixedTimingType>(getIntAttribute(obj, "ftime"));
	int def_ectime = getIntAttribute(obj, "ectime", 0);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		int sstart = getIntAttribute(ist, "sstart", def_sstart);
		int sstop = getIntAttribute(ist, "sstop", def_sstop);
		QTime ctime = getTimeAttribute(ist, "ctime", def_ctime);
		Light::FixedTimingType ftime = static_cast<Light::FixedTimingType>(getIntAttribute(ist, "ftime", def_ftime));
		int ectime = getIntAttribute(ist, "ectime", def_ectime);

		Dimmer100Device *d = bt_global::add_device_to_cache(new Dimmer100Device(where, pul));
		obj_list << ObjectPair(uii, new Dimmer100(descr, where, ctime, ftime, ectime, d, sstart, sstop));
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
	Light::FixedTimingType def_ftime = static_cast<Light::FixedTimingType>(getIntAttribute(obj, "ftime"));

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		Light::FixedTimingType ftime = static_cast<Light::FixedTimingType>(getIntAttribute(ist, "ftime", def_ftime));

		DimmerDevice *d = bt_global::add_device_to_cache(new DimmerDevice(where, pul));
		obj_list << ObjectPair(uii, new Dimmer(descr, where, ftime, d));
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
	QTime def_ctime = getTimeAttribute(obj, "ctime");
	Light::FixedTimingType def_ftime = static_cast<Light::FixedTimingType>(getIntAttribute(obj, "ftime"));
	int def_ectime = getIntAttribute(obj, "ectime", 0);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		QTime ctime = getTimeAttribute(ist, "ctime", def_ctime);
		Light::FixedTimingType ftime = static_cast<Light::FixedTimingType>(getIntAttribute(ist, "ftime", def_ftime));
		int ectime = getIntAttribute(ist, "ectime", def_ectime);

		LightingDevice *d = bt_global::add_device_to_cache(new LightingDevice(where, pul));
		obj_list << ObjectPair(uii, new Light(descr, where, ctime, ftime, ectime, d));
	}
	return obj_list;
}

QList<ObjectPair> parseLightCommand(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_where = getAttribute(obj, "where");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString where = getAttribute(ist, "where", def_where);

		LightingDevice *d = bt_global::add_device_to_cache(new LightingDevice(where, PULL));
		obj_list << ObjectPair(uii, new LightCommand(d));
	}
	return obj_list;
}

QList<ObjectPair> parseLightGroup(const QDomNode &obj, const UiiMapper &uii_map)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QList<ObjectInterface *> items;
		int dumber_type = ObjectInterface::IdDimmer100Fixed;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			ObjectInterface *item = uii_map.value<ObjectInterface>(object_uii);

			if (!item)
			{
				qWarning() << "Invalid uii" << object_uii << "in light set";
				Q_ASSERT_X(false, "parseLightGroup", "Invalid uii");
				continue;
			}

			items.append(item);
			dumber_type = findDumberObject(dumber_type, item->getObjectId());
		}

		switch (dumber_type)
		{
		case ObjectInterface::IdLightFixed:
			obj_list << ObjectPair(uii, new LightGroup(descr, convertQObjectList<LightCommand *>(items)));
			break;
		case ObjectInterface::IdDimmerFixed:
			obj_list << ObjectPair(uii, new DimmerGroup(descr, convertQObjectList<Dimmer *>(items)));
			break;
		case ObjectInterface::IdDimmer100Fixed:
			obj_list << ObjectPair(uii, new Dimmer100Group(descr, convertQObjectList<Dimmer100 *>(items)));
			break;
		}
	}
	return obj_list;
}


LightCommand::LightCommand(LightingDevice *d)
{
	dev = d;
}

void LightCommand::setActive(bool st)
{
	qDebug() << "LightCommand::setActive";
	if (st)
		dev->turnOn();
	else
		dev->turnOff();
}


Light::Light(QString _name, QString _key, QTime ctime, FixedTimingType _ftime, bool _ectime, LightingDevice *d) : LightCommand(d)
{
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	key = _key;
	name = _name;
	active = false; // initial value
	hours = ctime.hour();
	minutes = ctime.minute();
	seconds = ctime.second();
	ftime = _ftime;
	ectime = _ectime;
}

int Light::getObjectId() const
{
	if (ectime)
		return ObjectInterface::IdLightCustom;
	else
		return ObjectInterface::IdLightFixed;
}

QString Light::getObjectKey() const
{
	return key;
}

bool Light::isActive() const
{
	return active;
}

void Light::setHours(int h)
{
	if (h != hours && h >= 0 && h <= 255)
	{
		hours = h;
		emit hoursChanged();
	}
}

int Light::getHours()
{
	return hours;
}

void Light::setMinutes(int m)
{
	if (m != minutes && m >= 0 && m <= 59)
	{
		minutes = m;
		emit minutesChanged();
	}
}

int Light::getMinutes()
{
	return minutes;
}

void Light::setSeconds(int s)
{
	if (s != seconds && s >= 0 && s <= 59)
	{
		seconds = s;
		emit secondsChanged();
	}
}

int Light::getSeconds()
{
	return seconds;
}

void Light::setActiveWithTiming()
{
	dev->variableTiming(hours, minutes, seconds);
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


LightGroup::LightGroup(QString _name, QList<LightCommand *> d)
{
	name = _name;
	objects = d;
}

void LightGroup::setActive(bool status)
{
	foreach (LightCommand *l, objects)
		l->setActive(status);
}


Dimmer::Dimmer(QString name, QString key, FixedTimingType ftime, DimmerDevice *d)
	: Light(name, key, QTime(), ftime, false, d)
{
	dev = d;
	percentage = 0; // initial value
}

Dimmer::Dimmer(QString name, QString key, QTime ctime, Light::FixedTimingType ftime, bool ectime, DimmerDevice *d)
	: Light(name, key, ctime, ftime, ectime, d)
{
	dev = d;
	percentage = 0; // initial value
}

int Dimmer::getObjectId() const
{
	return ObjectInterface::IdDimmerFixed;
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

DimmerGroup::DimmerGroup(QString name, QList<Dimmer *> d) : LightGroup(name, convertQObjectList<LightCommand *>(d))
{
	objects = d;
}

void DimmerGroup::increaseLevel()
{
	foreach (Dimmer *d, objects)
		d->increaseLevel();
}

void DimmerGroup::decreaseLevel()
{
	foreach (Dimmer *d, objects)
		d->decreaseLevel();
}


Dimmer100::Dimmer100(QString name, QString key, QTime ctime, Light::FixedTimingType ftime, bool ectime, Dimmer100Device *d, int onspeed, int offspeed) :
	Dimmer(name, key, ctime, ftime, ectime, d)
{
	dev = d;
	on_speed = onspeed;
	off_speed = offspeed;
	step_speed = DIMMER100_SPEED;
	step_amount = DIMMER100_STEP;
}

int Dimmer100::getObjectId() const
{
	if (ectime)
		return ObjectInterface::IdDimmer100Custom;
	else
		return ObjectInterface::IdDimmer100Fixed;
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

void Dimmer100::setActiveWithTiming()
{
	// handle both on speed and timing (do not change frame order)
	setActive(true);
	Dimmer::setActiveWithTiming();
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


Dimmer100Group::Dimmer100Group(QString name, QList<Dimmer100 *> d) : DimmerGroup(name, convertQObjectList<Dimmer *>(d))
{
	objects = d;
}

void Dimmer100Group::increaseLevel100()
{
	foreach (Dimmer100 *d, objects)
		d->increaseLevel100();
}

void Dimmer100Group::decreaseLevel100()
{
	foreach (Dimmer100 *d, objects)
		d->decreaseLevel100();
}
