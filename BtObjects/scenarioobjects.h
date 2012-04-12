#ifndef SCENARIOOBJECTS_H
#define SCENARIOOBJECTS_H

#include "objectinterface.h"

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

private:
	int scenario_number;
	QString name;
	ScenarioDevice *dev;
};

#endif // SCENARIOOBJECTS_H
