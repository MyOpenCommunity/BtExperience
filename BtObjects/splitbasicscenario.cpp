#include "splitbasicscenario.h"

#include <QDebug>


SplitBasicScenario::SplitBasicScenario(QString name,
									   QString key,
									   AirConditioningDevice *d,
									   QString command,
									   QObject *parent) :
	ObjectInterface(parent)
{
	dev = d;

	this->command = command;
	this->key = key;
	this->name = name;
	// TODO read values from somewhere or implement something valueReceived-like
	dev->setOffCommand(QString("18"));
	program_list <<
					"manual" <<
					"command 1" <<
					"command 2";
	program_list << tr("off"); // off must always be present
	actual_program = QString();
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
	Q_ASSERT_X(!program.isEmpty(), qPrintable(QString("SplitBasicScenario::setProgram").arg(program)), "program cannot be empty.");
	Q_ASSERT_X(program_list.contains(program), qPrintable(QString("SplitBasicScenario::setProgram").arg(program)), "program must be known.");

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
