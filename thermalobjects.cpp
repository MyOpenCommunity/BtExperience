#include "thermalobjects.h"
#include "thermal_device.h"
#include "probe_device.h"
#include "scaleconversion.h" // bt2Celsius

#include <QDebug>


ThermalControlUnit::ThermalControlUnit(QString _name, QString _key, ThermalDevice *d)
{
    name = _name;
    key = _key;
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
    temperature = 0;
    mode = SummerMode;
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
    return bt2Celsius(temperature);
}

void ThermalControlUnit::setTemperature(int temp)
{
    dev->setManualTemp(celsius2Bt(temp));
}

ThermalControlUnit::ModeType ThermalControlUnit::getMode() const
{
    return mode;
}

void ThermalControlUnit::setMode(ModeType m)
{
    if (m == SummerMode)
        dev->setSummer();
    else
        dev->setWinter();
}

void ThermalControlUnit::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
        if (it.key() == ThermalDevice::DIM_TEMPERATURE) {
            if (it.value().toInt() != temperature) {
//                qDebug() << "Ricevuto temperature:" << it.value().toInt();
                temperature = it.value().toInt();

                emit temperatureChanged();
                break;
            }
        }
        else if (it.key() == ThermalDevice::DIM_SEASON) {
//            qDebug() << "Ricevuto season: " << it.value().toInt();
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


ThermalControlUnit4Zones::ThermalControlUnit4Zones(QString _name, QString _key, ThermalDevice4Zones *d) :
    ThermalControlUnit(_name, _key, d)
{
    dev = d;
}


ThermalControlUnit99Zones::ThermalControlUnit99Zones(QString _name, QString _key, ThermalDevice99Zones *d) :
    ThermalControlUnit(_name, _key, d)
{
    dev = d;
}


ThermalControlledProbe::ThermalControlledProbe(QString _name, QString _key, ControlledProbeDevice *d)
{
    name = _name;
    key = _key;
    probe_status = Unknown;
    temperature = 0;
    setpoint = 0;
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

ThermalControlledProbe::ProbeStatus ThermalControlledProbe::getProbeStatus() const
{
    return probe_status;
}

void ThermalControlledProbe::setProbeStatus(ProbeStatus st)
{
    if (st == probe_status)
        return;

    switch (st)
    {
    case Manual:
        dev->setManual(setpoint);
        break;
    case Auto:
        dev->setAutomatic();
        break;
    case Antifreeze:
        dev->setProtection();
        break;
    case Off:
        dev->setOff();
        break;
    default:
        qWarning() << "Unhandled status: " << st;
    }
}

int ThermalControlledProbe::getSetpoint() const
{
    return setpoint;
}

void ThermalControlledProbe::setSetpoint(int sp)
{
    if (sp != setpoint)
        dev->setManual(sp);
}

int ThermalControlledProbe::getTemperature() const
{
    return temperature;
}

void ThermalControlledProbe::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
//        qDebug() << "VALORE RICEVUTO:" << it.key() << ": " << it.value().toInt();
        if (it.key() == ControlledProbeDevice::DIM_STATUS) {
            probe_status = static_cast<ProbeStatus>(it.value().toInt());
            emit probeStatusChanged();
        }
        else if (it.key() == ControlledProbeDevice::DIM_SETPOINT) {
            setpoint = it.value().toInt();
            emit setpointChanged();
        }
        else if (it.key() == ControlledProbeDevice::DIM_TEMPERATURE) {
            temperature = it.value().toInt();
            emit temperatureChanged();
        }

        ++it;
    }
}

