#ifndef LIGHTOBJECTS_H
#define LIGHTOBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>

class LightingDevice;
class DimmerDevice;
class Dimmer100Device;
class QDomNode;

QList<ObjectPair> parseDimmer100(const QDomNode &obj);
QList<ObjectPair> parseDimmer(const QDomNode &obj);
QList<ObjectPair> parseLight(const QDomNode &obj);


/*!
	\ingroup Lighting
	\brief Manages light actuators

	Can also be used to control dimmer 10 and dimmer 100 actuators.

	The object id is \a ObjectInterface::IdLight, the key is the SCS where.
*/
class Light : public ObjectInterface
{
	friend class TestLight;

	Q_OBJECT

	/*!
		\brief Sets and gets if the light is active (on) or not (off)
	*/
	Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

public:
	Light(QString name, QString key, LightingDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdLight;
	}

	virtual QString getObjectKey() const;

	virtual ObjectCategory getCategory() const
	{
		return category;
	}

	virtual QString getName() const;
	virtual bool isActive() const;
	virtual void setActive(bool st);
	void setCategory(ObjectCategory _category);

signals:
	void activeChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString name;
	QString key;
	bool active;

private:
	LightingDevice *dev;
	ObjectCategory category;
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
	Dimmer(QString name, QString key, DimmerDevice *d);

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
	Dimmer100(QString name, QString key, Dimmer100Device *d, int onspeed, int offsspeed);

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

#endif // LIGHTOBJECTS_H

