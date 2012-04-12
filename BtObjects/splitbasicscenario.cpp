#include "splitbasicscenario.h"
#include "airconditioning_device.h"
#include "probe_device.h"
#include "scaleconversion.h"

#include <QDebug>


SplitBasicScenario::SplitBasicScenario(QString name,
									   QString key,
									   AirConditioningDevice *d,
									   QString command,
									   QString off_command,
									   NonControlledProbeDevice *d_probe,
									   QStringList programs,
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
	dev->setOffCommand(off_command);
	program_list = programs;
	program_list << tr("off"); // off must always be present
	actual_program = QString();
	temperature = 200;
}

void SplitBasicScenario::valueReceived(const DeviceValues &values_list)
{
	int v = values_list[NonControlledProbeDevice::DIM_TEMPERATURE].toInt();
	if (temperature == v)
		// nothing to do
		return;
	temperature = v;
	emit temperatureChanged();
}

void SplitBasicScenario::sendScenarioCommand()
{
	dev->activateScenario(command);
}

void SplitBasicScenario::sendOffCommand()
{
	dev->turnOff();
}

QString SplitBasicScenario::getProgram() const
{
	return actual_program;
}

QStringList SplitBasicScenario::getPrograms() const
{
	return program_list;
}

int SplitBasicScenario::getSize() const
{
	return program_list.size();
}

void SplitBasicScenario::setProgram(QString program)
{
	if (program.isEmpty())
	{
		qWarning() << QString("program cannot be empty");
		return;
	}

	if (!program_list.contains(program))
	{
		qWarning() << QString("Program (%1) not present in configured "
							  "programs list").arg(program);
		return;
	}

	if (actual_program == program)
		// nothing to do
		return;

	actual_program = program;
	emit programChanged();
}

void SplitBasicScenario::ok()
{
	if(actual_program == tr("off"))
		sendOffCommand();
	else
		sendScenarioCommand();
}

int SplitBasicScenario::getTemperature() const
{
	return bt2Celsius(temperature);
}
