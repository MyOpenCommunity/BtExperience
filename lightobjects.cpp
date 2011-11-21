#include "lightobjects.h"
#include "lighting_device.h"

#include <QDebug>


Light::Light(QString _name, LightingDevice *d)
{
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

    name = _name;
    status = false; // initial value
    connect(this, SIGNAL(statusChanged()), this, SIGNAL(dataChanged()));
}

QString Light::getName() const
{
    return name;
}

bool Light::getStatus() const
{
    return status;
}

void Light::setStatus(bool st)
{
    qDebug() << "Light::setStatus";
    if (st)
        dev->turnOn();
    else
        dev->turnOff();
}

void Light::valueReceived(const DeviceValues &values_list)
{
        DeviceValues::const_iterator it = values_list.constBegin();
        while (it != values_list.constEnd()) {
            if (it.key() == LightingDevice::DIM_DEVICE_ON) {
//                qDebug() << "Ricevuto status:" << it.value().toBool();
                if (it.value().toBool() != status) {
                    status = it.value().toBool() == true;

                    emit statusChanged();
                    break;
                }
            }
            ++it;
        }
}


Dimmer::Dimmer(QString name, DimmerDevice *d) : Light(name, d)
{
    dev = d;
    percentage = 50; // initial value
    connect(this, SIGNAL(percentageChanged()), this, SIGNAL(dataChanged()));
}

int Dimmer::getPercentage() const
{
    return percentage;
}

void Dimmer::setPercentage(int val)
{
    qDebug() << "Dimmer::setPercentage";
    if (percentage < val)
        dev->increaseLevel();
    else
        dev->decreaseLevel();
}

void Dimmer::valueReceived(const DeviceValues &values_list)
{
    Light::valueReceived(values_list);
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
        if (it.key() == LightingDevice::DIM_DIMMER_LEVEL) {
//            qDebug() << "Ricevuta percentuale" << it.value().toInt();
            if (status != true) {
                status = true;
                emit statusChanged();
            }
            if (percentage != it.value().toInt() * 10) {
                percentage = it.value().toInt() * 10;
                emit percentageChanged();
            }
        }
        ++it;
    }
}
