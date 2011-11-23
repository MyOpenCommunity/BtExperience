#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

#include "objectinterface.h"

#include <QObject>


class ThermalControlUnit : public ObjectInterface
{
    Q_OBJECT
    Q_ENUMS(ModeType)
    Q_PROPERTY(int objectId READ getObjectId CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(QString objectKey READ getObjectKey CONSTANT)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature)
    Q_PROPERTY(ModeType mode READ getMode WRITE setMode)

public:
    enum ModeType
    {
        SummerMode,
        WinterMode
    };

    ThermalControlUnit(QString name, int temperature, ModeType mode);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnit;
    }

    virtual QString getObjectKey() const;

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::ThermalRegulation;
    }

    virtual QString getName() const;
    virtual bool getStatus() const { return false; }
    virtual void setStatus(bool st) { Q_UNUSED(st); }

    int getTemperature() const;
    void setTemperature(int temp);

    ModeType getMode() const;
    void setMode(ModeType m);

private:
    QString name;
    QString key;
    int temperature;
    ModeType mode;

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
        return ObjectInterface::IdThermalControlledProbe;
    }
    virtual QString getName() const;
    virtual bool getStatus() const { return false; }
    virtual void setStatus(bool st) { }
};
*/

#endif // THERMALOBJECTS_H
