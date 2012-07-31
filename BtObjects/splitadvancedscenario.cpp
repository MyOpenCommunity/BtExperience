#include "splitadvancedscenario.h"
#include "probe_device.h"
#include "scaleconversion.h"
#include "choicelist.h"
#include "devices_cache.h"
#include "xmlobject.h"
#include "uiimapper.h"

#include <QDebug>


namespace
{
	enum ToApplyKeys
	{
		SPLIT_SPEED,
		SPLIT_SWING
	};

	QStringList mode_strings = QStringList() << "mode_off" << "mode_heating" << "mode_cooling" << "mode_fan" << "mode_dry" << "mode_auto";
	QStringList speed_strings = QStringList() << "speed_auto" << "speed_low" << "speed_medium" << "speed_high" << "speed_silent";

	QList<int> parseEnumeration(const QDomNode &node, QStringList names)
	{
		QDomNamedNodeMap attributes = node.attributes();
		QList<int> res;
		int index = 0;

		foreach (QString name, names)
		{
			if (attributes.contains("name") && attributes.namedItem(name).toAttr().value() != "-1")
				res.append(index);
			++index;
		}

		return res;
	}

	QList<int> parseEnumeration(const XmlObject &node, QStringList names)
	{
		QList<int> res;
		int index = 0;

		foreach (QString name, names)
		{
			if (node.intValue(name) != -1)
				res.append(index);
			++index;
		}

		return res;
	}
}

QList<ObjectPair> parseSplitAdvancedScenario(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString off_command = v.intValue("off_presence") ? v.value("off_cmd") : QString();
		NonControlledProbeDevice *probe = 0;
		AdvancedAirConditioningDevice *d = new AdvancedAirConditioningDevice(v.value("where"));
		QList<int> modes, speeds, swings;

		if (v.intValue("eprobe"))
		{
			QString where = getAttribute(getChildWithName(ist, "probe"), "where_probe");

			probe = bt_global::add_device_to_cache(new NonControlledProbeDevice(where, NonControlledProbeDevice::INTERNAL));
		}

		modes = parseEnumeration(v, mode_strings);

		if (v.intValue("speed_presence"))
			speeds = parseEnumeration(getChildWithName(ist, "speeds"), speed_strings);

		if (v.intValue("swing_presence"))
			swings << SplitAdvancedProgram::SwingOff << SplitAdvancedProgram::SwingOn;

		obj_list << ObjectPair(uii, new SplitAdvancedScenario(v.value("descr"), "", d, off_command, probe, modes, speeds, swings,
								      v.intValue("setpoint_min"), v.intValue("setpoint_max")));
	}
	return obj_list;
}

void parseSplitAdvancedCommand(const QDomNode &xml_node, const UiiMapper &uii_map)
{
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			SplitAdvancedScenario *s = uii_map.value<SplitAdvancedScenario>(object_uii);

			if (!s)
			{
				qWarning() << "Invalid split uii" << object_uii << "in command";
				continue;
			}

			SplitAdvancedProgram *p = new SplitAdvancedProgram(v.value("descr"), SplitAdvancedProgram::int2Mode(v.intValue("mode")),
									   v.intValue("setpoint"), SplitAdvancedProgram::int2Speed(v.intValue("speed")),
									   SplitAdvancedProgram::int2Swing(v.intValue("fan_swing")));
			s->addProgram(p);
		}
	}
}

SplitAdvancedProgram::SplitAdvancedProgram(QObject *parent) :
	QObject(parent),
	name(""),
	mode(ModeOff),
	speed(SpeedAuto),
	swing(SwingOff),
	temperature(200)
{}

SplitAdvancedProgram::SplitAdvancedProgram(
		QString _name,
		Mode mode,
		int _temperature,
		Speed speed,
		Swing swing,
		QObject *parent) : QObject(parent), mode(mode), speed(speed), swing(swing)
{
	Q_ASSERT_X(!_name.isEmpty(), "SplitAdvancedProgram::SplitAdvancedProgram", "name cannot be empty.");
	Q_ASSERT_X(_temperature >= 150, "SplitAdvancedProgram::SplitAdvancedProgram", "temperature cannot be less than 15°C.");
	Q_ASSERT_X(_temperature <= 300, "SplitAdvancedProgram::SplitAdvancedProgram", "temperature cannot be more than 30°C.");
	name = _name;
	temperature = _temperature;
}


SplitAdvancedScenario::SplitAdvancedScenario(QString _name,
											 QString _key,
											 AdvancedAirConditioningDevice *d,
											 QString _off_command,
											 NonControlledProbeDevice *d_probe,
											 QList<int> _modes,
											 QList<int> _speeds,
											 QList<int> _swings,
											 int _setpoint_min, int _setpoint_max,
											 QObject *parent) :
	ObjectInterface(parent)
{
	dev = d;
	dev_probe = d_probe;
	if (dev_probe)
		connect(dev_probe, SIGNAL(valueReceived(DeviceValues)),
				SLOT(valueReceived(DeviceValues)));

	modes = new ChoiceList(this);
	foreach (int mode, _modes)
		modes->add(mode);

	speeds = new ChoiceList(this);
	foreach (int speed, _speeds)
		speeds->add(speed);

	swings = new ChoiceList(this);
	foreach (int swing, _swings)
		swings->add(swing);

	off_command = _off_command;
	key = _key;
	name = _name;
	setpoint_min = _setpoint_min;
	setpoint_max = _setpoint_max;
	actual_program.name = QString();
	actual_program.mode = static_cast<SplitAdvancedProgram::Mode>(modes->value());
	current[SPLIT_SWING] = static_cast<SplitAdvancedProgram::Swing>(swings->value(SplitAdvancedProgram::SwingInvalid));
	actual_program.temperature = 200;
	current[SPLIT_SPEED] = static_cast<SplitAdvancedProgram::Speed>(speeds->value(SplitAdvancedProgram::SpeedInvalid));
	temperature = 200;
	reset();
	sync();
}

void SplitAdvancedScenario::sync()
{
	while (speeds->value(SplitAdvancedProgram::SpeedInvalid) != to_apply[SPLIT_SPEED].toInt())
		speeds->next();
	while (swings->value(SplitAdvancedProgram::SwingInvalid) != to_apply[SPLIT_SWING].toInt())
		swings->next();
}

QString SplitAdvancedScenario::getProgram() const
{
	return actual_program.name;
}

QStringList SplitAdvancedScenario::getPrograms() const
{
	QStringList result;
	for (int i = 0; i < program_list.size(); ++i)
		result << program_list.at(i)->name;
	return result;
}

int SplitAdvancedScenario::getCount() const
{
	return program_list.size();
}

void SplitAdvancedScenario::addProgram(SplitAdvancedProgram *program)
{
	program_list.append(program);
}

void SplitAdvancedScenario::setProgram(QString program)
{
	if (program.isEmpty())
	{
		qWarning() << QString("SplitAdvancedScenario::setProgram(): "
							  "program cannot be empty");
		return;
	}

	if (actual_program.name == program)
		// nothing to do
		return;

	// looks for the program in the program list
	int p = program_list.size() - 1;
	for (; p >= 0; --p)
	{
		if (program == program_list.at(p)->name)
			break;
	}

	// if not found, print a warning and exit
	if (p == -1)
	{
		qWarning() << QString("SplitAdvancedScenario::setProgram(%1) didn't "
							  "find the program inside available ones. "
							  "Program will not be changed.").arg(program);
		return;
	}

	// sets the choosen program
	actual_program.name = program_list.at(p)->name;
	emit programChanged();

	setMode(program_list.at(p)->mode);
	setSetPoint(program_list.at(p)->temperature);
	if (to_apply[SPLIT_SPEED] != program_list.at(p)->speed)
	{
		to_apply[SPLIT_SPEED] = program_list.at(p)->speed;
		emit speedChanged();
	}
	if (to_apply[SPLIT_SWING] != program_list.at(p)->swing)
	{
		to_apply[SPLIT_SWING] = program_list.at(p)->swing;
		emit swingChanged();
	}
	sync();
}

SplitAdvancedProgram::Mode SplitAdvancedScenario::getMode() const
{
	return actual_program.mode;
}

void SplitAdvancedScenario::setMode(SplitAdvancedProgram::Mode mode)
{
	// TODO save value somewhere
	if (actual_program.mode == mode)
		// nothing to do
		return;
	actual_program.mode = mode;
	emit modeChanged();
}

SplitAdvancedProgram::Swing SplitAdvancedScenario::getSwing() const
{
	return static_cast<SplitAdvancedProgram::Swing>(to_apply[SPLIT_SWING].toInt());
}

int SplitAdvancedScenario::getSetPoint() const
{
	return actual_program.temperature;
}

int SplitAdvancedScenario::getSetPointMin() const
{
	return setpoint_min;
}

int SplitAdvancedScenario::getSetPointMax() const
{
	return setpoint_max;
}

void SplitAdvancedScenario::setSetPoint(int setpoint)
{
	if (setpoint < setpoint_min || setpoint > setpoint_max)
		return;
	// TODO save value somewhere
	if (actual_program.temperature == setpoint)
		// nothing to do
		return;
	actual_program.temperature = setpoint;
	emit setPointChanged();
	sync();
}

SplitAdvancedProgram::Speed SplitAdvancedScenario::getSpeed() const
{
	return static_cast<SplitAdvancedProgram::Speed>(to_apply[SPLIT_SPEED].toInt());
}

void SplitAdvancedScenario::resetProgram()
{
	// resets the name of the actual program (but data is still valid as custom)
	if (actual_program.name.isEmpty())
		// nothing to do
		return;
	actual_program.name.clear();
	emit programChanged();
}

void SplitAdvancedScenario::nextSpeed()
{
	if (speeds->size() == 0)
		return;

	resetProgram();
	SplitAdvancedProgram::Speed old_value = static_cast<SplitAdvancedProgram::Speed>(to_apply[SPLIT_SPEED].toInt());
	speeds->next();
	to_apply[SPLIT_SPEED] = speeds->value();
	if (old_value != to_apply[SPLIT_SPEED])
		emit speedChanged();
}

void SplitAdvancedScenario::prevSpeed()
{
	if (speeds->size() == 0)
		return;

	resetProgram();
	SplitAdvancedProgram::Speed old_value = static_cast<SplitAdvancedProgram::Speed>(to_apply[SPLIT_SPEED].toInt());
	speeds->previous();
	to_apply[SPLIT_SPEED] = speeds->value();
	if (old_value != to_apply[SPLIT_SPEED])
		emit speedChanged();
}

void SplitAdvancedScenario::nextSwing()
{
	if (speeds->size() == 0)
		return;

	resetProgram();
	SplitAdvancedProgram::Swing old_value = static_cast<SplitAdvancedProgram::Swing>(to_apply[SPLIT_SWING].toInt());
	swings->next();
	to_apply[SPLIT_SWING] = swings->value();
	if (old_value != to_apply[SPLIT_SWING])
		emit swingChanged();
}

void SplitAdvancedScenario::prevSwing()
{
	if (speeds->size() == 0)
		return;

	resetProgram();
	SplitAdvancedProgram::Swing old_value = static_cast<SplitAdvancedProgram::Swing>(to_apply[SPLIT_SWING].toInt());
	swings->previous();
	to_apply[SPLIT_SWING] = swings->value();
	if (old_value != to_apply[SPLIT_SWING])
		emit swingChanged();
}

void SplitAdvancedScenario::sendScenarioCommand()
{
	dev->setStatus(
				static_cast<AdvancedAirConditioningDevice::Mode>(actual_program.mode),
				actual_program.temperature,
				static_cast<AdvancedAirConditioningDevice::Velocity>(current[SPLIT_SPEED].toInt()),
				static_cast<AdvancedAirConditioningDevice::Swing>(current[SPLIT_SWING].toInt())
				);
}

void SplitAdvancedScenario::sendOffCommand()
{
	dev->turnOff();
}

void SplitAdvancedScenario::apply()
{
	current = to_apply;

	if (actual_program.mode == SplitAdvancedProgram::ModeOff)
		sendOffCommand();
	else
		sendScenarioCommand();
}

void SplitAdvancedScenario::reset()
{
	to_apply = current;
}

void SplitAdvancedScenario::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case NonControlledProbeDevice::DIM_TEMPERATURE:
			if (it.value().toInt() != temperature)
			{
				temperature = it.value().toInt();
				emit temperatureChanged();
			}
			break;
		}
		++it;
	}
}

int SplitAdvancedScenario::getTemperature() const
{
	return bt2Celsius(temperature);
}

QObject *SplitAdvancedScenario::getModes() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ChoiceList *>(modes);
}

QObject *SplitAdvancedScenario::getSpeeds() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ChoiceList *>(speeds);
}

QObject *SplitAdvancedScenario::getSwings() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ChoiceList *>(swings);
}
