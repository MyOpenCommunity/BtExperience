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
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString where = v.value("dev") + v.value("addresses");

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

		QString where = v.value("where");
		PullMode pul = v.intValue("pul") ? PULL : NOT_PULL;
		QTime time = id == ObjectInterface::IdAutomationDoor ? v.timeValue("time") : QTime();

		LightingDevice *d = bt_global::add_device_to_cache(new LightingDevice(where, pul));
		obj_list << ObjectPair(uii, new AutomationLight(v.value("descr"), where, time, d, id));
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

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			ObjectInterface *item = uii_map.value<ObjectInterface>(object_uii);

			if (!item)
			{
				qWarning() << "Invalid uii" << object_uii << "in automation 2 set";
				Q_ASSERT_X(false, "parseLightGroup", "Invalid uii");
				continue;
			}

			items.append(item);
		}
		obj_list << ObjectPair(uii, new AutomationGroup2(descr, convertQObjectList<AutomationLight *>(items)));
	}
	return obj_list;
}

QList<ObjectPair> parseAutomation3(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	// extract default values
	QString def_descr = getAttribute(obj, "descr");
	QString def_where = getAttribute(obj, "where");
	int def_pul = getIntAttribute(obj, "pul", 0);
	QString def_mode = getAttribute(obj, "mode");
	int def_cid = getIntAttribute(obj, "cid");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		QString where = getAttribute(ist, "where", def_where);
		PullMode pul = getIntAttribute(ist, "pul", def_pul) ? PULL : NOT_PULL;
		QString mode = getAttribute(ist, "mode", def_mode);
		int cid = getIntAttribute(ist, "cid", def_cid);

		//this should not happen if the software works correctly, but just in case...
		if (cid < 0) cid = ObjectInterface::CidAutomation3OpenClose;
		
		AutomationDevice *d = bt_global::add_device_to_cache(new AutomationDevice(where, pul));

		switch (cid)
		{
		case ObjectInterface::CidAutomation3OpenClose:
		case ObjectInterface::CidAutomationGroup3OpenClose:
			if (mode.toInt()!=0)
				obj_list << ObjectPair(uii, new Automation3(descr, where, mode, ObjectInterface::IdAutomation3OpenCloseSafe, d));
			else
				obj_list << ObjectPair(uii, new Automation3(descr, where, mode, ObjectInterface::IdAutomation3OpenClose, d));
			break;
		case ObjectInterface::CidAutomation3UpDown:
		case ObjectInterface::CidAutomationGroup3UpDown:
			if (mode.toInt()!=0)
				obj_list << ObjectPair(uii, new Automation3(descr, where, mode, ObjectInterface::IdAutomation3UpDownSafe, d));
			else
				obj_list << ObjectPair(uii, new Automation3(descr, where, mode, ObjectInterface::IdAutomation3UpDown, d));
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
	// extract default values
	QString def_descr = getAttribute(obj, "descr");

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		int uii = getIntAttribute(ist, "uii");
		QString descr = getAttribute(ist, "descr", def_descr);
		int cid = ObjectInterface::CidAutomationGroup3OpenClose;
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
		obj_list << ObjectPair(uii, new AutomationGroup3(descr, ObjectInterface::IdAutomationGroup3OpenClose, convertQObjectList<Automation3 *>(items)));

	}
	return obj_list;
}


AutomationLight::AutomationLight(QString name, QString key, QTime time, LightingDevice *d, int _myid) :
	Light(name, key, time, FixedTimingDisabled, time.isValid(), d)
{
	setAutoTurnOff(time.isValid());
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

AutomationVDE::AutomationVDE(QString _name, VideoDoorEntryDevice *d) :
	DeviceObjectInterface(d)
{
	name = _name;
	dev = d;
}

void AutomationVDE::activate()
{
	dev->openLock();
	QTimer::singleShot(2000, this, SLOT(deactivate()));
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


AutomationCommand3::AutomationCommand3(AutomationDevice *d) :
	DeviceObjectInterface(d)
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

Automation3::Automation3(QString _name, QString _key, QString _mode, int _id, AutomationDevice *d) : AutomationCommand3(d)
{
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	key = _key;
	name = _name;
	mode = _mode;
	id = _id;
	status = 0; // initial value
}

int Automation3::getObjectId() const
{
	return id;
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
