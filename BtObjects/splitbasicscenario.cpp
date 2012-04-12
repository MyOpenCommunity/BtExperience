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
	this->enabled = false;
}

void SplitBasicScenario::sendScenarioCommand()
{
	dev->activateScenario(command);
}

void SplitBasicScenario::sendOffCommand()
{
	dev->turnOff();
}

bool SplitBasicScenario::isEnabled() const
{
	return enabled;
}

void SplitBasicScenario::setEnabled(bool enable)
{
	enabled = enable;
	if (enabled)
		sendScenarioCommand();
	else
		sendOffCommand();
	emit enabledChanged();
}
