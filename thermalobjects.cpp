#include "thermalobjects.h"


ThermalControlUnit::ThermalControlUnit(QString _name, int _temperature, ModeType _mode)
{
    name = _name;
    key = "TODO";
    temperature = _temperature;
    mode = _mode;
}

QString ThermalControlUnit::getObjectKey() const
{
    return key;
}

QString ThermalControlUnit::getName() const
{
    return name;
}

int ThermalControlUnit::getTemperature() const
{
    return temperature;
}

void ThermalControlUnit::setTemperature(int temp)
{
    temperature = temp;
}

ThermalControlUnit::ModeType ThermalControlUnit::getMode() const
{
    return mode;
}

void ThermalControlUnit::setMode(ModeType m)
{
    mode = m;
}
