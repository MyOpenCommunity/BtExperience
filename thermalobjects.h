#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QDateTime>
#include <QList>
#include <QPair>
#include <QHash>
#include <QString>
#include <QVariant>


class ThermalDevice;
class ThermalDevice4Zones;
class ThermalDevice99Zones;
class ObjectListModel;
class ThermalControlUnitObject;

typedef QPair<int, QString> ThermalRegulationProgram;
typedef QList<ThermalRegulationProgram> ThermalRegulationProgramList;
typedef QHash<int, QVariant> ThermalRegulationState;


class ThermalControlUnit : public ObjectInterface
{
    Q_OBJECT
    Q_ENUMS(ModeType)
    Q_ENUMS(ThermalControlUnitId)
    Q_PROPERTY(ModeType mode READ getMode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(ObjectListModel *modalities READ getModalities NOTIFY modalitiesChanged)
    Q_PROPERTY(QObject *currentModality READ getCurrentModality NOTIFY currentModalityChanged)

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

    QObject* getCurrentModality() const;

signals:
    void modeChanged();
    void modalitiesChanged();
    void currentModalityChanged();

protected slots:
    virtual void valueReceived(const DeviceValues &values_list);

protected:
    QList<ThermalControlUnitObject*> objs;

private:
    QString name;
    QString key;
    int temperature;
    ModeType mode;
    ThermalRegulationProgramList programs;
    ThermalDevice *dev;
    int current_modality;
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


class ThermalControlUnitObject : public ObjectInterface
{
    Q_OBJECT

public:
    ThermalControlUnitObject(QString name, ThermalDevice *dev);

    virtual QString getObjectKey() const;

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::ThermalRegulation;
    }

    virtual QString getName() const;

public slots:
    virtual void apply() = 0;
    virtual void reset();

protected:
    ThermalRegulationState current, to_apply;

protected:
    ThermalDevice *dev;
    QString name;
};


class ThermalControlUnitProgram : public ThermalControlUnitObject
{
    Q_OBJECT
    Q_PROPERTY(int programIndex READ getProgramIndex WRITE setProgramIndex NOTIFY programChanged)
    Q_PROPERTY(int programCount READ getProgramCount)
    Q_PROPERTY(int programId READ getProgramId NOTIFY programChanged)
    Q_PROPERTY(QString programDescription READ getProgramDescription NOTIFY programChanged)

public:
    ThermalControlUnitProgram(QString name, int object_id, const ThermalControlUnit *unit, ThermalDevice *dev);

    virtual int getObjectId() const
    {
        return object_id;
    }

    int getProgramCount() const;

    int getProgramIndex() const;
    void setProgramIndex(int index);

    int getProgramId() const;
    QString getProgramDescription() const;

public slots:
    virtual void apply();

signals:
    void programChanged();

protected slots:
    void valueReceived(const DeviceValues &values_list);

private:
    ThermalRegulationProgramList programs;
    int object_id;
};


class ThermalControlUnitTimedProgram : public ThermalControlUnitProgram
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ getDate WRITE setDate NOTIFY dateChanged)
    Q_PROPERTY(QTime time READ getTime WRITE setTime NOTIFY timeChanged)

public:
    ThermalControlUnitTimedProgram(QString name, int object_id, const ThermalControlUnit *unit, ThermalDevice *dev);

    QDate getDate() const;
    void setDate(QDate date);

    QTime getTime() const;
    void setTime(QTime time);

public slots:
    virtual void apply();

signals:
    void dateChanged();
    void timeChanged();
};


class ThermalControlUnitOff : public ThermalControlUnitObject
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


class ThermalControlUnitAntifreeze : public ThermalControlUnitObject
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


class ThermalControlUnitManual : public ThermalControlUnitObject
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

signals:
    void temperatureChanged();

protected slots:
    void valueReceived(const DeviceValues &values_list);
};


class ThermalControlUnitScenario : public ThermalControlUnitObject
{
    Q_OBJECT
    Q_PROPERTY(int scenarioIndex READ getScenarioIndex WRITE setScenarioIndex NOTIFY scenarioChanged)
    Q_PROPERTY(int scenarioCount READ getScenarioCount)
    Q_PROPERTY(int scenarioId READ getScenarioId NOTIFY scenarioChanged)
    Q_PROPERTY(QString scenarioDescription READ getScenarioDescription NOTIFY scenarioChanged)

public:
    ThermalControlUnitScenario(QString name, const ThermalControlUnit99Zones *unit, ThermalDevice99Zones *dev);

    virtual int getObjectId() const
    {
        return ThermalControlUnit::IdScenarios;
    }

    int getScenarioCount() const;

    int getScenarioIndex() const;
    void setScenarioIndex(int index);

    int getScenarioId() const;
    QString getScenarioDescription() const;

public slots:
    virtual void apply();

signals:
    void scenarioChanged();

protected slots:
    void valueReceived(const DeviceValues &values_list);

private:
    ThermalDevice99Zones *dev;
    ThermalRegulationProgramList scenarios;
};


#endif // THERMALOBJECTS_H
