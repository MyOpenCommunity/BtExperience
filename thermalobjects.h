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
class ThermalControlUnit99Zones;

typedef QPair<int, QString> ThermalRegulationProgram;
typedef QList<ThermalRegulationProgram> ThermalRegulationProgramList;


class ThermalControlUnitState : public ObjectInterface
{
    Q_OBJECT

public:
    ThermalControlUnitState(QString name, ThermalDevice *dev);

    virtual QString getObjectKey() const;

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::ThermalRegulationUnitState;
    }

    virtual QString getName() const;

    virtual bool getStatus() const { return false; }
    virtual void setStatus(bool st) { Q_UNUSED(st); }

protected:
    ThermalDevice *dev;
    QString name;
};


class ThermalControlUnitTimedProgram : public ThermalControlUnitState
{
    Q_OBJECT
    Q_PROPERTY(int programIndex READ getProgramIndex WRITE setProgramIndex NOTIFY programChanged)
    Q_PROPERTY(int programCount READ getProgramCount)
    Q_PROPERTY(int programId READ getProgramId NOTIFY programChanged)
    Q_PROPERTY(QString programDescription READ getProgramDescription NOTIFY programChanged)
    Q_PROPERTY(QDate date READ getDate WRITE setDate NOTIFY dateChanged)
    Q_PROPERTY(QTime time READ getTime WRITE setTime NOTIFY timeChanged)

public:
    ThermalControlUnitTimedProgram(QString name, int object_id, const ThermalControlUnit *unit, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return object_id;
    }

    int getProgramCount() const;

    int getProgramIndex() const;
    void setProgramIndex(int index);

    int getProgramId() const;
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
    ThermalRegulationProgramList programs;
    int object_id;
};


class ThermalControlUnitOff : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitOff(QString name, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitOff;
    }

public slots:
    void apply();
};


class ThermalControlUnitAntifreeze : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitAntifreeze(QString name, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitAntifreeze;
    }

public slots:
    void apply();
};


class ThermalControlUnitWeeklyProgram : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitWeeklyProgram(QString name, int program, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitWeeklyProgram;
    }

public slots:
    void apply();

private:
    int program;
};


class ThermalControlUnitWeeklyPrograms : public ThermalControlUnitState
{
    Q_OBJECT
    Q_PROPERTY(ObjectListModel *programs READ getPrograms NOTIFY programsChanged)

public:
    ThermalControlUnitWeeklyPrograms(QString name, const ThermalControlUnit *unit, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitWeeklyPrograms;
    }

    ObjectListModel *getPrograms() const;

signals:
    void programsChanged();

private:
    ThermalRegulationProgramList programs;
};


class ThermalControlUnitScenario : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitScenario(QString name, int scenario, ThermalDevice99Zones *dev);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitScenario;
    }

public slots:
    void apply();

private:
    ThermalDevice99Zones *dev;
    int scenario;
};


class ThermalControlUnitScenarios : public ThermalControlUnitState
{
    Q_OBJECT
    Q_PROPERTY(ObjectListModel *scenarios READ getScenarios NOTIFY scenariosChanged)

public:
    ThermalControlUnitScenarios(QString name, const ThermalControlUnit99Zones *unit, ThermalDevice99Zones *dev);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdThermalControlUnitScenarios;
    }

    ObjectListModel *getScenarios() const;

signals:
    void scenariosChanged();

private:
    ThermalDevice99Zones *dev;
    ThermalRegulationProgramList scenarios;
};


class ThermalControlUnit : public ObjectInterface
{
    Q_OBJECT
    Q_ENUMS(ModeType)
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(ModeType mode READ getMode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(ObjectListModel *modalities READ getModalities NOTIFY modalitiesChanged)

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

    ThermalRegulationProgramList getPrograms() const;

    virtual ObjectListModel *getModalities() const;

signals:
    void temperatureChanged();
    void modeChanged();
    void modalitiesChanged();

protected slots:
    virtual void valueReceived(const DeviceValues &values_list);

private:
    QString name;
    QString key;
    int temperature;
    ModeType mode;
    ThermalRegulationProgramList programs;
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

    virtual ObjectListModel *getModalities() const;

    ThermalRegulationProgramList getScenarios() const;

private:
    ThermalDevice99Zones *dev;
    ThermalRegulationProgramList scenarios;
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
