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
    Q_PROPERTY(ProbeStatus probeStatus READ getProbeStatus WRITE setProbeStatus NOTIFY probeStatusChanged)
    Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(int setpoint READ getSetpoint WRITE setSetpoint NOTIFY setpointChanged)
    Q_ENUMS(ProbeStatus)

public:
    enum ProbeStatus
    {
        Unknown,
        Manual,
        Auto,
        Antifreeze,
        Off
    };

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

    ProbeStatus getProbeStatus() const;
    void setProbeStatus(ProbeStatus st);

    int getTemperature() const;

    int getSetpoint() const;
    void setSetpoint(int sp);

signals:
    void probeStatusChanged();
    void temperatureChanged();
    void setpointChanged();


private slots:
    void valueReceived(const DeviceValues &values_list);

private:
    QString name;
    QString key;
    ProbeStatus probe_status;
    int setpoint;
    int temperature;
    ControlledProbeDevice *dev;
};


#endif // THERMALOBJECTS_H
