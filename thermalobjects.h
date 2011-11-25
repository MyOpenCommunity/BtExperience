#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>

class ThermalDevice99Zones;
class ControlledProbeDevice;


class ThermalControlUnit99Zones : public ObjectInterface
{
    Q_OBJECT
    Q_ENUMS(ModeType)
    Q_PROPERTY(int objectId READ getObjectId CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(QString objectKey READ getObjectKey CONSTANT)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(ModeType mode READ getMode WRITE setMode NOTIFY modeChanged)

public:
    enum ModeType
    {
        SummerMode,
        WinterMode
    };

    ThermalControlUnit99Zones(QString name, QString key, ThermalDevice99Zones *d);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnit99;
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

signals:
    void temperatureChanged();
    void modeChanged();

private slots:
    void valueReceived(const DeviceValues &values_list);

private:
    QString name;
    QString key;
    int temperature;
    ModeType mode;
    ThermalDevice99Zones *dev;
};


class ThermalControlledProbe : public ObjectInterface
{
    Q_OBJECT

public:
    Q_PROPERTY(int objectId READ getObjectId CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(QString objectKey READ getObjectKey CONSTANT)

    ThermalControlledProbe(QString name, QString key, ControlledProbeDevice *d);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlledProbe;
    }

    virtual QString getObjectKey() const;

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::ThermalRegulation;
    }

    virtual QString getName() const;
    virtual bool getStatus() const { return false; }
    virtual void setStatus(bool st) { Q_UNUSED(st); }

private slots:
    void valueReceived(const DeviceValues &values_list);

private:
    QString name;
    QString key;
    ControlledProbeDevice *dev;
};


#endif // THERMALOBJECTS_H
