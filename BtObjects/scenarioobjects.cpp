#include "scenarioobjects.h"
#include "scenario_device.h"
#include "devices_cache.h"
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
		QDomNode scen = getChildWithName(ist, "scen");
		QDomNodeList childs = scen.childNodes();
		QString act_frame, act_descr;

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
				act_frame = getTextChild(child, "open");
				act_descr = getTextChild(child, "descr");
			}
		}

		bool status = getTextChild(scen, "status").toInt();
		int days = getTextChild(scen, "days").toInt();

		obj_list << ObjectPair(uii, new AdvancedScenario(dc, tc, status, days, act_frame, act_descr, v.value("descr")));
	}
	return obj_list;
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
	return start_frame.isEmpty();
}

bool ScheduledScenario::hasStop() const
{
	return stop_frame.isEmpty();
}

bool ScheduledScenario::hasEnable() const
{
	return enable_frame.isEmpty();
}

bool ScheduledScenario::hasDisable() const
{
	return disable_frame.isEmpty();
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

void TimeConditionObject::resetTimer()
{
	const int MSECS_DAY = 24 * 60 * 60 * 1000;
	QTime now = QTime::currentTime();
	int msecsto = now.msecsTo(QTime(hours, minutes));

	// make it positive and < MSECS_DAY
	msecsto = (msecsto % MSECS_DAY + MSECS_DAY) % MSECS_DAY;

	qDebug("(re)starting timer with interval = %d", msecsto);
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
		{
			range_values = QVariantList() << min_condition_value * 10 << max_condition_value * 10;
			new_range_description = QString("%1% - %2%").arg(min_condition_value * 10).arg(max_condition_value * 10);
		}
		else
		{
			range_values = QVariantList() << min_condition_value << max_condition_value;
			new_range_description = QString("%1% - %2%").arg(min_condition_value).arg(max_condition_value);
		}
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
			range_values = QVariantList() << 1 << 100;
			new_range_description = QString();
		}
		else
		{
			int val_min = min_condition_value;
			int val_max = max_condition_value;
			int vmin = (val_min == 0 ? 0 : (10 * (val_min <= 15 ? val_min/3 : (val_min-1)/3) + 1));
			int vmax = 10 * (val_max <= 15 ? val_max/3 : (val_max-1)/3);
			range_values = QVariantList() << vmin << vmax;
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
		new_on_off = true;
		range_values = QVariantList() << min_condition_value / 10.0;
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

QVariantList DeviceConditionObject::getRangeValues() const
{
	return range_values;
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


AdvancedScenario::AdvancedScenario(DeviceConditionObject *device, TimeConditionObject *time, bool _enabled, int _days, QString _action_frame, QString _action_description, QString description)
{
	name = description;
	enabled = _enabled;
	days = _days;
	action_frame = _action_frame;
	action_description = _action_description;
	device_obj = device;
	time_obj = time;
	dev = bt_global::add_device_to_cache(new RawDevice, NO_INIT);

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
	if (action_frame.isEmpty())
	{
		qDebug("Action frame not set for scenario");
		return;
	}
	qDebug() << "START the advanced scenario" << action_frame;
	dev->sendCommand(action_frame);
	emit started();
}

void AdvancedScenario::save()
{
	if (time_obj)
		time_obj->save();
	if (device_obj)
		device_obj->save();

	// TODO save to configuration file
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
