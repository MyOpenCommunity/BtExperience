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
class ChoiceList;
class BasicVideoDoorEntryDevice;
class QTimer;

QList<ObjectPair> parseDimmer100(const QDomNode &obj);
QList<ObjectPair> parseDimmer(const QDomNode &obj);
QList<ObjectPair> parseLight(const QDomNode &obj);
QList<ObjectPair> parseLightGroup(const QDomNode &obj, const UiiMapper &uii_map);
QList<ObjectPair> parseStaircaseLight(const QDomNode &xml_node);


/*!
	\ingroup Lighting
	\brief A base interface for Light and StaircaseLight
*/
class LightInterface
{
public:
	virtual void setActive(bool active) = 0;
};


/*!
	\ingroup Lighting
	\brief Manages stair case light for this PI
*/
class StaircaseLight : public ObjectInterface, public LightInterface
{
	Q_OBJECT

public:
	StaircaseLight(const QString& name, BasicVideoDoorEntryDevice *d, const QString &where, QObject *parent = 0);

	virtual int getObjectId() const { return IdStaircaseLight; }
	virtual void setActive(bool st);

public slots:
	void staircaseLightActivate();
	void staircaseLightRelease();

private slots:
	void releaseAfterDelay();

private:
	BasicVideoDoorEntryDevice *dev;
	QString where;
	QTimer *timer_release;
};


/*!
	\ingroup Lighting
	\brief Manages light actuators

	Can also be used to control dimmer 10 and dimmer 100 actuators.

	If the object is a fixed timing light, the timing must be controlled using
	the \a ftimes member property.
	If the object is a custom timing light, it must be created with \a FixedTimingDisabled
	fixed time parameter and it must be handled using the \a timingEnabled and
	\a hours, \a minutes and \a seconds interface.

	The object id is \a ObjectInterface::IdLight, the key is the SCS where.
*/
class Light : public DeviceObjectInterface, public LightInterface
{
	friend class TestLight;

	Q_OBJECT

	/*!
		\brief Sets and gets if the light is active (on) or not (off)
	*/
	Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

	/*!
		\brief Sets and gets if automatic turn off is enabled or not
	*/
	Q_PROPERTY(bool timingEnabled READ isTimingEnabled WRITE setTimingEnabled NOTIFY timingEnabledChanged)

	/*!
		\brief Time interval for  \ref active

		After the specified amount of time, the light will turn off automatically.

		\sa active
	*/
	Q_PROPERTY(int hours READ getHours WRITE setHours NOTIFY hoursChanged)

	/*!
		\brief Time interval for  \ref active

		After the specified amount of time, the light will turn off automatically.

		\sa active
	*/
	Q_PROPERTY(int minutes READ getMinutes WRITE setMinutes NOTIFY minutesChanged)

	/*!
		\brief Time interval for  \ref active

		After the specified amount of time, the light will turn off automatically.

		\sa active
	*/
	Q_PROPERTY(int seconds READ getSeconds WRITE setSeconds NOTIFY secondsChanged)

	/*!
		\brief Time interval for LightingDevice::fixedTiming

		After the specified amount of time, the light will turn off automatically.
	*/
	Q_PROPERTY(FixedTimingType ftime READ getFTime NOTIFY fTimeChanged)

	/*!
		\brief Gets the valid ftime ChoiceList
	*/
	Q_PROPERTY(QObject *ftimes READ getFTimes CONSTANT)

	Q_ENUMS(FixedTimingType)

public:

	/// Fixed timing type. \sa LightingDevice::fixedTiming
	enum FixedTimingType
	{
		/*
		  Due to bug https://bugreports.qt-project.org/browse/QTBUG-21672
		  a -1 defined in enum is converted to undefined in QML
		  Bug will be solved in Qt 5, for now, we have to trick some values
		  in QML code
		  */
		/// fixed timing is not enabled/known
		FixedTimingDisabled = -1,
		/// 1 minute (11 in xml file)
		FixedTimingMinutes1 = 11,
		/// 2 minutes (12 in xml file)
		FixedTimingMinutes2,
		/// 3 minutes (13 in xml file)
		FixedTimingMinutes3,
		/// 4 minutes (14 in xml file)
		FixedTimingMinutes4,
		/// 5 minutes (15 in xml file)
		FixedTimingMinutes5,
		/// 15 minutes (16 in xml file)
		FixedTimingMinutes15,
		/// 30 seconds (17 in xml file)
		FixedTimingSeconds30,
		/// 0.5 seconds (18 in xml file)
		FixedTimingSeconds0_5
	};

	Light(QString name, QString key, QTime ctime, FixedTimingType ftime, bool ectime, bool point_to_point, LightingDevice *d);

	virtual int getObjectId() const;
	virtual QString getObjectKey() const;
	virtual bool isActive() const;
	bool isTimingEnabled() const;
	void setTimingEnabled(bool enabled);
	void setHours(int h);
	int getHours();
	void setMinutes(int m);
	int getMinutes();
	void setSeconds(int s);
	int getSeconds();
	FixedTimingType getFTime() const;
	QObject *getFTimes() const;
	virtual void setActive(bool st);

	Q_INVOKABLE virtual void prevFTime();
	Q_INVOKABLE virtual void nextFTime();

signals:
	void activeChanged();
	void hoursChanged();
	void minutesChanged();
	void secondsChanged();
	void fTimeChanged();
	void timingEnabledChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	// manages only turn on or off
	virtual void turn(bool on);
	bool isAutoTurnOff() const;

	QString key;
	bool active;
	bool ectime, timing_enabled;
	int hours, minutes, seconds;
	bool point_to_point;

private:
	ChoiceList *ftimes;
	LightingDevice *dev;
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
	LightGroup(QString name, QList<LightInterface *> d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdLightGroup;
	}

	/*!
		\brief Turn on light group
	*/
	Q_INVOKABLE void setActive(bool status);

private:
	QList<LightInterface *> objects;
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
		\brief Whether the dimmer is broken
	*/
	Q_PROPERTY(bool broken READ isBroken NOTIFY brokenChanged)

	/*!
		\brief Gets the dimmer level on a 1-100 scale

		Note that the level keeps its value even when the dimmer is off
	*/
	Q_PROPERTY(int percentage READ getPercentage WRITE setPercentage NOTIFY percentageChanged)

public:
	Dimmer(QString name, QString key, FixedTimingType ftime, bool point_to_point, DimmerDevice *d);

	virtual int getObjectId() const;
	virtual int getPercentage() const;
	virtual void setPercentage(int percentage);

	bool isBroken() const;

public slots:
	/*!
		\brief Increase dimmer level using either 10-level or 100-level frames, depending on device
	*/
	virtual void increaseLevel();

	/*!
		\brief Decrease dimmer level using either 10-level or 100-level frames, depending on device
	*/
	virtual void decreaseLevel();

	/*!
		\brief Increase dimmer level by about 10%
	*/
	void increaseLevel10();

	/*!
		\brief Decrease dimmer level by about 10%
	*/
	void decreaseLevel10();


signals:
	void percentageChanged();
	void brokenChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	Dimmer(QString name, QString key, QTime ctime, FixedTimingType ftime, bool ectime, bool point_to_point, DimmerDevice *d);

	void setBroken(bool broken);

	int percentage;
	bool broken;

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
	virtual void increaseLevel();

	/*!
		\brief Decrease dimmer group level by about 10%
	*/
	virtual void decreaseLevel();

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
	Dimmer100(QString name, QString key, QTime ctime, Light::FixedTimingType ftime, bool ectime, bool point_to_point, Dimmer100Device *d, int onspeed, int offspeed);

	virtual int getObjectId() const;

	void setOnSpeed(int speed);
	int getOnSpeed() const;

	void setOffSpeed(int speed);
	int getOffSpeed() const;

	void setStepSpeed(int speed);
	int getStepSpeed() const;

	void setStepAmount(int amount);
	int getStepAmount() const;

	virtual void setActive(bool on);
	virtual void setPercentage(int percentage);

	virtual void increaseLevel();
	virtual void decreaseLevel();

public slots:
	/*!
		\brief Increase dimmer level by \ref stepAmount at speed \ref stepSpeed.
	*/
	void increaseLevel100();

	/*!
		\brief Decrease dimmer level by \ref stepAmount at speed \ref stepSpeed.
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
	virtual void turn(bool on);

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

