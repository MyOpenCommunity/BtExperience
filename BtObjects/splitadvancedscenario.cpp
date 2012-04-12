#include "splitadvancedscenario.h"
#include "probe_device.h"
#include "scaleconversion.h"

#include <QDebug>


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
											 QObject *parent) :
	ObjectInterface(parent)
{
	dev = d;
	dev_probe = d_probe;
	connect(dev_probe, SIGNAL(valueReceived(DeviceValues)),
			SLOT(valueReceived(DeviceValues)));

	this->command = command;
	this->key = key;
	this->name = name;
	program_list = programs;
	actual_program.name = QString();
	actual_program.mode = SplitProgram::ModeOff;
	actual_program.swing = SplitProgram::SwingOff;
	actual_program.temperature = 200;
	actual_program.speed = SplitProgram::SpeedSilent;
	temperature = 200;
}

void SplitAdvancedScenario::valueReceived(const DeviceValues &values_list)
{
	temperature = values_list[NonControlledProbeDevice::DIM_TEMPERATURE].toInt();
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

QString SplitAdvancedScenario::getProgram() const
{
	return actual_program.name;
}

QStringList SplitAdvancedScenario::getPrograms() const
{
	QStringList result;
	for(int i = 0; i < program_list.size(); ++i)
		result << program_list.at(i)->name;
	return result;
}

int SplitAdvancedScenario::getSize() const
{
	return program_list.size();
}

void SplitAdvancedScenario::setProgram(QString program)
{
	Q_ASSERT_X(!program.isEmpty(), qPrintable(QString("SplitAdvancedScenario::setProgram").arg(program)), "program cannot be empty.");

	if (actual_program.name == program)
		// nothing to do
		return;

	// looks for the program in the program list
	int p = program_list.size() - 1;
	for (; p >= 0; --p) {
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
	if (actual_program.name != program_list.at(p)->name) {
		actual_program.name = program_list.at(p)->name;
		emit programChanged();
	}
	setMode(program_list.at(p)->mode);
	setSpeed(program_list.at(p)->speed);
	setSwing(program_list.at(p)->swing);
	setSetPoint(program_list.at(p)->temperature);
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
	return actual_program.swing;
}

void SplitAdvancedScenario::setSwing(SplitProgram::Swing swing)
{
	// TODO save value somewhere
	if (actual_program.swing == swing)
		// nothing to do
		return;
	actual_program.swing = swing;
	emit swingChanged();
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
}

SplitProgram::Speed SplitAdvancedScenario::getSpeed() const
{
	return actual_program.speed;
}

void SplitAdvancedScenario::setSpeed(SplitProgram::Speed speed)
{
	// TODO save value somewhere
	if (actual_program.speed == speed)
		// nothing to do
		return;
	actual_program.speed = speed;
	emit speedChanged();
}

void SplitAdvancedScenario::ok()
{
	if(actual_program.mode == SplitProgram::ModeOff)
		sendOffCommand();
	else
		sendScenarioCommand();
}

void SplitAdvancedScenario::sendScenarioCommand()
{
	dev->setStatus(
				static_cast<AdvancedAirConditioningDevice::Mode>(actual_program.mode),
				actual_program.temperature,
				static_cast<AdvancedAirConditioningDevice::Velocity>(actual_program.speed),
				static_cast<AdvancedAirConditioningDevice::Swing>(actual_program.swing)
				);
}

void SplitAdvancedScenario::sendOffCommand()
{
	dev->turnOff();
}

int SplitAdvancedScenario::getTemperature() const
{
	return bt2Celsius(temperature);
}
