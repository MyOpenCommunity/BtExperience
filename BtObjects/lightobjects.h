#ifndef LIGHTOBJECTS_H
#define LIGHTOBJECTS_H

/*!
	\defgroup Lighting Lighting
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>

class LightingDevice;
class DimmerDevice;
class Dimmer100Device;
class QDomNode;
class UiiMapper;

QList<ObjectPair> parseDimmer100(const QDomNode &obj);
QList<ObjectPair> parseDimmer(const QDomNode &obj);
QList<ObjectPair> parseLight(const QDomNode &obj);
QList<ObjectPair> parseLightCommand(const QDomNode &obj);
QList<ObjectPair> parseLightGroup(const QDomNode &obj, const UiiMapper &uii_map);

// internal class, used in light groups, not useful to the GUI
class LightCommand : public ObjectInterface
{
	Q_OBJECT

public:
	LightCommand(LightingDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdLight;
	}

	virtual void setActive(bool st);

protected:
	LightingDevice *dev;
};


/*!
	\ingroup Lighting
	\brief Manages light actuators

	Can also be used to control dimmer 10 and dimmer 100 actuators.

	The object id is \a ObjectInterface::IdLight, the key is the SCS where.
*/
class Light : public LightCommand
{
	friend class TestLight;

	Q_OBJECT

	/*!
		\brief Sets and gets if the light is active (on) or not (off)
	*/
	Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

	Q_PROPERTY(int hours READ getHours WRITE setHours NOTIFY hoursChanged)
	Q_PROPERTY(int minutes READ getMinutes WRITE setMinutes NOTIFY minutesChanged)
	Q_PROPERTY(int seconds READ getSeconds WRITE setSeconds NOTIFY secondsChanged)

public:
	Light(QString name, QString key, QString ctime, LightingDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdLight;
	}

	virtual QString getObjectKey() const;

	virtual bool isActive() const;
	void setHours(int h);
	int getHours();
	void setMinutes(int m);
	int getMinutes();
	void setSeconds(int s);
	int getSeconds();
	Q_INVOKABLE void setActiveWithTiming();

signals:
	void activeChanged();
	void hoursChanged();
	void minutesChanged();
	void secondsChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;
	bool active;

private:
	int hours, minutes, seconds;
};


/*!
	\ingroup Lighting
	\brief Manages light actuator groups

	Can also be used to control dimmer 10 and dimmer 100 actuators.

	The object id is \a ObjectInterface::IdLightGroup
*/
class LightGroup : public ObjectInterface
{
	Q_OBJECT

public:
	LightGroup(QString name, QList<LightCommand *> d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdLightGroup;
	}

	/*!
		\brief Turn on light group
	*/
	Q_INVOKABLE void setActive(bool status);

private:
	QList<LightCommand *> objects;
};


/*!
	\ingroup Lighting
	\brief Manages dimmer 10 and dimmer 100 actuators

	Dimmer 100 actuators are controlled as if they were dimmer 10, so there
	is no way to use fine-grained increments or to control the speed.

	The object id is \a ObjectInterface::IdDimmer, the object key is the SCS where.
*/
class Dimmer : public Light
{
	friend class TestDimmer;

	Q_OBJECT

	/*!
		\brief Gets the dimmer level on a 1-100 scale

		Note that the level keeps its value even when the dimmer is off
	*/
	Q_PROPERTY(int percentage READ getPercentage NOTIFY percentageChanged)

public:
	Dimmer(QString name, QString key, QString ctime, DimmerDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDimmer;
	}

	virtual int getPercentage() const;

public slots:
	/*!
		\brief Increase dimmer level by about 10%
	*/
	void increaseLevel();

	/*!
		\brief Decrease dimmer level by about 10%
	*/
	void decreaseLevel();

signals:
	void percentageChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	int percentage;

private:
	DimmerDevice *dev;
};


/*!
	\ingroup Lighting
	\brief Manages dimmer 10 and dimmer 100 groups

	The object id is \a ObjectInterface::IdDimmerGroup

	\sa Dimmer
	\sa Dimmer100
*/
class DimmerGroup : public LightGroup
{
	Q_OBJECT

public:
	DimmerGroup(QString name, QList<Dimmer *> d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDimmerGroup;
	}

public slots:
	/*!
		\brief Increase dimmer group level by about 10%
	*/
	void increaseLevel();

	/*!
		\brief Decrease dimmer group level by about 10%
	*/
	void decreaseLevel();

private:
	QList<Dimmer *> objects;
};


/*!
	\ingroup Lighting
	\brief Manages dimmer 100 actuators

	The actuator allows setting the speed at which it turns on/off and offers 100 levels
	instead of 10.

	The object id is \a ObjectInterface::IdDimmer, the object key is the SCS where.
*/
class Dimmer100 : public Dimmer
{
	friend class TestDimmer100;

	Q_OBJECT

	/*!
		\brief The speed at which the dimmer turns on (1-255)

		\sa active
	*/
	Q_PROPERTY(int onSpeed READ getOnSpeed WRITE setOnSpeed NOTIFY onSpeedChanged)

	/*!
		\brief The speed at which the dimmer turns off (1-255)

		\sa active
	*/
	Q_PROPERTY(int offSpeed READ getOffSpeed WRITE setOffSpeed NOTIFY offSpeedChanged)

	/*!
		\brief The speed at which the dimmer increases/decreases its level (1-255)

		\sa increaseLevel100
		\sa decreaseLevel100
	*/
	Q_PROPERTY(int stepSpeed READ getStepSpeed WRITE setStepSpeed NOTIFY stepSpeedChanged)

	/*!
		\brief The amount used to increase/decrease the dimmer level.

		\sa increaseLevel100
		\sa decreaseLevel100
	*/
	Q_PROPERTY(int stepAmount READ getStepAmount WRITE setStepAmount NOTIFY stepAmountChanged)

public:
	Dimmer100(QString name, QString key, QString ctime, Dimmer100Device *d, int onspeed, int offsspeed);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDimmer100;
	}

	virtual void setActive(bool st);

	void setOnSpeed(int speed);
	int getOnSpeed() const;

	void setOffSpeed(int speed);
	int getOffSpeed() const;

	void setStepSpeed(int speed);
	int getStepSpeed() const;

	void setStepAmount(int amount);
	int getStepAmount() const;

public slots:
	/*!
		\brief Increase dimmer level by \a stepAmount at speed \a stepSpeed.
	*/
	void increaseLevel100();

	/*!
		\brief Decrease dimmer level by \a stepAmount at speed \a stepSpeed.
	*/
	void decreaseLevel100();

signals:
	void onSpeedChanged();
	void offSpeedChanged();
	void stepSpeedChanged();
	void stepAmountChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	int on_speed, off_speed, step_speed, step_amount;

private:
	Dimmer100Device *dev;
};


/*!
	\ingroup Lighting
	\brief Manages dimmer 100 groups

	The object id is \a ObjectInterface::IdDimmer100Group

	\sa Dimmer
	\sa Dimmer100
*/
class Dimmer100Group : public DimmerGroup
{
	Q_OBJECT

public:
	Dimmer100Group(QString name, QList<Dimmer100 *> d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdDimmer100Group;
	}

public slots:
	/*!
		\brief Increase dimmer group level.

		Amount and speed are the one specified by the linked dimmer objects
	*/
	void increaseLevel100();

	/*!
		\brief Decrease dimmer group level.

		Amount and speed are the one specified by the linked dimmer objects
	*/
	void decreaseLevel100();

private:
	QList<Dimmer100 *> objects;
};

#endif // LIGHTOBJECTS_H

