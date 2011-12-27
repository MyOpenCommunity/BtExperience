#include "thermalprobes.h"
#include "scaleconversion.h" // bt2Celsius
#include "probe_device.h"

#include <QDebug>


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
    return bt2Celsius(setpoint);
}

void ThermalControlledProbe::setSetpoint(int sp)
{
    if (celsius2Bt(sp) != setpoint)
        dev->setManual(celsius2Bt(sp));
}

int ThermalControlledProbe::getTemperature() const
{
    return bt2Celsius(temperature);
}

void ThermalControlledProbe::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
//        qDebug() << "VALORE RICEVUTO:" << it.key() << ": " << it.value().toInt();
        if (it.key() == ControlledProbeDevice::DIM_STATUS) {
//            qDebug() << "PROBE STATUS CHANGED: " << it.value().toInt();
            if (it.value().toInt() != probe_status) {
                probe_status = static_cast<ProbeStatus>(it.value().toInt());
                emit probeStatusChanged();
            }
        }
        else if (it.key() == ControlledProbeDevice::DIM_SETPOINT) {
            if (setpoint != it.value().toInt()) {
                setpoint = it.value().toInt();
                emit setpointChanged();
            }
        }
        else if (it.key() == ControlledProbeDevice::DIM_TEMPERATURE) {
            if (temperature != it.value().toInt()) {
                temperature = it.value().toInt();
                emit temperatureChanged();
            }
        }

        ++it;
    }
}


