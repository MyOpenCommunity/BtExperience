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
class StopAndGo : public ObjectInterface
{
	friend class TestStopAndGo;

	Q_OBJECT

	/*!
		\brief Gets the status of the circuit breaker

		Can be one of:
		- Closed (normal status)
		- Opened
		- Locked
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
		Locked,
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
	void statusChanged();
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
	/*!
		\brief Tries to force the circuit breaker status to close

		After the operation completes, emits \ref forceClosedComplete() to communicate
		the success/failure status of the operation
	*/
	void forceClosed();

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

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	StopAndGoBTestDevice *dev;
	bool auto_test;
	int auto_test_frequency;
};

#endif // STOPANDGO_OBJECTS_H
