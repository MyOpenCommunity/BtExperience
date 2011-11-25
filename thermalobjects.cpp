#include "thermalobjects.h"
#include "thermal_device.h"
#include "scaleconversion.h" // bt2Celsius

#include <QDebug>


ThermalControlUnit99Zones::ThermalControlUnit99Zones(QString _name, QString _key, ThermalDevice99Zones *d)
{
    name = _name;
    key = _key;
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
    temperature = 0;
    mode = SummerMode;
}

QString ThermalControlUnit99Zones::getObjectKey() const
{
    return key;
}

QString ThermalControlUnit99Zones::getName() const
{
    return name;
}

int ThermalControlUnit99Zones::getTemperature() const
{
    return bt2Celsius(temperature);
}

void ThermalControlUnit99Zones::setTemperature(int temp)
{
    dev->setManualTemp(celsius2Bt(temp));
}

ThermalControlUnit99Zones::ModeType ThermalControlUnit99Zones::getMode() const
{
    return mode;
}

void ThermalControlUnit99Zones::setMode(ModeType m)
{
    if (m == SummerMode)
        dev->setSummer();
    else
        dev->setWinter();
}

void ThermalControlUnit99Zones::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
        if (it.key() == ThermalDevice::DIM_TEMPERATURE) {
            if (it.value().toInt() != temperature) {
                qDebug() << "Ricevuto temperature:" << it.value().toInt();
                temperature = it.value().toInt();

                emit temperatureChanged();
                break;
            }
        }
        else if (it.key() == ThermalDevice::DIM_SEASON) {
            qDebug() << "Ricevuto season: " << it.value().toInt();
            ThermalDevice::Season season = static_cast<ThermalDevice::Season>(it.value().toInt());
            if (season == ThermalDevice::SE_SUMMER && mode != SummerMode) {
                mode = SummerMode;
                emit modeChanged();
            }
            else if (season == ThermalDevice::SE_WINTER && mode != WinterMode) {
                mode = WinterMode;
                emit modeChanged();
            }
        }
        ++it;
    }
}


ThermalControlledProbe::ThermalControlledProbe(QString _name, QString _key, ControlledProbeDevice *d)
{
    name = _name;
    key = _key;
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

QString ThermalControlledProbe::getObjectKey() const
{
    return key;
}

QString ThermalControlledProbe::getName() const
{
    return name;
}

void ThermalControlledProbe::valueReceived(const DeviceValues &values_list)
{

}
