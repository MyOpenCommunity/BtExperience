#include "lightobjects.h"

#include <QDebug>


Light::Light(QString _name, bool _status)
{
    name = _name;
    status = _status;
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
    if (st != status)
    {
        status = st;
        emit statusChanged();
    }
}


Dimmer::Dimmer(QString name, bool status, int _percentage)
    : Light(name, status)
{
    percentage = _percentage;
    connect(this, SIGNAL(percentageChanged()), this, SIGNAL(dataChanged()));
}

int Dimmer::getPercentage() const
{
    return percentage;
}

void Dimmer::setPercentage(int val)
{
    qDebug() << "Dimmer::setPercentage";
    if (val != percentage)
    {
        percentage = val;
        emit percentageChanged();
    }
}
