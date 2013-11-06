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

#ifndef AUTOMATIONOBJECTS_H
#define AUTOMATIONOBJECTS_H

/*!
	\defgroup Automation Automation
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues
#include "lightobjects.h"
#include "lighting_device.h"
#include "automation_device.h"

#include <QObject>

class LightingDevice;
class VideoDoorEntryDevice;
class AutomationDevice;
//class PPTStatDeviceDevice;
class QDomNode;
class UiiMapper;

QList<ObjectPair> parseAutomationVDE(const QDomNode &obj);
QList<ObjectPair> parseAutomation2(const QDomNode &obj);
QList<ObjectPair> parseAutomation3(const QDomNode &obj);
QList<ObjectPair> parseAutomationGroup2(const QDomNode &obj, const UiiMapper &uii_map);
QList<ObjectPair> parseAutomationGroup3(const QDomNode &obj, const UiiMapper &uii_map);




/*!
	\ingroup Automation
	\brief Manages a light actuator
*/
class AutomationLight: public Light
{
	Q_OBJECT

public:
	AutomationLight(QString name, QString key, QTime time, LightingDevice *d, int _myid);

	int getObjectId() const;

	Q_INVOKABLE void activate();

protected:
	int myid;
};

/*!
	\ingroup Automation
	\brief Manages contacts
*/
class AutomationContact : public DeviceObjectInterface
{
	Q_OBJECT

	/*!
		\brief Sets and gets if the light is active (on) or not (off)
	*/
	Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)

public:
	AutomationContact(QString name, PPTStatDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationContact;
	}

	virtual bool isActive() const;

protected:
	bool active;

signals:
	void activeChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	PPTStatDevice *dev;
};

/*!
	\ingroup Automation
	\brief Manages open/release lock
*/
class AutomationVDE : public DeviceObjectInterface
{
	Q_OBJECT

public:
	AutomationVDE(QString name, VideoDoorEntryDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationVDE;
	}

public slots:
	void activate();
	void deactivate();

private:
	VideoDoorEntryDevice *dev;
};


/*!
	\ingroup Automation
	\brief Manages light actuator groups

	Can also be used to control dimmer 10 and dimmer 100 actuators.

	The object id is \a ObjectInterface::IdLightGroup
*/
class AutomationGroup2 : public ObjectInterface
{
	Q_OBJECT

public:
	AutomationGroup2(QString name, QList<AutomationLight *> d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationGroup2;
	}

	/*!
		\brief Turn on light group
	*/
	Q_INVOKABLE void setActive(bool status);

private:
	QList<AutomationLight *> objects;
};


/*!
	\ingroup Automation
	\brief Manages 3-state automation actuators

	The object id is \a ObjectInterface::IdAutomation3, the key is the SCS where.
*/
class Automation3 : public DeviceObjectInterface
{
	friend class TestAutomation3;

	Q_OBJECT

	/*!
		\brief Sets and gets if the light is active (on) or not (off)
	*/
	Q_PROPERTY(int status READ getStatus WRITE setStatus NOTIFY statusChanged)

public:
	Automation3(QString name, QString key, int _id, AutomationDevice *d);

	virtual int getObjectId() const;
	virtual QString getObjectKey() const;

	void setStatus(int st);
	int getStatus() const;

	Q_INVOKABLE void goUp();
	Q_INVOKABLE void goDown();
	Q_INVOKABLE void stop();

signals:
	void statusChanged();

private slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	AutomationDevice *dev;
	QString key;
	int status;
	int id;
};


/*!
	\ingroup Automation
	\brief Manages Automation 3-states actuator groups

	The object id is \a ObjectInterface::IdAutomationGroup3
*/
class AutomationGroup3 : public ObjectInterface
{
	Q_OBJECT

public:
	AutomationGroup3(QString name, int _id, QList<Automation3 *> d);

	virtual int getObjectId() const
	{
		return id;
	}

	/*!
		\brief automation group commands
	*/
	Q_INVOKABLE void goUp();
	Q_INVOKABLE void goDown();
	Q_INVOKABLE void stop();

	/*!
		\brief Turn on light group
	*/
	Q_INVOKABLE void setStatus(int _status);


private:
	QList<Automation3 *> objects;
	int id;
};



#endif // AUTOMATIONOBJECTS_H

