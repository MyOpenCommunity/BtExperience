#include "thermalobjects.h"
#include "thermal_device.h"
#include "scaleconversion.h" // bt2Celsius
#include "objectlistmodel.h"

#include <QDebug>


ThermalControlUnit::ThermalControlUnit(QString _name, QString _key, ThermalDevice *d)
{
    name = _name;
    key = _key;
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
    mode = SummerMode;
    programs << qMakePair(1, QString("P1")) << qMakePair(3, QString("P3")) << qMakePair(5, QString("P5"));

    objs << new ThermalControlUnitWeeklyPrograms("Settimanale", this, dev);
    objs << new ThermalControlUnitTimedProgram("Festivi", ThermalControlUnit::IdHoliday, this, dev);
    objs << new ThermalControlUnitTimedProgram("Vacanze", ThermalControlUnit::IdVacation, this, dev);
    objs << new ThermalControlUnitAntifreeze("Antigelo", dev);
    objs << new ThermalControlUnitManual("Manuale", dev);
    objs << new ThermalControlUnitOff("Off", dev);
}

QString ThermalControlUnit::getObjectKey() const
{
    return key;
}

QString ThermalControlUnit::getName() const
{
    return name;
}

ThermalControlUnit::ModeType ThermalControlUnit::getMode() const
{
    return mode;
}

void ThermalControlUnit::setMode(ModeType m)
{
    if (m == SummerMode)
        dev->setSummer();
    else
        dev->setWinter();
}

ThermalRegulationProgramList ThermalControlUnit::getPrograms() const
{
    return programs;
}

ObjectListModel *ThermalControlUnit::getModalities() const
{
    ObjectListModel *items = new ObjectListModel;
    for (int i = 0; i < objs.length(); ++i)
        items->appendRow(objs[i]);

    items->reparentObjects();

    return items;
}

void ThermalControlUnit::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
        if (it.key() == ThermalDevice::DIM_SEASON) {
//            qDebug() << "Ricevuto season: " << it.value().toInt();
            ThermalDevice::Season season = static_cast<ThermalDevice::Season>(it.value().toInt());
            if (season == ThermalDevice::SE_SUMMER && mode != SummerMode) {
                mode = SummerMode;
                emit modeChanged();
            }
            else if (season == ThermalDevice::SE_WINTER && mode != WinterMode) {
                mode = WinterMode;
                emit modeChanged();
            }
        }
        ++it;
    }
}


ThermalControlUnit4Zones::ThermalControlUnit4Zones(QString _name, QString _key, ThermalDevice4Zones *d) :
    ThermalControlUnit(_name, _key, d)
{
    dev = d;
}


ThermalControlUnit99Zones::ThermalControlUnit99Zones(QString _name, QString _key, ThermalDevice99Zones *d) :
    ThermalControlUnit(_name, _key, d)
{
    dev = d;
    scenarios << qMakePair(1, QString("S1")) << qMakePair(3, QString("S3")) << qMakePair(5, QString("S5"));
    objs << new ThermalControlUnitScenarios("Scenari", this, dev);
}

ThermalRegulationProgramList ThermalControlUnit99Zones::getScenarios() const
{
    return scenarios;
}

ThermalControlUnitState::ThermalControlUnitState(QString _name, ThermalDevice *_dev)
{
    dev = _dev;
    name = _name;
}

QString ThermalControlUnitState::getObjectKey() const
{
    return QString();
}

QString ThermalControlUnitState::getName() const
{
    return name;
}


ThermalControlUnitTimedProgram::ThermalControlUnitTimedProgram(QString name, int _object_id, const ThermalControlUnit *unit, ThermalDevice *dev) :
    ThermalControlUnitState(name, dev)
{
    object_id = _object_id;
    programs = unit->getPrograms();
    current.programIndex = 0;
    current.date = QDate::currentDate();
    current.time = QTime::currentTime();
    to_apply = current;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitTimedProgram::getProgramCount() const
{
    return programs.count();
}

int ThermalControlUnitTimedProgram::getProgramIndex() const
{
    return to_apply.programIndex;
}

void ThermalControlUnitTimedProgram::setProgramIndex(int index)
{
    if (to_apply.programIndex == index || index < 0 || index >= programs.count())
        return;

    to_apply.programIndex = index;
    emit programChanged();
}

int ThermalControlUnitTimedProgram::getProgramId() const
{
    return programs[to_apply.programIndex].first;
}

QString ThermalControlUnitTimedProgram::getProgramDescription() const
{
    return programs[to_apply.programIndex].second;
}

QDate ThermalControlUnitTimedProgram::getDate() const
{
    return to_apply.date;
}

void ThermalControlUnitTimedProgram::setDate(QDate _date)
{
    if (to_apply.date == _date)
        return;

    to_apply.date = _date;
    emit dateChanged();
}

QTime ThermalControlUnitTimedProgram::getTime() const
{
    return to_apply.time;
}

void ThermalControlUnitTimedProgram::setTime(QTime _time)
{
    if (to_apply.time == _time)
        return;

    to_apply.time = _time;
    emit timeChanged();
}

void ThermalControlUnitTimedProgram::apply()
{
    if (to_apply == current)
        return;

    current = to_apply;

    if (object_id == ThermalControlUnit::IdHoliday)
        dev->setWeekendDateTime(to_apply.date, to_apply.time, programs[to_apply.programIndex].first);
    else
        dev->setHolidayDateTime(to_apply.date, to_apply.time, programs[to_apply.programIndex].first);
}

void ThermalControlUnitTimedProgram::reset()
{
    to_apply = current;
}

void ThermalControlUnitTimedProgram::valueReceived(const DeviceValues &values_list)
{
    if (values_list.contains(ThermalDevice99Zones::DIM_PROGRAM)) {
        int val = values_list[ThermalDevice99Zones::DIM_PROGRAM].toInt();
        for (int i = 0; i < programs.length(); ++i) {
            if (programs[i].first == val) {
                qDebug() << "ThermalControlUnitTimedProgram program changed:" << val;
                current.programIndex = i;
                emit programChanged();
                break;
            }
            else
                qWarning() << "ThermalControlUnitTimedProgram unknown program:" << val;
        }
    }
}

ThermalControlUnitOff::ThermalControlUnitOff(QString name, ThermalDevice *dev) :
    ThermalControlUnitState(name, dev)
{
}

void ThermalControlUnitOff::apply()
{
    dev->setOff();
}


ThermalControlUnitManual::ThermalControlUnitManual(QString name, ThermalDevice *dev) :
    ThermalControlUnitState(name, dev)
{
    current.temperature = 0;
    to_apply = current;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitManual::getTemperature() const
{
    return bt2Celsius(to_apply.temperature);
}

void ThermalControlUnitManual::setTemperature(int temp)
{
    if (celsius2Bt(temp) != to_apply.temperature) {
        to_apply.temperature = celsius2Bt(temp);
        emit temperatureChanged();
    }
}

void ThermalControlUnitManual::apply()
{
    if (to_apply == current)
        return;

    current = to_apply;
    dev->setManualTemp(to_apply.temperature);
}

void ThermalControlUnitManual::reset()
{
    to_apply = current;
}

void ThermalControlUnitManual::valueReceived(const DeviceValues &values_list)
{
    if (values_list.contains(ThermalDevice::DIM_TEMPERATURE)) {
        int val = values_list[ThermalDevice::DIM_TEMPERATURE].toInt();
        if (val != current.temperature) {
            qDebug() << "ThermalControlUnitManual temperature received:" << val;
            current.temperature = val;
            emit temperatureChanged();
        }
    }
}


ThermalControlUnitAntifreeze::ThermalControlUnitAntifreeze(QString name, ThermalDevice *dev) :
    ThermalControlUnitState(name, dev)
{
}

void ThermalControlUnitAntifreeze::apply()
{
    dev->setProtection();
}


ThermalControlUnitWeeklyProgram::ThermalControlUnitWeeklyProgram(QString name, int _program, ThermalDevice *dev) :
    ThermalControlUnitState(name, dev)
{
    program = _program;
}

void ThermalControlUnitWeeklyProgram::apply()
{
    dev->setWeekProgram(program);
}


ThermalControlUnitWeeklyPrograms::ThermalControlUnitWeeklyPrograms(QString name, const ThermalControlUnit *unit, ThermalDevice *dev) :
    ThermalControlUnitState(name, dev)
{
    programs = unit->getPrograms();
}

ObjectListModel *ThermalControlUnitWeeklyPrograms::getPrograms() const
{
    ObjectListModel *items = new ObjectListModel;

    foreach (const ThermalRegulationProgram &p, programs)
        items->appendRow(new ThermalControlUnitWeeklyProgram(p.second, p.first, dev));

    items->reparentObjects();

    return items;
}


ThermalControlUnitScenario::ThermalControlUnitScenario(QString name, int _scenario, ThermalDevice99Zones *_dev) :
    ThermalControlUnitState(name, _dev)
{
    scenario = _scenario;
    dev = _dev;
}

void ThermalControlUnitScenario::apply()
{
    dev->setScenario(scenario);
}


ThermalControlUnitScenarios::ThermalControlUnitScenarios(QString name, const ThermalControlUnit99Zones *unit, ThermalDevice99Zones *_dev) :
    ThermalControlUnitState(name, _dev)
{
    scenarios = unit->getScenarios();
    dev = _dev;
}

ObjectListModel *ThermalControlUnitScenarios::getScenarios() const
{
    ObjectListModel *items = new ObjectListModel;

    foreach (const ThermalRegulationProgram &p, scenarios)
        items->appendRow(new ThermalControlUnitScenario(p.second, p.first, dev));

    items->reparentObjects();

    return items;
}


