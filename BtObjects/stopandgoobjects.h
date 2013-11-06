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

#ifndef STOPANDGO_OBJECTS_H
#define STOPANDGO_OBJECTS_H

/*!
	\defgroup StopAndGo Stop and go
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues

class StopAndGoDevice;
class StopAndGoPlusDevice;
class StopAndGoBTestDevice;
class QDomNode;


QList<ObjectPair> parseStopAndGo(const QDomNode &obj);
QList<ObjectPair> parseStopAndGoPlus(const QDomNode &obj);
QList<ObjectPair> parseStopAndGoBTest(const QDomNode &obj);


/*!
	\ingroup StopAndGo
	\brief Controls the status of the Stop & Go (circuit breaker) device

	Allows reading the status of the circuit breaker and enable/disable its automatic
	reset function.

	The object id is \a ObjectInterface::IdStopAndGo, the object key is empty.
*/
class StopAndGo : public DeviceObjectInterface
{
	friend class TestStopAndGo;

	Q_OBJECT

	/*!
		\brief Gets the status of the circuit breaker

		Can be one of:
		- Closed (normal status)
		- Opened
		- Blocked: automatic rearm with unhook within 5 seconds
		- ShortCircuit
		- GroundFail
		- OverTension
	*/
	Q_PROPERTY(Status status READ getStatus NOTIFY statusChanged)

	/*!
		\brief Sets or gets the automatic reset status of the circuit breaker
	*/
	Q_PROPERTY(bool autoReset READ getAutoReset WRITE setAutoReset NOTIFY autoResetChanged)

	Q_ENUMS(Status)

public:
	enum Status
	{
		Unknown = 0,
		Closed = 1,
		Opened,
		Blocked, // see #19824 for the reason of name change
		ShortCircuit,
		GroundFail,
		Overtension
	};

	StopAndGo(StopAndGoDevice *dev, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdStopAndGo;
	}

	Status getStatus() const;

	bool getAutoReset() const;
	void setAutoReset(bool active);

signals:
	void statusChanged(StopAndGo *stopGoDevice);
	void autoResetChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	StopAndGoDevice *dev;
	Status status;
	bool auto_reset;
};


/*!
	\ingroup StopAndGo
	\brief Controls the status of the Stop & Go Plus (circuit breaker) device

	Allows forcing the circuit breaker to closed in presence of an excessive load that
	would normally make it open the circuit.

	The object id is \a ObjectInterface::IdStopAndGoPlus, the object key is empty.
*/
class StopAndGoPlus : public StopAndGo
{
	friend class TestStopAndGoPlus;

	Q_OBJECT

	/*!
		\brief Sets or gets the function to automatically detect overtension and open the device
	*/
	Q_PROPERTY(bool diagnostic READ getDiagnostic WRITE setDiagnostic NOTIFY diagnosticChanged)

public:
	StopAndGoPlus(StopAndGoPlusDevice *dev, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdStopAndGoPlus;
	}

	bool getDiagnostic() const;
	void setDiagnostic(bool active);

public slots:
	void open();
	void close();

signals:
	void diagnosticChanged();

	/*!
		\brief Emitted after trying to force the closed status of the circuit breaker.
	*/
	void forceClosedComplete(bool success);

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	StopAndGoPlusDevice *dev;
	bool diagnostic;
};


/*!
	\ingroup StopAndGo
	\brief Controls the status of the Stop & Go BTest (circuit breaker) device

	Allows enabling the automatic self-test functionality of the circuit breaker.

	The object id is \a ObjectInterface::IdStopAndGoBTest, the object key is empty.
*/
class StopAndGoBTest : public StopAndGo
{
	friend class TestStopAndGoBTest;

	Q_OBJECT

	/*!
		\brief Sets and gets whether automated self-tests are enabled
	*/
	Q_PROPERTY(bool autoTest READ getAutoTest WRITE setAutoTest NOTIFY autoTestChanged)

	/*!
		\brief Sets and gets the interval (in days) between two automated self-tests
	*/
	Q_PROPERTY(int autoTestFrequency READ getAutoTestFrequency WRITE setAutoTestFrequency NOTIFY autoTestFrequencyChanged)

public:
	StopAndGoBTest(StopAndGoBTestDevice *dev, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdStopAndGoBTest;
	}

	bool getAutoTest() const;
	void setAutoTest(bool active);

	int getAutoTestFrequency() const;
	void setAutoTestFrequency(int frequency);

signals:
	void autoTestChanged();
	void autoTestFrequencyChanged();

public slots:
	void increaseAutoTestFrequency();
	void decreaseAutoTestFrequency();
	void apply();
	void reset();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	StopAndGoBTestDevice *dev;
	bool auto_test;
	QHash<int, QVariant> current, to_apply;

	enum
	{
		AUTO_TEST_FREQUENCY
	};
};

#endif // STOPANDGO_OBJECTS_H
