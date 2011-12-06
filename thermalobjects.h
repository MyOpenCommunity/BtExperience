#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QDateTime>

class ThermalDevice;
class ThermalDevice4Zones;
class ThermalDevice99Zones;
class ControlledProbeDevice;
class ObjectListModel;
class ThermalControlUnit;

typedef QList<QPair<int, QString> > ProgramList;


class ThermalControlUnitState : public ObjectInterface
{
    Q_OBJECT

public:
    ThermalControlUnitState(ThermalDevice *dev);

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::ThermalRegulationUnitState;
    }

    virtual bool getStatus() const { return false; }
    virtual void setStatus(bool st) { Q_UNUSED(st); }

protected:
    ThermalDevice *dev;
};


class ThermalControlUnitHoliday : public ThermalControlUnitState
{
    Q_OBJECT
    Q_PROPERTY(int programIndex READ getProgramIndex WRITE setProgramIndex NOTIFY programChanged)
    Q_PROPERTY(int programCount READ getProgramCount)
    Q_PROPERTY(int program READ getProgram NOTIFY programChanged)
    Q_PROPERTY(QString programDescription READ getProgramDescription NOTIFY programChanged)
    Q_PROPERTY(QDate date READ getDate WRITE setDate NOTIFY dateChanged)
    Q_PROPERTY(QTime time READ getTime WRITE setTime NOTIFY timeChanged)

public:
    ThermalControlUnitHoliday(QString name, const ThermalControlUnit *unit, ThermalDevice *dev);

    virtual QString getObjectKey() const;

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitHoliday;
    }

    virtual QString getName() const;

    int getProgramCount() const;

    int getProgramIndex() const;
    void setProgramIndex(int index);

    int getProgram() const;
    QString getProgramDescription() const;

    QDate getDate() const;
    void setDate(QDate date);

    QTime getTime() const;
    void setTime(QTime time);

public slots:
    void apply();

signals:
    void programChanged();
    void dateChanged();
    void timeChanged();

private:
    int programIndex;
    QDate date;
    QTime time;
    QString name;
    ProgramList programs;
};


class ThermalControlUnitOff : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitOff(QString name, const ThermalControlUnit *unit, ThermalDevice *dev);

    virtual QString getObjectKey() const;

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitOff;
    }

    virtual QString getName() const;

public slots:
    void apply();

private:
    QString name;
};


class ThermalControlUnitAntifreeze : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitAntifreeze(QString name, const ThermalControlUnit *unit, ThermalDevice *dev);

    virtual QString getObjectKey() const;

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitAntifreeze;
    }

    virtual QString getName() const;

public slots:
    void apply();

private:
    QString name;
};


class ThermalControlUnit : public ObjectInterface
{
    Q_OBJECT
    Q_ENUMS(ModeType)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(ModeType mode READ getMode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(ObjectListModel *menuItemList READ getMenuItems NOTIFY menuItemListChanged)

public:
    enum ModeType
    {
        SummerMode,
        WinterMode
    };

    ThermalControlUnit(QString name, QString key, ThermalDevice *d);

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

    ProgramList getPrograms() const;

    ObjectListModel *getMenuItems() const;

signals:
    void temperatureChanged();
    void modeChanged();
    void menuItemListChanged();

protected slots:
    virtual void valueReceived(const DeviceValues &values_list);

private:
    QString name;
    QString key;
    int temperature;
    ModeType mode;
    ProgramList programs;
    ThermalDevice *dev;
};


class ThermalControlUnit4Zones : public ThermalControlUnit
{
    Q_OBJECT

public:
    ThermalControlUnit4Zones(QString name, QString key, ThermalDevice4Zones *d);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnit4;
    }

private:
    ThermalDevice4Zones *dev;
};


class ThermalControlUnit99Zones : public ThermalControlUnit
{
    Q_OBJECT

public:
    ThermalControlUnit99Zones(QString name, QString key, ThermalDevice99Zones *d);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnit99;
    }

private:
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
