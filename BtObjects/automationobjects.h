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
class AutomationDevice;
//class PPTStatDeviceDevice;
class QDomNode;
class UiiMapper;

QList<ObjectPair> parseAutomationVDE(const QDomNode &obj);
QList<ObjectPair> parseAutomation2(const QDomNode &obj);
QList<ObjectPair> parseAutomation3(const QDomNode &obj);
QList<ObjectPair> parseAutomationCommandVDE(const QDomNode &obj);
QList<ObjectPair> parseAutomationCommand2(const QDomNode &obj);
QList<ObjectPair> parseAutomationCommand3(const QDomNode &obj);
QList<ObjectPair> parseAutomationGroup2(const QDomNode &obj, const UiiMapper &uii_map);
QList<ObjectPair> parseAutomationGroup3(const QDomNode &obj, const UiiMapper &uii_map);




class AutomationLight: public Light
{
public:
	AutomationLight(QString name, QString key, QTime ctime, FixedTimingType ftime, bool ectime, LightingDevice *d, int _myid);
	int getObjectId() const;
protected:
	int myid;
};

// internal class, used in automation groups, not useful to the GUI
class AutomationCommand2 : public DeviceObjectInterface
{
	Q_OBJECT

public:
	AutomationCommand2(LightingDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationCommand2;
	}

	virtual void setActive(bool st);

protected:
	LightingDevice *dev;
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
	AutomationGroup2(QString name, QList<AutomationCommand2 *> d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationCommand2;
	}

	/*!
		\brief Turn on light group
	*/
	Q_INVOKABLE void setActive(bool status);

private:
	QList<AutomationCommand2 *> objects;
};




// internal class, used in automation groups, not useful to the GUI
class AutomationCommand3 : public DeviceObjectInterface
{
	Q_OBJECT

public:
	AutomationCommand3(AutomationDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationCommand3;
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

	Automation3(QString name, QString key, QString safe, AutomationDevice *d);

	virtual int getObjectId() const;
	virtual QString getObjectKey() const;
	virtual int getStatus() const;

signals:
	void statusChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;
	QString mode;
	int status;
	bool safe;
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
	AutomationGroup3(QString name, QList<AutomationCommand3 *> d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAutomationGroup3;
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
	QList<AutomationCommand3 *> objects;
};



#endif // AUTOMATIONOBJECTS_H

