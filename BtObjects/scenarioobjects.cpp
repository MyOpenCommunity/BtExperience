#include "scenarioobjects.h"
#include "scenario_device.h"
#include "devices_cache.h"

#include <QDomNode>
#include <QDebug>

QList<ObjectInterface *> createScenarioSystem(const QDomNode &xml_node, int id)
{
	Q_UNUSED(xml_node);
	Q_UNUSED(id);

	QList<ObjectInterface *> objects;
	objects << new ScheduledScenario("scheduled scenario", "enable", "start", "stop", "disable");
	objects << new AdvancedScenario;
	objects << new SimpleScenario(3, "mattino", bt_global::add_device_to_cache(new ScenarioDevice("39")));
	objects << new SimpleScenario(1, "sera", bt_global::add_device_to_cache(new ScenarioDevice("39")));
	objects << new ScenarioModule(1, "cinema", bt_global::add_device_to_cache(new ScenarioDevice("40")));
	objects << new ScenarioModule(2, "in vacanza", bt_global::add_device_to_cache(new ScenarioDevice("40")));
	objects << new ScenarioModule(2, "party", bt_global::add_device_to_cache(new ScenarioDevice("41")));

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
	dev->startProgramming(scenario_number);
}

void ScenarioModule::stopProgramming()
{
	dev->stopProgramming(scenario_number);
}

void ScenarioModule::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it;
	for (it = values_list.constBegin(); it != values_list.constEnd(); ++it)
	{
		switch (it.key())
		{
		case ScenarioDevice::DIM_LOCK:
		{
			bool is_locked = it.value().toBool();
			// TODO: this can be removed once we are sure about the behaviour
			if (status == Editing)
				qWarning() << "Got a LOCK frame in Editing status before a STOP frame; this is unexpected";

			if (is_locked && status != Locked)
				changeStatus(Locked);

			if (!is_locked && status != Unlocked)
				changeStatus(Unlocked);
		}
			break;
		case ScenarioDevice::DIM_START:
		{
			Q_ASSERT_X(it.value().canConvert<ScenarioProgrammingStatus>(), "ScenarioModule::valueReceived",
				"Cannot convert values in DIM_START");
			ScenarioProgrammingStatus val = it.value().value<ScenarioProgrammingStatus>();
			if (val.first)
			{
				int programming_scenario = val.second;
				if (programming_scenario == scenario_number && status == Unlocked)
					changeStatus(Editing);

				if (programming_scenario != scenario_number && status == Unlocked)
					changeStatus(Locked);
			}
		}
			break;
		}
	}
}

void ScenarioModule::changeStatus(ScenarioModule::Status new_status)
{
	// Please notice: you need to check if new_status == status outside!
	status = new_status;
	emit statusChanged();
}


ScheduledScenario::ScheduledScenario(QString _name, QString enable, QString start, QString stop, QString disable)
{
	name = _name;
	enable_frame = enable;
	start_frame = start;
	stop_frame = stop;
	disable_frame = disable;
}

void ScheduledScenario::start()
{
	qDebug() << "ScheduledScenario::start()";
	// TODO: implement :)
}

void ScheduledScenario::stop()
{
	qDebug() << "ScheduledScenario::stop()";
	// TODO: implement :)
}

void ScheduledScenario::enable()
{
	qDebug() << "ScheduledScenario::enable()";
	// TODO: implement :)
}

void ScheduledScenario::disable()
{
	qDebug() << "ScheduledScenario::disable()";
	// TODO: implement :)
}


AdvancedScenario::AdvancedScenario()
{
	// TODO: implement :)
	name = "Advanced scenario";
	enabled = true;
}

bool AdvancedScenario::isEnabled() const
{
	return enabled;
}

void AdvancedScenario::setEnabled(bool enable)
{
	if (enable == enabled)
		return;

	enabled = enable;
	emit enabledChanged();
}

void AdvancedScenario::start()
{
	qDebug() << "START the advanced scenario";
	// TODO: implement :)
}

