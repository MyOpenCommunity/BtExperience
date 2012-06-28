#include "splitadvancedscenario.h"
#include "probe_device.h"
#include "scaleconversion.h"
#include "choicelist.h"

#include <QDebug>


namespace
{
	enum ToApplyKeys
	{
		SPLIT_SPEED,
		SPLIT_SWING
	};
}

SplitProgram::SplitProgram(QObject *parent) :
	QObject(parent),
	name(""),
	mode(ModeOff),
	speed(SpeedAuto),
	swing(SwingOff),
	temperature(200)
{}

SplitProgram::SplitProgram(
		QString name,
		Mode mode,
		int temperature,
		Speed speed,
		Swing swing,
		QObject *parent) : QObject(parent), mode(mode), speed(speed), swing(swing)
{
	Q_ASSERT_X(!name.isEmpty(), "SplitProgram::SplitProgram", "name cannot be empty.");
	Q_ASSERT_X(temperature >= 160, "SplitProgram::SplitProgram", "temperature cannot be less than 16°C.");
	Q_ASSERT_X(temperature <= 300, "SplitProgram::SplitProgram", "temperature cannot be more than 30°C.");
	this->name = name;
	this->temperature = temperature;
}


SplitAdvancedScenario::SplitAdvancedScenario(QString name,
											 QString key,
											 AdvancedAirConditioningDevice *d,
											 QString command,
											 NonControlledProbeDevice *d_probe,
											 QList<SplitProgram *> programs,
											 QList<int> _modes,
											 QList<int> _speeds,
											 QList<int> _swings,
											 QObject *parent) :
	ObjectInterface(parent)
{
	dev = d;
	dev_probe = d_probe;
	if (dev_probe)
	{
		connect(dev_probe, SIGNAL(valueReceived(DeviceValues)),
				SLOT(valueReceived(DeviceValues)));
	}

	modes = new ChoiceList(this);
	foreach (int mode, _modes) {
		modes->add(mode);
	}
	speeds = new ChoiceList(this);
	foreach (int speed, _speeds) {
		speeds->add(speed);
	}
	swings = new ChoiceList(this);
	foreach (int swing, _swings) {
		swings->add(swing);
	}
	this->command = command;
	this->key = key;
	this->name = name;
	program_list = programs;
	actual_program.name = QString();
	actual_program.mode = static_cast<SplitProgram::Mode>(modes->value());
	current[SPLIT_SWING] = static_cast<SplitProgram::Swing>(swings->value());
	actual_program.temperature = 200;
	current[SPLIT_SPEED] = static_cast<SplitProgram::Speed>(speeds->value());
	temperature = 200;
	reset();
	sync();
}

void SplitAdvancedScenario::sync()
{
	while (speeds->value() != to_apply[SPLIT_SPEED].toInt())
		speeds->next();
	while (swings->value() != to_apply[SPLIT_SWING].toInt())
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
	if (actual_program.name != program_list.at(p)->name)
	{
		actual_program.name = program_list.at(p)->name;
		emit programChanged();
	}
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

SplitProgram::Mode SplitAdvancedScenario::getMode() const
{
	return actual_program.mode;
}

void SplitAdvancedScenario::setMode(SplitProgram::Mode mode)
{
	// TODO save value somewhere
	if (actual_program.mode == mode)
		// nothing to do
		return;
	actual_program.mode = mode;
	emit modeChanged();
}

SplitProgram::Swing SplitAdvancedScenario::getSwing() const
{
	return static_cast<SplitProgram::Swing>(to_apply[SPLIT_SWING].toInt());
}

int SplitAdvancedScenario::getSetPoint() const
{
	return actual_program.temperature;
}

void SplitAdvancedScenario::setSetPoint(int setPoint)
{
	// TODO save value somewhere
	if (actual_program.temperature == setPoint)
		// nothing to do
		return;
	actual_program.temperature = setPoint;
	emit setPointChanged();
	sync();
}

SplitProgram::Speed SplitAdvancedScenario::getSpeed() const
{
	return static_cast<SplitProgram::Speed>(to_apply[SPLIT_SPEED].toInt());
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
	resetProgram();
	SplitProgram::Speed old_value = static_cast<SplitProgram::Speed>(to_apply[SPLIT_SPEED].toInt());
	speeds->next();
	to_apply[SPLIT_SPEED] = speeds->value();
	if (old_value != to_apply[SPLIT_SPEED])
		emit speedChanged();
}

void SplitAdvancedScenario::prevSpeed()
{
	resetProgram();
	SplitProgram::Speed old_value = static_cast<SplitProgram::Speed>(to_apply[SPLIT_SPEED].toInt());
	speeds->previous();
	to_apply[SPLIT_SPEED] = speeds->value();
	if (old_value != to_apply[SPLIT_SPEED])
		emit speedChanged();
}

#include <iostream>
void SplitAdvancedScenario::nextSwing()
{
	resetProgram();
	SplitProgram::Swing old_value = static_cast<SplitProgram::Swing>(to_apply[SPLIT_SWING].toInt());
	swings->next();
	to_apply[SPLIT_SWING] = swings->value();
	if (old_value != to_apply[SPLIT_SWING])
		emit swingChanged();
}

void SplitAdvancedScenario::prevSwing()
{
	resetProgram();
	SplitProgram::Swing old_value = static_cast<SplitProgram::Swing>(to_apply[SPLIT_SWING].toInt());
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

	if (actual_program.mode == SplitProgram::ModeOff)
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
