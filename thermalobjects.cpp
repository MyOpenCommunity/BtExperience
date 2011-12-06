#include "thermalobjects.h"
#include "thermal_device.h"
#include "probe_device.h"
#include "scaleconversion.h" // bt2Celsius
#include "objectlistmodel.h"

#include <QDebug>


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
    programIndex = 0;
    date = QDate::currentDate();
    time = QTime::currentTime();
}

int ThermalControlUnitTimedProgram::getProgramCount() const
{
    return programs.count();
}

int ThermalControlUnitTimedProgram::getProgramIndex() const
{
    return programIndex;
}

void ThermalControlUnitTimedProgram::setProgramIndex(int index)
{
    if (programIndex == index || index < 0 || index >= programs.count())
        return;

    programIndex = index;
    emit programChanged();
}

int ThermalControlUnitTimedProgram::getProgram() const
{
    return programs[programIndex].first;
}

QString ThermalControlUnitTimedProgram::getProgramDescription() const
{
    return programs[programIndex].second;
}

QDate ThermalControlUnitTimedProgram::getDate() const
{
    return date;
}

void ThermalControlUnitTimedProgram::setDate(QDate _date)
{
    if (date == _date)
        return;

    date = _date;
    emit dateChanged();
}

QTime ThermalControlUnitTimedProgram::getTime() const
{
    return time;
}

void ThermalControlUnitTimedProgram::setTime(QTime _time)
{
    if (time == _time)
        return;

    time = _time;
    emit timeChanged();
}

void ThermalControlUnitTimedProgram::apply()
{
    if (object_id == ObjectInterface::IdThermalControlUnitHoliday)
        dev->setWeekendDateTime(date, time, programs[programIndex].first);
    else
        dev->setHolidayDateTime(date, time, programs[programIndex].first);
}


ThermalControlUnitOff::ThermalControlUnitOff(QString name, ThermalDevice *dev) :
    ThermalControlUnitState(name, dev)
{
}

void ThermalControlUnitOff::apply()
{
    dev->setOff();
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

ObjectListModel *ThermalControlUnitWeeklyPrograms::getMenuItems() const
{
    ObjectListModel *items = new ObjectListModel;

    foreach (const ThermalRegulationProgram &p, programs)
        items->appendRow(new ThermalControlUnitWeeklyProgram(p.second, p.first, dev));

    return items;
}


ThermalControlUnit::ThermalControlUnit(QString _name, QString _key, ThermalDevice *d)
{
    name = _name;
    key = _key;
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
    temperature = 0;
    mode = SummerMode;
    programs << qMakePair(1, QString("P1")) << qMakePair(3, QString("P3")) << qMakePair(5, QString("P5"));
}

QString ThermalControlUnit::getObjectKey() const
{
    return key;
}

QString ThermalControlUnit::getName() const
{
    return name;
}

int ThermalControlUnit::getTemperature() const
{
    return bt2Celsius(temperature);
}

void ThermalControlUnit::setTemperature(int temp)
{
    dev->setManualTemp(celsius2Bt(temp));
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

ObjectListModel *ThermalControlUnit::getMenuItems() const
{
    ObjectListModel *items = new ObjectListModel;

    items->appendRow(new ThermalControlUnitOff("Off", dev));
    items->appendRow(new ThermalControlUnitAntifreeze("Antigelo", dev));
    items->appendRow(new ThermalControlUnitTimedProgram("Festivi", ObjectInterface::IdThermalControlUnitHoliday, this, dev));
    items->appendRow(new ThermalControlUnitTimedProgram("Vacanze", ObjectInterface::IdThermalControlUnitVacation, this, dev));
    items->appendRow(new ThermalControlUnitWeeklyPrograms("Settimanale", this, dev));
    // TODO:
    // scenari => ThermalCentralUnitScenari.qml
    // manuale
    // manuale temporizzato

    return items;
}

void ThermalControlUnit::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
        if (it.key() == ThermalDevice::DIM_TEMPERATURE) {
            if (it.value().toInt() != temperature) {
//                qDebug() << "Ricevuto temperature:" << it.value().toInt();
                temperature = it.value().toInt();

                emit temperatureChanged();
                break;
            }
        }
        else if (it.key() == ThermalDevice::DIM_SEASON) {
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
}


ThermalControlledProbe::ThermalControlledProbe(QString _name, QString _key, ControlledProbeDevice *d)
{
    name = _name;
    key = _key;
    probe_status = Unknown;
    temperature = 0;
    setpoint = 0;
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

QString ThermalControlledProbe::getObjectKey() const
{
    return key;
}

QString ThermalControlledProbe::getName() const
{
    return name;
}

ThermalControlledProbe::ProbeStatus ThermalControlledProbe::getProbeStatus() const
{
    return probe_status;
}

void ThermalControlledProbe::setProbeStatus(ProbeStatus st)
{
    if (st == probe_status)
        return;

    switch (st)
    {
    case Manual:
        dev->setManual(setpoint);
        break;
    case Auto:
        dev->setAutomatic();
        break;
    case Antifreeze:
        dev->setProtection();
        break;
    case Off:
        dev->setOff();
        break;
    default:
        qWarning() << "Unhandled status: " << st;
    }
}

int ThermalControlledProbe::getSetpoint() const
{
    return setpoint;
}

void ThermalControlledProbe::setSetpoint(int sp)
{
    if (sp != setpoint)
        dev->setManual(sp);
}

int ThermalControlledProbe::getTemperature() const
{
    return temperature;
}

void ThermalControlledProbe::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd()) {
//        qDebug() << "VALORE RICEVUTO:" << it.key() << ": " << it.value().toInt();
        if (it.key() == ControlledProbeDevice::DIM_STATUS) {
            probe_status = static_cast<ProbeStatus>(it.value().toInt());
            emit probeStatusChanged();
        }
        else if (it.key() == ControlledProbeDevice::DIM_SETPOINT) {
            setpoint = it.value().toInt();
            emit setpointChanged();
        }
        else if (it.key() == ControlledProbeDevice::DIM_TEMPERATURE) {
            temperature = it.value().toInt();
            emit temperatureChanged();
        }

        ++it;
    }
}

