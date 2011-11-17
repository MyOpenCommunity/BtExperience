#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

#include "objectinterface.h"

#include <QObject>


class ThermalControlUnit : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(int objectId READ getObjectId CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature)
    Q_PROPERTY(int mode READ getMode WRITE setMode)

public:
    ThermalControlUnit(QString name, int temperature, int mode);

    virtual int getObjectId() const
    {
        return ObjectInterface::ThermalControlUnit;
    }

    virtual int getCategory() const
    {
        return THERMAL_REGULATION;
    }

    virtual QString getName() const;
    virtual bool getStatus() const { return false; }
    virtual void setStatus(bool st) { Q_UNUSED(st); }

    int getTemperature() const;
    void setTemperature(int temp);

    int getMode() const;
    void setMode(int m);


//    Q_INVOKABLE QObject* programs(); // boh

private:
    QString name;
    int temperature;
    int mode; // enum?
};

/*
class ThermalControlledProbe : public ObjectInterface
{
    Q_OBJECT
public:
    Q_PROPERTY(int objectId READ getObjectId CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)

    virtual int getObjectId() const
    {
        return ObjectInterface::ThermalControlledProbe;
    }
    virtual QString getName() const;
    virtual bool getStatus() const { return false; }
    virtual void setStatus(bool st) { }
};
*/

#endif // THERMALOBJECTS_H
