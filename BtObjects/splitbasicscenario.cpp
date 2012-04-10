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
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	this->command = command;
	this->key = key;
	this->name = name;
	// TODO read values from somewhere or implement something valueReceived-like
	this->enabled = true;
}

void SplitBasicScenario::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		++it;
	}
}

void SplitBasicScenario::sendScenarioCommand()
{
	dev->activateScenario(command);
}

bool SplitBasicScenario::isEnabled() const
{
	return enabled;
}

void SplitBasicScenario::setEnabled(bool enable)
{
	// TODO save value somewhere
	enabled = enable;
	emit enabledChanged();
}
