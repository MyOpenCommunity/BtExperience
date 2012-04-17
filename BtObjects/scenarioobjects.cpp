#include "scenarioobjects.h"
#include "scenario_device.h"
#include "devices_cache.h"

#include <QDomNode>

QList<ObjectInterface *> createScenarioSystem(const QDomNode &xml_node, int id)
{
	Q_UNUSED(xml_node);
	Q_UNUSED(id);

	QList<ObjectInterface *> objects;
	objects << new SimpleScenario(3, "mattino", bt_global::add_device_to_cache(new ScenarioDevice("19")));
	objects << new SimpleScenario(1, "sera", bt_global::add_device_to_cache(new ScenarioDevice("19")));
	return objects;
}


SimpleScenario::SimpleScenario(int scenario, QString _name, ScenarioDevice *d)
{
	scenario_number = scenario;
	name = _name;
	dev = d;
}

void SimpleScenario::activate()
{
	dev->activateScenario(scenario_number);
}


ScenarioModule::ScenarioModule(int scenario, QString _name, ScenarioDevice *d) :
	SimpleScenario(scenario, _name, d)
{
	status = Locked;
}

ScenarioModule::Status ScenarioModule::getStatus()
{
	return status;
}

void ScenarioModule::startProgramming()
{
}

void ScenarioModule::stopProgramming()
{
}

void ScenarioModule::valueReceived(const DeviceValues &values_list)
{

}

