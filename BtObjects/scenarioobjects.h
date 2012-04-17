#ifndef SCENARIOOBJECTS_H
#define SCENARIOOBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

class ScenarioDevice;
class QDomNode;

QList<ObjectInterface *> createScenarioSystem(const QDomNode &xml_node, int id);


class SimpleScenario : public ObjectInterface
{
	Q_OBJECT

public:
	SimpleScenario(int scenario, QString _name, ScenarioDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSimpleScenario;
	}

	virtual QString getName() const
	{
		return name;
	}

	virtual QString getObjectKey() const
	{
		return QString();
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Scenarios;
	}

public slots:
	void activate();

protected:
	int scenario_number;
	QString name;
	ScenarioDevice *dev;
};

class ScenarioModule : public SimpleScenario
{
friend class TestScenarioModule;
	Q_OBJECT

	Q_PROPERTY(Status status READ getStatus NOTIFY statusChanged)

public:
	ScenarioModule(int scenario, QString _name, ScenarioDevice *d);

	enum Status
	{
		Locked = 1,
		Unlocked,
		Editing
	};

	virtual int getObjectId() const
	{
		return ObjectInterface::IdScenarioModule;
	}

	Status getStatus();

public slots:
	void startProgramming();
	void stopProgramming();

signals:
	void statusChanged();

private slots:
	void valueReceived(const DeviceValues &values_list);

private:
	void changeStatus(Status new_status);
	Status status;
};

#endif // SCENARIOOBJECTS_H
