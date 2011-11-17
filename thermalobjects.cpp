#include "thermalobjects.h"


ThermalControlUnit::ThermalControlUnit(QString _name, int _temperature, int _mode)
{
    name = _name;
    temperature = _temperature;
    mode = _mode;
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

int ThermalControlUnit::getMode() const
{
    return mode;
}

void ThermalControlUnit::setMode(int m)
{
    mode = m;
}
