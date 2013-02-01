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


class AutomationVDE : public DeviceObjectInterface
{
	Q_OBJECT

public:
	AutomationVDE(QString name, VideoDoorEntryDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationVDE;
	}

	Q_INVOKABLE void activate();

private:
	VideoDoorEntryDevice *dev;
	
protected slots:
	void deactivate();
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


// internal class, used in automation groups, not useful to the GUI
class AutomationCommand3 : public DeviceObjectInterface
{
	Q_OBJECT

public:
	AutomationCommand3(AutomationDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomation3;
	}

	virtual void goUp();
	virtual void goDown();
	virtual void stop();

	virtual void setStatus(int st);

protected:
	AutomationDevice *dev;
};


/*!
	\ingroup Automation3
	\brief Manages 3-state automation actuators
	The object id is \a ObjectInterface::IdAutomation3, the key is the SCS where.
*/
class Automation3 : public AutomationCommand3
{
	friend class TestAutomation;

	Q_OBJECT

	/*!
		\brief Sets and gets if the light is active (on) or not (off)
	*/
	Q_PROPERTY(int status READ getStatus WRITE setStatus NOTIFY statusChanged)


public:

	Automation3(QString name, QString key, int _id, AutomationDevice *d);

	virtual int getObjectId() const;
	virtual QString getObjectKey() const;
	virtual int getStatus() const;

signals:
	void statusChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;
	int status;
	int id;
};


/*!
	\ingroup Automation3
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

