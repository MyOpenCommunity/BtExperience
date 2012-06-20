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
	if (dev_probe)
	{
		connect(dev_probe, SIGNAL(valueReceived(DeviceValues)),
				SLOT(valueReceived(DeviceValues)));
	}

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

int SplitBasicScenario::getCount() const
{
	return program_list.size();
}

void SplitBasicScenario::setProgram(QString program)
{
	if (program.isEmpty())
	{
		qWarning() << QString("SplitBasicScenario::setProgram(): "
							  "program cannot be empty");
		return;
	}

	if (!program_list.contains(program))
	{
		qWarning() << QString("SplitBasicScenario::setProgram(%1): "
							  "Program not present in configured "
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
	if (actual_program == tr("off"))
		sendOffCommand();
	else
		sendScenarioCommand();
}

int SplitBasicScenario::getTemperature() const
{
	return bt2Celsius(temperature);
}
