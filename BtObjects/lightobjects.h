#ifndef LIGHTOBJECTS_H
#define LIGHTOBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>

class LightingDevice;
class DimmerDevice;


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
		\brief Sets and gets the on/off status of the light
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
		return ObjectInterface::Lighting;
	}

	virtual QString getName() const;
	virtual bool isActive() const;
	virtual void setActive(bool st);

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
	friend class TestDimmer100;

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


#endif // LIGHTOBJECTS_H

