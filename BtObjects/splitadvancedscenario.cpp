#include "splitadvancedscenario.h"

#include <QDebug>


SplitAdvancedScenario::SplitAdvancedScenario(QString name,
											 QString key,
											 AdvancedAirConditioningDevice *d,
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
	this->status.mode = static_cast<AdvancedAirConditioningDevice::Mode>(ModeOff);
	this->status.swing = static_cast<AdvancedAirConditioningDevice::Swing>(SwingOff);
	this->status.temp = 0;
	this->status.vel = static_cast<AdvancedAirConditioningDevice::Velocity>(SpeedAuto);
}

SplitAdvancedScenario::Mode SplitAdvancedScenario::getMode() const
{
	return static_cast<Mode>(status.mode);
}

void SplitAdvancedScenario::setMode(Mode mode)
{
	// TODO save value somewhere
	status.mode = static_cast<AdvancedAirConditioningDevice::Mode>(mode);
	emit modeChanged();
}

SplitAdvancedScenario::Swing SplitAdvancedScenario::getSwing() const
{
	return static_cast<Swing>(status.swing);
}

void SplitAdvancedScenario::setSwing(Swing swing)
{
	// TODO save value somewhere
	status.swing = static_cast<AdvancedAirConditioningDevice::Swing>(swing);
	emit swingChanged();
}

int SplitAdvancedScenario::getSetPoint() const
{
	return status.temp;
}

void SplitAdvancedScenario::setSetPoint(int setPoint)
{
	// TODO save value somewhere
	status.temp = setPoint;
	emit setPointChanged();
}

SplitAdvancedScenario::Speed SplitAdvancedScenario::getSpeed() const
{
	return static_cast<Speed>(status.vel);
}

void SplitAdvancedScenario::setSpeed(Speed speed)
{
	// TODO save value somewhere
	status.vel = static_cast<AdvancedAirConditioningDevice::Velocity>(speed);
	emit speedChanged();
}

void SplitAdvancedScenario::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		++it;
	}
}

void SplitAdvancedScenario::sendScenarioCommand()
{
	dev->activateScenario(command);
}

bool SplitAdvancedScenario::isEnabled() const
{
	return enabled;
}

void SplitAdvancedScenario::setEnabled(bool enable)
{
	// TODO save value somewhere
	enabled = enable;
	emit enabledChanged();
}
