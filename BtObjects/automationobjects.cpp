/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#include "automationobjects.h"
#include "automation_device.h"
#include "lighting_device.h"
#include "videodoorentry_device.h"
#include "lightobjects.h"
#include "xml_functions.h"
#include "devices_cache.h"
#include "uiimapper.h"
#include "xmlobject.h"

#include <QDebug>
#include <QStringList>


QList<ObjectPair> parseAutomationVDE(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString where = v.value("dev") + v.value("where");

		VideoDoorEntryDevice *d = bt_global::add_device_to_cache(new VideoDoorEntryDevice(where));
		obj_list << ObjectPair(uii, new AutomationVDE(v.value("descr"), d));
	}

	return obj_list;
}


QList<ObjectPair> parseAutomation2(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);
	int id = getIntAttribute(obj, "id");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		int cid = v.intValue("cid");

		QString where = v.value("where");
		PullMode pul = v.intValue("pul") ? PULL : NOT_PULL;
		QTime time = id == ObjectInterface::IdAutomationDoor ? v.timeValue("time") : QTime();
		LightingDevice *d;
		switch (cid)
		{
		case ObjectInterface::CidAutomation2Normal:
			d = bt_global::add_device_to_cache(new LightingDevice(where, pul));
			obj_list << ObjectPair(uii, new AutomationLight(v.value("descr"), where, time, d, ObjectInterface::IdAutomation2Normal));
			break;
		case ObjectInterface::CidAutomation2GEN:
			d = bt_global::add_device_to_cache(new LightingDevice(where, pul));
			obj_list << ObjectPair(uii, new AutomationLight(v.value("descr"), where, time, d, ObjectInterface::IdAutomation2GEN));
			break;
		case ObjectInterface::CidAutomationContact:
			PPTStatDevice *p;
			p = bt_global::add_device_to_cache(new PPTStatDevice(where));
			obj_list << ObjectPair(uii, new AutomationContact(v.value("descr"), p));
			break;
		default:
			d = bt_global::add_device_to_cache(new LightingDevice(where, pul));
			obj_list << ObjectPair(uii, new AutomationLight(v.value("descr"), where, time, d, id));
			break;
		}
	}

	return obj_list;
}

QList<ObjectPair> parseAutomationGroup2(const QDomNode &obj, const UiiMapper &uii_map)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QList<AutomationLight *> items;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			v.setIst(ist);
			int object_uii = getIntAttribute(link, "uii");
			AutomationLight *item = uii_map.value<AutomationLight>(object_uii);

			if (!item)
			{
				qWarning() << "Invalid uii" << object_uii << "in automation 2 set";
				Q_ASSERT_X(false, __PRETTY_FUNCTION__, "Invalid uii");
				continue;
			}

			items.append(item);
		}
		obj_list << ObjectPair(uii, new AutomationGroup2(v.value("descr"), items));
	}
	return obj_list;
}

QList<ObjectPair> parseAutomation3(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);
	int id = getIntAttribute(obj, "id");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString descr = v.value("descr");
		QString where = v.value("where");
		PullMode pul = v.intValue("pul") ? PULL : NOT_PULL;
		int mode = v.intValue("mode");
		int cid = v.intValue("cid");
		AutomationDevice *d = bt_global::add_device_to_cache(new AutomationDevice(where, pul));

		if (bool(mode) != (id == ObjectInterface::IdAutomation3Safe))
		{
			qWarning() << "Inconsistend safe mode for 3-state actuator with UII" << uii;
			Q_ASSERT_X(false, "parseAutomation3", "Inconsistent safe mode");
		}

		switch (cid)
		{
		case ObjectInterface::CidAutomationGroup3OpenClose:
			obj_list << ObjectPair(uii, new Automation3(descr, where, ObjectInterface::IdAutomationGEN3OpenClose, d));
			break;
		case ObjectInterface::CidAutomationGroup3UpDown:
			obj_list << ObjectPair(uii, new Automation3(descr, where, ObjectInterface::IdAutomationGEN3UpDown, d));
			break;
		case ObjectInterface::CidAutomation3OpenClose:
			if (id == ObjectInterface::IdAutomation3Safe)
				obj_list << ObjectPair(uii, new Automation3(descr, where, ObjectInterface::IdAutomation3OpenCloseSafe, d));
			else
				obj_list << ObjectPair(uii, new Automation3(descr, where, ObjectInterface::IdAutomation3OpenClose, d));
			break;
		case ObjectInterface::CidAutomation3UpDown:
			if (id == ObjectInterface::IdAutomation3Safe)
				obj_list << ObjectPair(uii, new Automation3(descr, where, ObjectInterface::IdAutomation3UpDownSafe, d));
			else
				obj_list << ObjectPair(uii, new Automation3(descr, where, ObjectInterface::IdAutomation3UpDown, d));
			break;
		default:
			qWarning() << "Invalid Cid " << cid << " in Automation 3 Set";
			break;
		}
	}
	return obj_list;
}

QList<ObjectPair> parseAutomationGroup3(const QDomNode &obj, const UiiMapper &uii_map)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString descr = v.value("descr");
		int cid = v.intValue("cid");
		int id = cid == ObjectInterface::CidAutomationGroup3OpenClose ? ObjectInterface::IdAutomationGroup3OpenClose : ObjectInterface::IdAutomationGroup3UpDown;
		QList<Automation3 *> items;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			Automation3 *item = uii_map.value<Automation3>(object_uii);

			if (!item)
			{
				qWarning() << "Invalid uii" << object_uii << "in automation set";
				Q_ASSERT_X(false, "parseAutomationGroup3", "Invalid uii");
				continue;
			}
			items.append(item);
		}
		obj_list << ObjectPair(uii, new AutomationGroup3(descr, id, items));

	}
	return obj_list;
}


AutomationLight::AutomationLight(QString name, QString key, QTime time, LightingDevice *d, int _myid) :
	Light(name, key, time, FixedTimingDisabled, time.isValid(), true /*id=3001 is a PP*/, d)
{
	setTimingEnabled(time.isValid());
	myid = _myid;
}

int AutomationLight::getObjectId() const
{
	return myid;
}

void AutomationLight::activate()
{
	setActive(true);
}

AutomationContact::AutomationContact(QString _name, PPTStatDevice *d) :
	DeviceObjectInterface(d)
{
	name = _name;
	dev = d;
	active = false; // initial value
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

}

bool AutomationContact::isActive() const
{
	return active;
}

void AutomationContact::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
			if (it.value().toBool() != active)
			{
				active = it.value().toBool() == true;

				emit activeChanged();
				break;
			}
		++it;
	}
}



AutomationVDE::AutomationVDE(QString _name, VideoDoorEntryDevice *d) :
	DeviceObjectInterface(d)
{
	name = _name;
	dev = d;
}

void AutomationVDE::activate()
{
	dev->openLock();
}

void AutomationVDE::deactivate()
{
	dev->releaseLock();
}

AutomationGroup2::AutomationGroup2(QString _name, QList<AutomationLight *> d)
{
	name = _name;
	objects = d;
}

void AutomationGroup2::setActive(bool status)
{
	foreach (AutomationLight *l, objects)
	{
		l->setActive(status);
	}
}


Automation3::Automation3(QString _name, QString _key, int _id, AutomationDevice *d) : DeviceObjectInterface(d)
{
	dev = d;
	key = _key;
	name = _name;
	id = _id;
	status = 0;

	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int Automation3::getObjectId() const
{
	return id;
}

QString Automation3::getObjectKey() const
{
	return key;
}

void Automation3::goUp()
{
	dev->goUp();
}

void Automation3::goDown()
{
	dev->goDown();
}

void Automation3::stop()
{
	dev->stop();
}


void Automation3::setStatus(int st)
{
	if (st == AutomationDevice::DIM_UP)
		dev->goUp();
	else if (st == AutomationDevice::DIM_DOWN)
		dev->goDown();
	else
		dev->stop();
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
			if ((it.key() != status) && (it.value().toInt()))
			{
				status = it.key();

				emit statusChanged();
				break;
			}
		}
		++it;
	}
}

AutomationGroup3::AutomationGroup3(QString _name, int _id, QList<Automation3 *> d)
{
	name = _name;
	objects = d;
	id = _id;
}

void AutomationGroup3::goUp()
{
	foreach (Automation3 *l, objects)
		l->goUp();
}

void AutomationGroup3::goDown()
{
	foreach (Automation3 *l, objects)
		l->goDown();
}

void AutomationGroup3::stop()
{
	foreach (Automation3 *l, objects)
		l->stop();
}

void AutomationGroup3::setStatus(int status)
{
	foreach (Automation3 *l, objects)
		l->setStatus(status);
}
