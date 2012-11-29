#include "scenarioobjects.h"
#include "scenario_device.h"
#include "devices_cache.h"
#include "shared_functions.h"
#include "xml_functions.h"
#include "xmlobject.h"

#include <QDomNode>
#include <QDebug>


QList<ObjectPair> parseScenarioUnit(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		obj_list << ObjectPair(uii, new SimpleScenario(v.intValue("what"), v.value("descr"), bt_global::add_device_to_cache(new ScenarioDevice(v.value("where")))));
	}
	return obj_list;
}

QList<ObjectPair> parseScenarioModule(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		obj_list << ObjectPair(uii, new ScenarioModule(v.intValue("what"), v.value("descr"), bt_global::add_device_to_cache(new ScenarioDevice(v.value("where")))));
	}
	return obj_list;
}

QString parseSchedCommand(const QDomNode &xml_node, QString name)
{
	QDomNode scen = getChildWithName(xml_node, "schedscen");
	QDomNode cmd = getChildWithName(scen, name);

	if (!getTextChild(cmd, "presence").toInt())
		return QString();

	return getTextChild(cmd, "open");
}

QList<ObjectPair> parseScheduledScenario(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString enable = parseSchedCommand(ist, "enable");
		QString start = parseSchedCommand(ist, "start");
		QString stop = parseSchedCommand(ist, "stop");
		QString disable = parseSchedCommand(ist, "disable");

		obj_list << ObjectPair(uii, new ScheduledScenario(v.value("descr"), enable, start, stop, disable));
	}
	return obj_list;
}

QList<ObjectPair> parseAdvancedScenario(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		DeviceConditionObject *dc = 0;
		TimeConditionObject *tc = 0;
		ActionObject *ao = 0;
		QDomNode scen = getChildWithName(ist, "scen");
		QDomNodeList childs = scen.childNodes();

		for (int i = 0; i < childs.size(); ++i)
		{
			if (!childs.at(i).isElement())
				continue;
			QDomElement child = childs.at(i).toElement();

			if (child.tagName() == "time" && getTextChild(child, "status") == "1")
			{
				int hour = getTextChild(child, "hour").toInt();
				int minute = getTextChild(child, "minute").toInt();

				tc = new TimeConditionObject(hour, minute);
			}
			else if (child.tagName() == "device" && getTextChild(child, "status") == "1")
			{
				DeviceCondition::Type type = static_cast<DeviceCondition::Type>(getTextChild(child, "objectID").toInt());
				QString descr = getTextChild(child, "descr");
				QString trigger = getTextChild(child, "trigger");
				QString where = getTextChild(child, "where");
				PullMode pull_mode = getTextChild(child, "pul") == "1" ? PULL : NOT_PULL;

				dc = new DeviceConditionObject(type, descr, trigger, where, pull_mode);
			}
			else if (child.tagName() == "action")
			{
				ActionObject::Type type = static_cast<ActionObject::Type>(getTextChild(child, "objectID").toInt());
				ao = new ActionObject(getTextChild(child, "descr"), getTextChild(child, "open"), type, getTextChild(child, "commandID").toInt());
			}
		}

		bool status = getTextChild(scen, "status").toInt();
		int days = getTextChild(scen, "days").toInt();

		obj_list << ObjectPair(uii, new AdvancedScenario(dc, tc, ao, status, days, v.value("descr")));
	}
	return obj_list;
}

void updateAdvancedScenario(QDomNode node, AdvancedScenario *item)
{
	QDomNode scen = getChildWithName(node, "scen");
	QDomNodeList childs = scen.childNodes();

	for (int i = 0; i < childs.size(); ++i)
	{
		if (!childs.at(i).isElement())
			continue;
		QDomElement child = childs.at(i).toElement();

		if (child.tagName() == "time" && getTextChild(child, "status") == "1")
		{
			TimeConditionObject *tc = qobject_cast<TimeConditionObject *>(item->getTimeCondition());

			setTextChild(child, "hour", QString::number(tc->getHours()));
			setTextChild(child, "minute", QString::number(tc->getMinutes()));
		}
		else if (child.tagName() == "device" && getTextChild(child, "status") == "1")
		{
			DeviceConditionObject *dc = qobject_cast<DeviceConditionObject *>(item->getDeviceCondition());

			setTextChild(child, "trigger", dc->getTriggerAsString());
		}
	}

	setTextChild(scen, "days", QString::number(item->getDays()));
}


SimpleScenario::SimpleScenario(int scenario, QString _name, ScenarioDevice *d) :
	DeviceObjectInterface(d)
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
	connect(d, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
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

void ScenarioModule::deleteScenario()
{
	dev->deleteScenario(scenario_number);
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
			else
			{
				// Change the value on STOP since the device won't warn us
				// if an UNLOCK frame arrives while the device is in unlock state.
				if (status != Unlocked)
					changeStatus(Unlocked);
			}
		}
			break;
		}
	}
}

void ScenarioModule::changeStatus(ScenarioModule::Status new_status)
{
	if (status == Editing && new_status == Unlocked)
		emit programmingStopped(this);
	// Please notice: you need to check if new_status == status outside!
	status = new_status;
	emit statusChanged(this);
}


ScheduledScenario::ScheduledScenario(QString _name, QString enable, QString start, QString stop, QString disable)
{
	name = _name;
	enable_frame = enable;
	start_frame = start;
	stop_frame = stop;
	disable_frame = disable;
	dev = bt_global::add_device_to_cache(new RawDevice, NO_INIT);
}

void ScheduledScenario::start()
{
	if (!start_frame.isEmpty())
		dev->sendCommand(start_frame);
}

void ScheduledScenario::stop()
{
	if (!stop_frame.isEmpty())
		dev->sendCommand(stop_frame);
}

void ScheduledScenario::enable()
{
	if (!enable_frame.isEmpty())
		dev->sendCommand(enable_frame);
}

void ScheduledScenario::disable()
{
	if (!disable_frame.isEmpty())
		dev->sendCommand(disable_frame);
}

bool ScheduledScenario::hasStart() const
{
	return !start_frame.isEmpty();
}

bool ScheduledScenario::hasStop() const
{
	return !stop_frame.isEmpty();
}

bool ScheduledScenario::hasEnable() const
{
	return !enable_frame.isEmpty();
}

bool ScheduledScenario::hasDisable() const
{
	return !disable_frame.isEmpty();
}


ActionObject::ActionObject(QString _target, QString _frame, Type _type, int _command_id)
{
	target = _target;
	frame = _frame;
	dev = bt_global::add_device_to_cache(new RawDevice, NO_INIT);
	type = _type;
	command_id = _command_id;
	buildDescriptionMap();
}

void ActionObject::sendFrame()
{
	if (frame.isEmpty())
	{
		qDebug("Action frame not set for ActionObject: %s", qPrintable(target));
		return;
	}
	dev->sendCommand(frame);
}

QString ActionObject::getTarget() const
{
	return target;
}

QString ActionObject::getDescription() const
{
	if (id_to_descr.contains(command_id))
		return trUtf8(id_to_descr[command_id].toUtf8());

	return trUtf8(id_to_descr[-1].toUtf8()); // contains the default
}

void ActionObject::buildDescriptionMap()
{
	switch (type)
	{
	case ActionLight:
	case ActionFan:
	case ActionWatering:
	case ActionControlledSocket:
		id_to_descr[0] = QT_TR_NOOP("OFF");
		id_to_descr[1] = QT_TR_NOOP("ON");
		id_to_descr[-1] = id_to_descr[0];
		break;

	case ActionDimmer:
		id_to_descr[0] = QT_TR_NOOP("OFF");
		id_to_descr[1] = QT_TR_NOOP("ON");
		id_to_descr[2] = QT_TR_NOOP("20%");
		id_to_descr[3] = QT_TR_NOOP("30%");
		id_to_descr[4] = QT_TR_NOOP("40%");
		id_to_descr[5] = QT_TR_NOOP("50%");
		id_to_descr[6] = QT_TR_NOOP("60%");
		id_to_descr[7] = QT_TR_NOOP("70%");
		id_to_descr[8] = QT_TR_NOOP("80%");
		id_to_descr[9] = QT_TR_NOOP("90%");
		id_to_descr[10] = QT_TR_NOOP("100%");
		id_to_descr[-1] = id_to_descr[0];
		break;

	case ActionTimedLights:
		id_to_descr[11] = QT_TR_NOOP("1 min.");
		id_to_descr[12] = QT_TR_NOOP("2 min.");
		id_to_descr[13] = QT_TR_NOOP("3 min.");
		id_to_descr[15] = QT_TR_NOOP("4 min.");
		id_to_descr[16] = QT_TR_NOOP("5 min.");
		id_to_descr[17] = QT_TR_NOOP("15 min.");
		id_to_descr[-1] = id_to_descr[11];
		break;

	case ActionDimmer100:
		id_to_descr[18] = QT_TR_NOOP("OFF");
		id_to_descr[19] = QT_TR_NOOP("ON");
		id_to_descr[20] = QT_TR_NOOP("Level");
		id_to_descr[-1] = id_to_descr[18];
		break;

	case ActionShutter:
	case ActionTilting:
		id_to_descr[21] = QT_TR_NOOP("Up");
		id_to_descr[22] = QT_TR_NOOP("Down");
		id_to_descr[23] = QT_TR_NOOP("Stop");
		id_to_descr[-1] = id_to_descr[21];
		break;

	case ActionCurtain:
	case ActionAutomationGate:
		id_to_descr[21] = QT_TR_NOOP("Open");
		id_to_descr[22] = QT_TR_NOOP("Close");
		id_to_descr[23] = QT_TR_NOOP("Stop");
		id_to_descr[-1] = id_to_descr[21];
		break;

	case ActionLightinGate:
		id_to_descr[1] = QT_TR_NOOP("On 1 sec.");
		id_to_descr[2] = QT_TR_NOOP("On 2 sec.");
		id_to_descr[-1] = id_to_descr[1];
		break;

	case ActionVideoDoorEntryGate:
	case ActionVideoDoorEntryLock:
		id_to_descr[24] = QT_TR_NOOP("ON");
		id_to_descr[-1] = id_to_descr[24];
		break;

	case ActionAutomationDoorLock:
		id_to_descr[90] = QT_TR_NOOP("ON");
		id_to_descr[-1] = id_to_descr[90];
		break;

	case ActionScenarioUnit:
		id_to_descr[25] = QT_TR_NOOP("Scenario 1.4");
		id_to_descr[-1] = id_to_descr[25];
		break;

	case ActionScenarioModule:
		id_to_descr[25] = QT_TR_NOOP("Scenario 1.16");
		id_to_descr[-1] = id_to_descr[25];
		break;

	case ActionControlUnit3550:
		id_to_descr[26] = QT_TR_NOOP("Antifreeze/thermal protection");
		id_to_descr[27] = QT_TR_NOOP("OFF");
		id_to_descr[28] = QT_TR_NOOP("Manual Temperature");
		id_to_descr[29] = QT_TR_NOOP("Heating scenario");
		id_to_descr[45] = QT_TR_NOOP("Air-conditioning scenario");
		id_to_descr[61] = QT_TR_NOOP("Heating Program");
		id_to_descr[64] = QT_TR_NOOP("Air-conditioning program");
		id_to_descr[67] = QT_TR_NOOP("Last program");
		id_to_descr[86] = QT_TR_NOOP("Set the air conditioning mode");
		id_to_descr[87] = QT_TR_NOOP("Set the heating mode");
		id_to_descr[88] = QT_TR_NOOP("Last scenario");
		id_to_descr[-1] = id_to_descr[27];
		break;

	case ActionZone3550:
		id_to_descr[26] = QT_TR_NOOP("Antifreeze/thermal protection");
		id_to_descr[27] = QT_TR_NOOP("OFF");
		id_to_descr[28] = QT_TR_NOOP("Manual Temperature");
		id_to_descr[68] = QT_TR_NOOP("Automatic");
		id_to_descr[-1] = id_to_descr[27];
		break;

	case ActionAmplifier:
		id_to_descr[70] = QT_TR_NOOP("OFF");
		id_to_descr[71] = QT_TR_NOOP("ON");
		id_to_descr[72] = QT_TR_NOOP("Volume");
		id_to_descr[-1] = id_to_descr[70];
		break;

	case ActionControlUnit4695:
		id_to_descr[73] = QT_TR_NOOP("Antifreeze/thermal protection");
		id_to_descr[74] = QT_TR_NOOP("OFF");
		id_to_descr[75] = QT_TR_NOOP("Manual Temperature");
		id_to_descr[76] = QT_TR_NOOP("Timed manual Temperature");
		id_to_descr[77] = QT_TR_NOOP("Heating Program");
		id_to_descr[80] = QT_TR_NOOP("Air-conditioning program");
		id_to_descr[83] = QT_TR_NOOP("Last program");
		id_to_descr[84] = QT_TR_NOOP("Set the air conditioning mode");
		id_to_descr[85] = QT_TR_NOOP("Set the heating mode");
		id_to_descr[-1] = id_to_descr[74];
		break;

	case ActionZone3550Fan:
		id_to_descr[26] = QT_TR_NOOP("Antifreeze/thermal protection");
		id_to_descr[27] = QT_TR_NOOP("OFF");
		id_to_descr[28] = QT_TR_NOOP("Manual Temperature");
		id_to_descr[68] = QT_TR_NOOP("Automatic");
		id_to_descr[89] = QT_TR_NOOP("Set the fan-coil speed");
		id_to_descr[-1] = id_to_descr[27];
		break;

	case ActionCen:
		id_to_descr[94] = QT_TR_NOOP("Start pressure button");
		id_to_descr[95] = QT_TR_NOOP("Short pressure button");
		id_to_descr[96] = QT_TR_NOOP("Release after extended pressure button");
		id_to_descr[97] = QT_TR_NOOP("Extended pressure button");
		id_to_descr[-1] = id_to_descr[94];
		break;

	case ActionCenPlus:
		id_to_descr[98] = QT_TR_NOOP("Short pressure button");
		id_to_descr[99] = QT_TR_NOOP("Start pressure button");
		id_to_descr[100] = QT_TR_NOOP("Release after extended pressure button");
		id_to_descr[101] = QT_TR_NOOP("Extended pressure button");
		id_to_descr[-1] = id_to_descr[98];
		break;

	case ActionScenarioPlus:
		id_to_descr[102] = QT_TR_NOOP("Activate Scenarios");
		id_to_descr[103] = QT_TR_NOOP("Scenario OFF");
		id_to_descr[104] = QT_TR_NOOP("Increase level");
		id_to_descr[105] = QT_TR_NOOP("Decrease level");
		id_to_descr[106] = QT_TR_NOOP("Stop");
		id_to_descr[-1] = id_to_descr[103];
		break;

	case ActionAux:
		id_to_descr[109] = QT_TR_NOOP("OFF");
		id_to_descr[110] = QT_TR_NOOP("ON");
		id_to_descr[-1] = id_to_descr[109];
		break;

	default:
		qFatal("Unknown type: %d", type);
	}
}


TimeConditionObject::TimeConditionObject(int _hours, int _minutes)
{
	hours = condition_hours = _hours;
	minutes = condition_minutes = _minutes;
	timer.setSingleShot(true);

	connect(&timer, SIGNAL(timeout()), this, SIGNAL(satisfied()));
	connect(&timer, SIGNAL(timeout()), this, SLOT(resetTimer()));

	resetTimer();
}

void TimeConditionObject::save()
{
	condition_hours = hours;
	condition_minutes = minutes;
	resetTimer();
}

void TimeConditionObject::reset()
{
	setHours(condition_hours);
	setMinutes(condition_minutes);
}

int TimeConditionObject::getHours() const
{
	return hours;
}

void TimeConditionObject::setHours(int h)
{
	QTime t(hours, minutes);
	QTime new_time = addHours(t, h);

	if (new_time.hour() != hours)
	{
		hours = new_time.hour();
		emit hoursChanged();
	}
}

void TimeConditionObject::setMinutes(int m)
{
	QTime t(hours, minutes);
	QTime new_time = addMinutes(t, m);

	if (new_time.minute() != minutes)
	{
		minutes = new_time.minute();
		emit minutesChanged();
	}
	if (new_time.hour() != hours)
	{
		hours = new_time.hour();
		emit hoursChanged();
	}
}

int TimeConditionObject::getMinutes() const
{
	return minutes;
}

void TimeConditionObject::resetTimer()
{
	const int MSECS_DAY = 24 * 60 * 60 * 1000;
	QTime now = QTime::currentTime();
	int msecsto = now.msecsTo(QTime(hours, minutes));

	// make it positive and < MSECS_DAY
	msecsto = (msecsto % MSECS_DAY + MSECS_DAY) % MSECS_DAY;

	qDebug("(re)starting timer with interval of msecs = %d", msecsto);
	timer.start(msecsto);
}


DeviceConditionObject::DeviceConditionObject(DeviceCondition::Type type, QString _description, QString trigger, QString where, PullMode pull_mode)
{
	description = _description;
	condition_type = type;
	on_off = false;
	device_cond = 0;

	bool external = false;

	switch (condition_type)
	{
	case DeviceCondition::LIGHT:
		device_cond = new DeviceConditionLight(this, trigger, where, 0, pull_mode);
		break;
	case DeviceCondition::DIMMING:
		device_cond = new DeviceConditionDimming(this, trigger, where, 0, pull_mode, false);
		break;
	case DeviceCondition::EXTERNAL_PROBE:
		external = true;
		where += "00";
	case DeviceCondition::PROBE:
	case DeviceCondition::TEMPERATURE:
		device_cond = new DeviceConditionTemperature(this, trigger, where, external, 0);
		break;
	case DeviceCondition::AUX:
		device_cond = new DeviceConditionAux(this, trigger, where);
		break;
	case DeviceCondition::AMPLIFIER:
		device_cond = new DeviceConditionVolume(this, trigger, where, false);
		break;
	case DeviceCondition::DIMMING100:
		device_cond = new DeviceConditionDimming100(this, trigger, where, 0, pull_mode, false);
		break;
	default:
		qFatal("Unknown device condition: %d", condition_type);
	}

	device_cond->setSupportedInitMode(device::DISABLED_INIT);
	connect(device_cond, SIGNAL(condSatisfied()), this, SIGNAL(satisfied()));

	if (on_off)
		on_state = device_cond->getState();
	else
		on_state = device_cond->getDefaultState();

	// hack to force label update; the problem is that
	// the first updateText() is called when on_state is not set yet,
	// and we do not have a DeviceConditon pointer to query the
	// default value
	if (!on_off)
		device_cond->setState(device_cond->getState());
}

void DeviceConditionObject::enableObject()
{
	device_cond->setSupportedInitMode(device::NORMAL_INIT);
}

void DeviceConditionObject::updateText(int min_condition_value, int max_condition_value)
{
	bool new_on_off;
	QVariantList new_range_values;

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
			new_range_values = QVariantList() << min_condition_value * 10 << max_condition_value * 10;
		else
			new_range_values = QVariantList() << min_condition_value << max_condition_value;
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
			new_range_values = QVariantList() << 1 << 100;
		else
		{
			int val_min = min_condition_value;
			int val_max = max_condition_value;
			int vmin = (val_min == 0 ? 0 : (10 * (val_min <= 15 ? val_min/3 : (val_min-1)/3) + 1));
			int vmax = 10 * (val_max <= 15 ? val_max/3 : (val_max-1)/3);
			new_range_values = QVariantList() << vmin << vmax;
		}
		break;

	case DeviceCondition::EXTERNAL_PROBE:
	case DeviceCondition::PROBE:
	case DeviceCondition::TEMPERATURE:
	{
		Q_UNUSED(max_condition_value)
		new_on_off = true;
		new_range_values = QVariantList() << min_condition_value / 10.0;
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

	if (new_range_values != range_values)
	{
		range_values = new_range_values;
		emit rangeChanged();
	}
}

QString DeviceConditionObject::getDescription() const
{
	return description;
}

QVariantList DeviceConditionObject::getRangeValues() const
{
	return range_values;
}

DeviceConditionObject::Type DeviceConditionObject::getConditionType() const
{
	return static_cast<Type>(condition_type);
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

void DeviceConditionObject::save()
{
	device_cond->save();
}

void DeviceConditionObject::reset()
{
	device_cond->reset();
}

bool DeviceConditionObject::isSatisfied() const
{
	return device_cond->isTrue();
}

QString DeviceConditionObject::getTriggerAsString() const
{
	return device_cond->getConditionAsString();
}

AdvancedScenario::AdvancedScenario(DeviceConditionObject *device, TimeConditionObject *time, ActionObject *action, bool _enabled, int _days, QString description)
{
	name = description;
	enabled = _enabled;
	days = _days;
	action_obj = action;
	device_obj = device;
	time_obj = time;

	if (device_obj)
	{
		device_obj->setParent(this);
		connect(device_obj, SIGNAL(satisfied()),
			this, SLOT(deviceConditionSatisfied()));
	}
	if (time_obj)
	{
		time_obj->setParent(this);
		connect(time_obj, SIGNAL(satisfied()),
			this, SLOT(timeConditionSatisfied()));
	}

	Q_ASSERT_X(action_obj, "AdvancedScenario::AdvancedScenario", "The action object is mandatory!");
	action_obj->setParent(this);
}

void AdvancedScenario::enableObject()
{
	if (device_obj)
		device_obj->enableObject();
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

bool AdvancedScenario::isDayEnabled(int day) const
{
	// map to 0-6 -> monday-sunday
	if (day == 0)
		day = 6;
	else
		day -= 1;

	return days & (1 << day);
}

void AdvancedScenario::setDayEnabled(int day, bool enabled)
{
	if (isDayEnabled(day) == enabled)
		return;

	// map to 0-6 -> monday-sunday
	if (day == 0)
		day = 6;
	else
		day -= 1;

	if (enabled)
		days |= (1 << day);
	else
		days &= ~(1 << day);

	emit daysChanged();
}

int AdvancedScenario::getDays() const
{
	return days;
}

QObject *AdvancedScenario::getDeviceCondition() const
{
	return device_obj;
}

QObject *AdvancedScenario::getTimeCondition() const
{
	return time_obj;
}

QObject *AdvancedScenario::getAction() const
{
	return action_obj;
}

void AdvancedScenario::start()
{
	qDebug() << "START the advanced scenario";
	action_obj->sendFrame();
	emit started(getName());
}

void AdvancedScenario::save()
{
	if (time_obj)
		time_obj->save();
	if (device_obj)
		device_obj->save();

	emit persistItem();
}

void AdvancedScenario::reset()
{
	if (time_obj)
		time_obj->reset();
	if (device_obj)
		device_obj->reset();
}

void AdvancedScenario::timeConditionSatisfied()
{
	if (!enabled)
	{
		qDebug("time condition satisfied but scenario disabled");
		return;
	}
	if (!isDayEnabled(QDate::currentDate().dayOfWeek()))
	{
		qDebug("condition disabled on this week day");
		return;
	}
	if (device_obj && !device_obj->isSatisfied())
	{
		qDebug("time condition satisfied but device condition not satisfied");
		return;
	}

	start();
}

void AdvancedScenario::deviceConditionSatisfied()
{
	if (!enabled)
	{
		qDebug("device condition satisfied but scenario disabled");
		return;
	}
	// if time condition is set, the device condition is checked again
	// when the timeout expires
	if (time_obj)
		return;

	if (!isDayEnabled(QDate::currentDate().dayOfWeek()))
	{
		qDebug("condition disabled on this week day");
		return;
	}

	start();
}
