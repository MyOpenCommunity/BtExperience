#ifndef STOPANDGO_OBJECTS_H
#define STOPANDGO_OBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

class StopAndGoDevice;
class StopAndGoPlusDevice;
class StopAndGoBTestDevice;


class StopAndGo : public ObjectInterface
{
	friend class TestStopAndGo;

	Q_OBJECT
	Q_PROPERTY(Status status READ getStatus NOTIFY statusChanged)
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

	virtual QString getObjectKey() const
	{
		return QString();
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::EnergyManagement;
	}

	virtual QString getName() const
	{
		return name;
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
	QString name;
	Status status;
	bool auto_reset;
};


class StopAndGoPlus : public StopAndGo
{
	friend class TestStopAndGoPlus;

	Q_OBJECT
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
	void forceClosed();

signals:
	void diagnosticChanged();
	void forceClosedComplete(bool success);

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	StopAndGoPlusDevice *dev;
	bool diagnostic;
};


class StopAndGoBTest : public StopAndGo
{
	friend class TestStopAndGoBTest;

	Q_OBJECT
	Q_PROPERTY(bool autoTest READ getAutoTest WRITE setAutoTest NOTIFY autoTestChanged)
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
