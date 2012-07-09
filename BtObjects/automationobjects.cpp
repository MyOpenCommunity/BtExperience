#include "automationobjects.h"
#include "automation_device.h"
#include "lighting_device.h"
#include "lightobjects.h"
#include "xml_functions.h"
#include "devices_cache.h"
#include "uiimapper.h"

#include <QDebug>
#include <QStringList>



namespace
{
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



QList<ObjectPair> parseAutomationVDE(const QDomNode &obj)
{
	// TODO VDE door object
	QList<ObjectPair> obj_list;
	return obj_list;
}



QList<ObjectPair> parseAutomation2(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");
	int def_pul = getIntAttribute(obj, "pul");
	QTime def_ctime = getTimeAttribute(obj, "ctime");
	Light::FixedTimingType def_ftime = static_cast<Light::FixedTimingType>(getIntAttribute(obj, "ftime"));
	int def_ectime = getIntAttribute(obj, "ectime", 0);
	int myid = getIntAttribute(obj, "id");

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
		obj_list << ObjectPair(uii, new AutomationLight(descr, where, ctime, ftime, ectime, d, myid));
	}

	return obj_list;
}

QList<ObjectPair> parseAutomationCommand2(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_where = getAttribute(obj, "where");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString where = getAttribute(ist, "where", def_where);

		LightingDevice *d = bt_global::add_device_to_cache(new LightingDevice(where, PULL));
		obj_list << ObjectPair(uii, new AutomationCommand2(d));
	}
	return obj_list;
}

QList<ObjectPair> parseAutomationGroup2(const QDomNode &obj, const UiiMapper &uii_map)
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
		}
		obj_list << ObjectPair(uii, new AutomationGroup2(descr, convertQObjectList<AutomationCommand2 *>(items)));
	}
	return obj_list;
}



QList<ObjectPair> parseAutomation3(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");
	int def_pul = getIntAttribute(obj, "pul");
	QString def_mode = getAttribute(obj, "mode");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		QString mode = getAttribute(ist, "mode", def_mode);

		AutomationDevice *d = bt_global::add_device_to_cache(new AutomationDevice(where, pul));
		obj_list << ObjectPair(uii, new Automation3(descr, where, mode, d));
	}
	return obj_list;
}

QList<ObjectPair> parseAutomationGroup3(const QDomNode &obj, const UiiMapper &uii_map)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QList<ObjectInterface *> items;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			ObjectInterface *item = uii_map.value<ObjectInterface>(object_uii);

			if (!item)
			{
				qWarning() << "Invalid uii" << object_uii << "in automation set";
				Q_ASSERT_X(false, "parseAutomationGroup3", "Invalid uii");
				continue;
			}

			items.append(item);
		}
		obj_list << ObjectPair(uii, new AutomationGroup3(descr, convertQObjectList<AutomationCommand3 *>(items)));
	}
	return obj_list;
}

QList<ObjectPair> parseAutomationCommand3(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_where = getAttribute(obj, "where");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString where = getAttribute(ist, "where", def_where);

		AutomationDevice *d = bt_global::add_device_to_cache(new AutomationDevice(where, PULL));
		obj_list << ObjectPair(uii, new AutomationCommand3(d));
	}
	return obj_list;
}


AutomationLight::AutomationLight(QString name, QString key, QTime ctime, FixedTimingType ftime, bool ectime, LightingDevice *d, int _myid): Light(name, key, ctime, ftime, ectime, d)
{
	myid = _myid;
}

int AutomationLight::getObjectId() const
{
	return myid;
}

AutomationCommand2::AutomationCommand2(LightingDevice *d)
{
	dev = d;
}

void AutomationCommand2::setActive(bool st)
{
	qDebug() << "AutomationCommand2::setActive";
	if (st)
		dev->turnOn();
	else
		dev->turnOff();
}

AutomationGroup2::AutomationGroup2(QString _name, QList<AutomationCommand2 *> d)
{
	name = _name;
	objects = d;
}

void AutomationGroup2::setActive(bool status)
{
	foreach (AutomationCommand2 *l, objects)
		l->setActive(status);
}


AutomationCommand3::AutomationCommand3(AutomationDevice *d)
{
	dev = d;
}

void AutomationCommand3::setStatus(int st)
{
	qDebug() << "AutomationCommand3::setStatus " << st;
	if (st == AutomationDevice::DIM_UP)
		dev->goUp();
	else if (st == AutomationDevice::DIM_DOWN)
		dev->goDown();
	else dev->stop();
}

void AutomationCommand3::goUp()
{
	qDebug() << "AutomationCommand3::goUp";
	dev->goUp();
}

void AutomationCommand3::goDown()
{
	qDebug() << "AutomationCommand3::goDown";
	dev->goDown();
}

void AutomationCommand3::stop()
{
	qDebug() << "AutomationCommand3::stop";
	dev->stop();
}

Automation3::Automation3(QString _name, QString _key, QString _mode, AutomationDevice *d) : AutomationCommand3(d)
{
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	key = _key;
	name = _name;
	mode = _mode;
	status = 0; // initial value
}

int Automation3::getObjectId() const
{
	return ObjectInterface::IdAutomation3;
}

QString Automation3::getObjectKey() const
{
	return key;
}

int Automation3::getStatus() const
{
	return status;
}

void Automation3::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if ((it.key() == AutomationDevice::DIM_UP ) || (it.key() == AutomationDevice::DIM_DOWN ) || (it.key() == AutomationDevice::DIM_STOP ))
		{
			if (it.value() != status)
			{
				status = it.value().toInt();

				emit statusChanged();
				break;
			}
		}
		++it;
	}
}

AutomationGroup3::AutomationGroup3(QString _name, QList<AutomationCommand3 *> d)
{
	name = _name;
	objects = d;
}

void AutomationGroup3::goUp()
{
	foreach (AutomationCommand3 *l, objects)
		l->goUp();
}

void AutomationGroup3::goDown()
{
	foreach (AutomationCommand3 *l, objects)
		l->goDown();
}

void AutomationGroup3::stop()
{
	foreach (AutomationCommand3 *l, objects)
		l->stop();
}

void AutomationGroup3::setStatus(int status)
{
	foreach (AutomationCommand3 *l, objects)
		l->setStatus(status);
}
