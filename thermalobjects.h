#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QDateTime>

class ThermalDevice;
class ThermalDevice4Zones;
class ThermalDevice99Zones;
class ObjectListModel;
class ThermalControlUnitState;

typedef QPair<int, QString> ThermalRegulationProgram;
typedef QList<ThermalRegulationProgram> ThermalRegulationProgramList;


class ThermalControlUnit : public ObjectInterface
{
    Q_OBJECT
    Q_ENUMS(ModeType)
    Q_ENUMS(ThermalControlUnitId)
    Q_PROPERTY(ModeType mode READ getMode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(ObjectListModel *modalities READ getModalities NOTIFY modalitiesChanged)

public:
    enum ThermalControlUnitId
    {
        IdHoliday,
        IdOff,
        IdAntifreeze,
        IdManual,
        IdWeeklyPrograms,
        IdVacation,
        IdScenarios
    };

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

    ModeType getMode() const;
    void setMode(ModeType m);

    ThermalRegulationProgramList getPrograms() const;

    ObjectListModel *getModalities() const;

signals:
    void modeChanged();
    void modalitiesChanged();

protected slots:
    virtual void valueReceived(const DeviceValues &values_list);

protected:
    QList<ThermalControlUnitState*> objs;

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

    ThermalRegulationProgramList getScenarios() const;

private:
    ThermalDevice99Zones *dev;
    ThermalRegulationProgramList scenarios;
};



class ThermalControlUnitState : public ObjectInterface
{
    Q_OBJECT

public:
    ThermalControlUnitState(QString name, ThermalDevice *dev);

    virtual QString getObjectKey() const;

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::ThermalRegulation;
    }

    virtual QString getName() const;

public slots:
//    virtual void apply() = 0;


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
    virtual void apply();
    void reset();

signals:
    void programChanged();
    void dateChanged();
    void timeChanged();

protected slots:
    void valueReceived(const DeviceValues &values_list);

private:
    ThermalRegulationProgramList programs;
    int object_id;

    struct Data
    {
        int programIndex;
        QDate date;
        QTime time;
        bool operator==(const Data &other) { return programIndex == other.programIndex && date == other.date && time == other.time; }
    };

    Data current, to_apply;
};


class ThermalControlUnitOff : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitOff(QString name, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return ThermalControlUnit::IdOff;
    }

public slots:
    virtual void apply();
};


class ThermalControlUnitAntifreeze : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitAntifreeze(QString name, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return ThermalControlUnit::IdAntifreeze;
    }

public slots:
    virtual void apply();
};


class ThermalControlUnitManual : public ThermalControlUnitState
{
    Q_OBJECT
    Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)

public:
    ThermalControlUnitManual(QString name, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return ThermalControlUnit::IdManual;
    }

    int getTemperature() const;
    void setTemperature(int temp);


public slots:
    virtual void apply();
    void reset();

signals:
    void temperatureChanged();

protected slots:
    void valueReceived(const DeviceValues &values_list);

private:
    struct Data
    {
        int temperature;
        bool operator==(const Data &other) { return temperature == other.temperature; }
    };

    Data current, to_apply;
};


class ThermalControlUnitWeeklyProgram : public ThermalControlUnitState
{
    Q_OBJECT

public:
    ThermalControlUnitWeeklyProgram(QString name, int program, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return -1;
    }

public slots:
    virtual void apply();

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
        return ThermalControlUnit::IdWeeklyPrograms;
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
        return -1;
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
        return ThermalControlUnit::IdScenarios;
    }

    ObjectListModel *getScenarios() const;

signals:
    void scenariosChanged();

private:
    ThermalDevice99Zones *dev;
    ThermalRegulationProgramList scenarios;
};


#endif // THERMALOBJECTS_H
