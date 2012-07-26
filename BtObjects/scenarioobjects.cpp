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
	objects << new SimpleScenario(3, "mattino", bt_global::add_device_to_cache(new ScenarioDevice("39")));
	objects << new SimpleScenario(1, "sera", bt_global::add_device_to_cache(new ScenarioDevice("39")));
	objects << new ScenarioModule(1, "cinema", bt_global::add_device_to_cache(new ScenarioDevice("40")));
	objects << new ScenarioModule(2, "in vacanza", bt_global::add_device_to_cache(new ScenarioDevice("40")));
	objects << new ScenarioModule(2, "party", bt_global::add_device_to_cache(new ScenarioDevice("41")));
	objects << new AdvancedScenario(new DeviceConditionObject(DeviceCondition::LIGHT), new TimeConditionObject);
	objects << new AdvancedScenario(new DeviceConditionObject(DeviceCondition::TEMPERATURE), new TimeConditionObject);
	objects << new AdvancedScenario(new DeviceConditionObject(DeviceCondition::DIMMING), new TimeConditionObject);
	objects << new AdvancedScenario(new DeviceConditionObject(DeviceCondition::AMPLIFIER), new TimeConditionObject);

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


TimeConditionObject::TimeConditionObject()
{
	hours = 0;
	minutes = 10;
}

int TimeConditionObject::getHours() const
{
	return hours;
}

void TimeConditionObject::setHours(int h)
{
	if (h != hours && h >= 0 && h <= 255)
	{
		hours = h;
		emit hoursChanged();
	}
}

void TimeConditionObject::setMinutes(int m)
{
	if (m != minutes && m >= 0 && m <= 59)
	{
		minutes = m;
		emit minutesChanged();
	}
}

int TimeConditionObject::getMinutes() const
{
	return minutes;
}


DeviceConditionObject::DeviceConditionObject(DeviceCondition::Type type)
{
	// TODO: read the condition type, trigger, description and other stuff from the
	// configuration file
	condition_type = type;
	on_off = false;
	device_cond = 0;

	QString trigger = "0"; // trigger
	QString w = "0"; // where
	int oid = 0; // openserver id
	bool external = false;

	switch (condition_type)
	{
	case DeviceCondition::LIGHT:
		description = "Light";
		device_cond = new DeviceConditionLight(this, trigger, w, oid, NOT_PULL);
		break;
	case DeviceCondition::DIMMING:
		description = "Dimmer";
		device_cond = new DeviceConditionDimming(this, trigger, w, oid, NOT_PULL, false);
		break;
	case DeviceCondition::EXTERNAL_PROBE:
		external = true;
		w += "00";
	case DeviceCondition::PROBE:
	case DeviceCondition::TEMPERATURE:
		description = "Temperature";
		device_cond = new DeviceConditionTemperature(this, trigger, w, external, oid);
		break;
	case DeviceCondition::AUX:
		description = "Aux";
		device_cond = new DeviceConditionAux(this, trigger, w);
		break;
	case DeviceCondition::AMPLIFIER:
		description = "Amplifier";
		device_cond = new DeviceConditionVolume(this, "-1", w, false);
		break;
	case DeviceCondition::DIMMING100:
		description = "Dimmer";
		device_cond = new DeviceConditionDimming100(this, trigger, w, oid, NOT_PULL, false);
		break;
	default:
		qFatal("Unknown device condition: %d", condition_type);
	}

	if (on_off)
		on_state = device_cond->getState();
	else
		on_state = device_cond->getDefaultState();

	// force update
	device_cond->setState(device_cond->getState());
}



void DeviceConditionObject::updateText(int min_condition_value, int max_condition_value)
{
	bool new_on_off;
	QString new_range_description;

	switch (condition_type)
	{
	case DeviceCondition::LIGHT:
	case DeviceCondition::AUX:
		Q_UNUSED(max_condition_value)
		new_on_off = min_condition_value > 0;
		break;

	case DeviceCondition::DIMMING:
	case DeviceCondition::DIMMING100:
		if (min_condition_value == 0)
		{
			new_on_off = false;
			min_condition_value = on_state.first;
			max_condition_value = on_state.second;
		}
		else
			new_on_off = true;

		if (condition_type == DeviceCondition::DIMMING)
			new_range_description = QString("%1% - %2%").arg(min_condition_value * 10).arg(max_condition_value * 10);
		else
			new_range_description = QString("%1% - %2%").arg(min_condition_value).arg(max_condition_value);
		break;

	case DeviceCondition::AMPLIFIER:
		if (min_condition_value == -1)
		{
			new_on_off = false;
			min_condition_value = on_state.first;
			max_condition_value = on_state.second;
		}
		else
			new_on_off = true;

		if (min_condition_value == 0 && max_condition_value == 31)
		{
			 new_range_description = QString();
		}
		else
		{
			int val_min = min_condition_value;
			int val_max = max_condition_value;
			int vmin = (val_min == 0 ? 0 : (10 * (val_min <= 15 ? val_min/3 : (val_min-1)/3) + 1));
			int vmax = 10 * (val_max <= 15 ? val_max/3 : (val_max-1)/3);
			new_range_description = QString("%1% - %2%").arg(vmin).arg(vmax);
		}
		break;

	case DeviceCondition::EXTERNAL_PROBE:
	case DeviceCondition::PROBE:
	case DeviceCondition::TEMPERATURE:
	{
		Q_UNUSED(max_condition_value)
		// TODO: what is the right locale to use for BtExperience?
		QLocale loc(QLocale::Italian);
		new_range_description = loc.toString(min_condition_value / 10.0, 'f', 1) + TEMP_DEGREES"C \2611"TEMP_DEGREES"C";
		break;
	}
	default:
		qFatal("Unknown device condition: %d", condition_type);
	}

	if (new_on_off != on_off)
	{
		on_off = new_on_off;
		emit onOffChanged();
	}

	if (new_on_off && device_cond)
		on_state = device_cond->getState();

	if (new_range_description != range_description)
	{
		range_description = new_range_description;
		emit rangeChanged();
	}
}

QString DeviceConditionObject::getDescription() const
{
	return description;
}

QVariant DeviceConditionObject::getRange() const
{
	if (condition_type == DeviceCondition::LIGHT ||
		condition_type == DeviceCondition::AUX)
		return QVariant();
	return range_description;
}

QVariant DeviceConditionObject::getOnOff() const
{
	if (condition_type == DeviceCondition::EXTERNAL_PROBE ||
		condition_type == DeviceCondition::PROBE ||
		condition_type == DeviceCondition::TEMPERATURE)
		return QVariant();
	return on_off;
}

void DeviceConditionObject::setOnOff(QVariant value)
{
	if (condition_type == DeviceCondition::EXTERNAL_PROBE ||
		condition_type == DeviceCondition::PROBE ||
		condition_type == DeviceCondition::TEMPERATURE)
		return;

	if (value == on_off)
		return;

	if (value.toBool())
		device_cond->setState(on_state);
	else
		device_cond->setState(device_cond->getOffState());
}

void DeviceConditionObject::conditionUp()
{
	device_cond->Up();
}

void DeviceConditionObject::conditionDown()
{
	device_cond->Down();
}


AdvancedScenario::AdvancedScenario(DeviceConditionObject *device, TimeConditionObject *time)
{
	// TODO: implement :)
	name = "Advanced scenario";
	enabled = true;
	device_obj = device;
	device_obj->setParent(this);
	time_obj = time;
	time_obj->setParent(this);
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

QObject *AdvancedScenario::getDeviceCondition() const
{
	return device_obj;
}

QObject *AdvancedScenario::getTimeCondition() const
{
	return time_obj;
}

void AdvancedScenario::start()
{
	qDebug() << "START the advanced scenario";
	// TODO: implement :)
}

