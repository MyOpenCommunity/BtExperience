#include "thermalobjects.h"
#include "thermalprobes.h"
#include "thermal_device.h"
#include "probe_device.h"
#include "scaleconversion.h" // bt2Celsius
#include "objectmodel.h"
#include "devices_cache.h"
#include "xmlobject.h"

#include <QDebug>


enum ThermalRegulationStateKeys
{
	PROGRAM_INDEX,
	DATE,
	TIME,
	TEMPERATURE,
	SCENARIO_INDEX
};

QList<ObjectPair> parseZone99(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString where = v.value("where");
		ControlledProbeDevice::ProbeType fancoil = v.intValue<ControlledProbeDevice::ProbeType>("fancoil");
		ControlledProbeDevice *d = bt_global::add_device_to_cache(new ControlledProbeDevice(where, "0", where, ControlledProbeDevice::CENTRAL_99ZONES, fancoil));

		if (fancoil == ControlledProbeDevice::FANCOIL)
			obj_list << ObjectPair(uii, new ThermalControlledProbeFancoil(v.value("descr"), "", ThermalControlledProbe::CentralUnit99Zones, d));
		else
			obj_list << ObjectPair(uii, new ThermalControlledProbe(v.value("descr"), "", ThermalControlledProbe::CentralUnit99Zones, d));
	}
	return obj_list;
}

QList<ObjectPair> parseControlUnit99(const QDomNode &obj)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		ThermalDevice99Zones *d = bt_global::add_device_to_cache(new ThermalDevice99Zones("0"));
		obj_list << ObjectPair(uii, new ThermalControlUnit99Zones(v.value("descr"), "", d));
	}
	return obj_list;
}

ObjectPair parseZone4(const QDomNode &obj, const QDomNode &ist, QString control_unit_where)
{
	XmlObject v(obj);

	v.setIst(ist);
	int uii = getIntAttribute(ist, "uii");
	QString where = v.value("where");
	ControlledProbeDevice::ProbeType fancoil = v.intValue<ControlledProbeDevice::ProbeType>("fancoil");
	ControlledProbeDevice *d = bt_global::add_device_to_cache(new ControlledProbeDevice(where + "#" + control_unit_where, "0#" + control_unit_where, where, ControlledProbeDevice::CENTRAL_4ZONES, fancoil));

	if (fancoil == ControlledProbeDevice::FANCOIL)
		return ObjectPair(uii, new ThermalControlledProbeFancoil(v.value("descr"), "", ThermalControlledProbe::CentralUnit4Zones, d));
	else
		return ObjectPair(uii, new ThermalControlledProbe(v.value("descr"), "", ThermalControlledProbe::CentralUnit4Zones, d));
}

QList<ObjectPair> parseControlUnit4(const QDomNode &obj, QHash<int, QPair<QDomNode, QDomNode> > zones)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QString control_unit_where = v.value("where");

		ThermalDevice4Zones *d = bt_global::add_device_to_cache(new ThermalDevice4Zones("0#" + control_unit_where));
		obj_list << ObjectPair(uii, new ThermalControlUnit4Zones(v.value("descr"), "", d));

		foreach (const QDomNode &link, getChildren(ist.firstChildElement("zones"), "link"))
		{
			int uii = getIntAttribute(link, "uii");

			if (!zones.contains(uii))
			{
				qWarning() << "Invalid uii" << uii << "in thermal control unit";
				continue;
			}

			obj_list << parseZone4(zones[uii].first, zones[uii].second, control_unit_where);
		}
	}
	return obj_list;
}

ThermalControlUnit::ThermalControlUnit(QString _name, QString _key, ThermalDevice *d)
{
	name = _name;
	key = _key;
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
	season = Summer;
	programs << new ThermalRegulationProgram(1, QString("P1"));
	programs << new ThermalRegulationProgram(3, QString("P3"));
	programs << new ThermalRegulationProgram(5, QString("P5"));
	current_modality_index = -1;

	// The objects list should contain only one item per id
	// TODO: fix the the timed programs
	modalities << new ThermalControlUnitProgram("Weekly", ThermalControlUnit::IdWeeklyPrograms, &programs, dev);
	// for unknown reasons these are reverted
	modalities << new ThermalControlUnitTimedProgram("Weekday", ThermalControlUnit::IdHoliday, &programs, dev);
	modalities << new ThermalControlUnitTimedProgram("Holiday", ThermalControlUnit::IdWeekday, &programs, dev);
	modalities << new ThermalControlUnitAntifreeze("Antifreeze", dev);
	modalities << new ThermalControlUnitManual("Manual", dev);
	modalities << new ThermalControlUnitOff("Off", dev);
}

QString ThermalControlUnit::getObjectKey() const
{
	return key;
}

ThermalControlUnit::SeasonType ThermalControlUnit::getSeason() const
{
	return season;
}

void ThermalControlUnit::setSeason(SeasonType s)
{
	if (s == Summer)
		dev->setSummer();
	else
		dev->setWinter();
}

ObjectDataModel *ThermalControlUnit::getPrograms() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel*>(&programs);
}

ObjectDataModel *ThermalControlUnit::getModalities() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel*>(&modalities);
}

QObject* ThermalControlUnit::getCurrentModality() const
{
	return current_modality_index == -1 ? 0 : modalities.getObject(current_modality_index);
}

ThermalControlUnit::ThermalControlUnitId ThermalControlUnit::getCurrentModalityId() const
{
	return current_modality_index == -1 ?
				static_cast<ThermalControlUnitId>(-1) :
				static_cast<ThermalControlUnitId>(modalities.getObject(current_modality_index)->getObjectId());
}

void ThermalControlUnit::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == ThermalDevice::DIM_SEASON)
		{
			ThermalDevice::Season s = static_cast<ThermalDevice::Season>(it.value().toInt());
			if (s == ThermalDevice::SE_SUMMER && season != Summer)
			{
				season = Summer;
				emit seasonChanged();
			}
			else if (s == ThermalDevice::SE_WINTER && season != Winter)
			{
				season = Winter;
				emit seasonChanged();
			}
		}
		else if (it.key() == ThermalDevice::DIM_STATUS)
		{
			ThermalDevice::Status status = static_cast<ThermalDevice::Status>(it.value().toInt());
			int id = -1;
			switch (status)
			{
			case ThermalDevice::ST_HOLIDAY:
				id = ThermalControlUnit::IdHoliday;
				break;
			case ThermalDevice::ST_OFF:
				id = ThermalControlUnit::IdOff;
				break;
			case ThermalDevice::ST_PROTECTION:
				id = ThermalControlUnit::IdAntifreeze;
				break;
			case ThermalDevice::ST_MANUAL:
				id = ThermalControlUnit::IdManual;
				break;
			case ThermalDevice::ST_MANUAL_TIMED:
				id = ThermalControlUnit::IdTimedManual;
				break;
			case ThermalDevice::ST_WEEKEND:
				id = ThermalControlUnit::IdWeekday;
				break;
			case ThermalDevice::ST_PROGRAM:
				id = ThermalControlUnit::IdWeeklyPrograms;
				break;
			case ThermalDevice::ST_SCENARIO:
				id = ThermalControlUnit::IdScenarios;
				break;
			default:
				break;
			}
			if (id == -1)
			{
				qWarning() << "ThermalControlUnit unknown status: " << status;
				continue;
			}

			for (int i = 0; i < modalities.getCount(); ++i)
			{
				if (modalities.getObject(i)->getObjectId() == id)
				{
					if (i != current_modality_index)
					{
						current_modality_index = i;
						emit currentModalityChanged();
						emit currentModalityIdChanged();
					}
					break;
				}
			}
		}
		++it;
	}
}


ThermalControlUnit4Zones::ThermalControlUnit4Zones(QString _name, QString _key, ThermalDevice4Zones *d) :
	ThermalControlUnit(_name, _key, d)
{
	dev = d;
	modalities << new ThermalControlUnitTimedManual("Timed Manual", d);
}


ThermalControlUnit99Zones::ThermalControlUnit99Zones(QString _name, QString _key, ThermalDevice99Zones *d) :
	ThermalControlUnit(_name, _key, d)
{
	dev = d;
	scenarios << new ThermalRegulationProgram(1, QString("S1"));
	scenarios << new ThermalRegulationProgram(3, QString("S3"));
	scenarios << new ThermalRegulationProgram(5, QString("S5"));
	modalities << new ThermalControlUnitScenario("Scenarios", &scenarios, dev);
}

ObjectDataModel *ThermalControlUnit99Zones::getScenarios() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel*>(&scenarios);
}


ThermalControlUnitObject::ThermalControlUnitObject(QString _name, ThermalDevice *_dev)
{
	dev = _dev;
	name = _name;
}

void ThermalControlUnitObject::reset()
{
	to_apply = current;
}


ThermalControlUnitProgram::ThermalControlUnitProgram(QString name, int _object_id, const ObjectDataModel *_programs, ThermalDevice *dev) :
	ThermalControlUnitObject(name, dev)
{
	object_id = _object_id;
	programs = _programs;
	current[PROGRAM_INDEX] = 0;
	to_apply = current;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitProgram::getProgramIndex() const
{
	return to_apply[PROGRAM_INDEX].toInt();
}

void ThermalControlUnitProgram::setProgramIndex(int index)
{
	if (to_apply[PROGRAM_INDEX].toInt() == index || index < 0 || index >= programs->rowCount())
		return;

	to_apply[PROGRAM_INDEX] = index;
	emit programChanged();
}

int ThermalControlUnitProgram::getProgramId() const
{
	return programs->getObject(to_apply[PROGRAM_INDEX].toInt())->getObjectId();
}

QString ThermalControlUnitProgram::getProgramDescription() const
{
	return programs->getObject(to_apply[PROGRAM_INDEX].toInt())->getName();
}

ObjectDataModel *ThermalControlUnitProgram::getPrograms() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel *>(programs);
}

void ThermalControlUnitProgram::apply()
{
	current = to_apply;
	dev->setWeekProgram(programs->getObject(to_apply[PROGRAM_INDEX].toInt())->getObjectId());
}

void ThermalControlUnitProgram::valueReceived(const DeviceValues &values_list)
{
	if (values_list.contains(ThermalDevice99Zones::DIM_PROGRAM))
	{
		int val = values_list[ThermalDevice99Zones::DIM_PROGRAM].toInt();
		for (int i = 0; i < programs->rowCount(); ++i)
		{
			if (programs->getObject(i)->getObjectId() == val)
			{
				qDebug() << "ThermalControlUnitProgram program changed:" << val;
				current[PROGRAM_INDEX] = i;
				to_apply = current;
				emit programChanged();
				break;
			}
		}
	}
}


ThermalControlUnitTimedProgram::ThermalControlUnitTimedProgram(QString name, int _object_id, ObjectDataModel *programs, ThermalDevice *dev) :
	ThermalControlUnitProgram(name, _object_id, programs, dev)
{
	current[DATE] = QDate::currentDate();
	current[TIME] = QTime::currentTime();
	to_apply = current;
}

void ThermalControlUnitTimedProgram::emitTimeSignals(QTime oldTime, QTime newTime)
{
	if (oldTime.hour() != newTime.hour())
		emit hoursChanged();
	if (oldTime.minute() != newTime.minute())
		emit minutesChanged();
	if (oldTime.second() != newTime.second())
		emit secondsChanged();
}

int ThermalControlUnitTimedProgram::getHours() const
{
	const QTime &time = to_apply[TIME].toTime();
	return time.hour();
}

void ThermalControlUnitTimedProgram::setHours(int newValue)
{
	QTime time = to_apply[TIME].toTime();
	int oldValue = time.hour();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;
	QTime newTime = time.addSecs(diff * 60 * 60);
	to_apply[TIME] = newTime;
	emitTimeSignals(time, newTime);
}

int ThermalControlUnitTimedProgram::getMinutes() const
{
	const QTime &time = to_apply[TIME].toTime();
	return time.minute();
}

void ThermalControlUnitTimedProgram::setMinutes(int newValue)
{
	QTime time = to_apply[TIME].toTime();
	int oldValue = time.minute();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;
	QTime newTime = time.addSecs(diff * 60);
	to_apply[TIME] = newTime;
	emitTimeSignals(time, newTime);
}

int ThermalControlUnitTimedProgram::getSeconds() const
{
	const QTime &time = to_apply[TIME].toTime();
	return time.second();
}

void ThermalControlUnitTimedProgram::setSeconds(int newValue)
{
	QTime time = to_apply[TIME].toTime();
	int oldValue = time.second();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;
	QTime newTime = time.addSecs(diff);
	to_apply[TIME] = newTime;
	emitTimeSignals(time, newTime);
}

void ThermalControlUnitTimedProgram::emitDateSignals(QDate oldDate, QDate newDate)
{
	if (oldDate.day() != newDate.day())
		emit daysChanged();
	if (oldDate.month() != newDate.month())
		emit monthsChanged();
	if (oldDate.year() != newDate.year())
		emit yearsChanged();
}

int ThermalControlUnitTimedProgram::getDays() const
{
	const QDate &date = to_apply[DATE].toDate();
	return date.day();
}

void ThermalControlUnitTimedProgram::setDays(int newValue)
{
	QDate date = to_apply[DATE].toDate();
	int oldValue = date.day();
	if ((newValue - oldValue) == 0)
		return;
	QDate newDate = date.addDays(newValue - oldValue);
	to_apply[DATE] = newDate;
	emitDateSignals(date, newDate);
}

int ThermalControlUnitTimedProgram::getMonths() const
{
	const QDate &date = to_apply[DATE].toDate();
	return date.month();
}

void ThermalControlUnitTimedProgram::setMonths(int newValue)
{
	QDate date = to_apply[DATE].toDate();
	int oldValue = date.month();
	if ((newValue - oldValue) == 0)
		return;
	QDate newDate = date.addMonths(newValue - oldValue);
	to_apply[DATE] = newDate;
	emitDateSignals(date, newDate);
}

int ThermalControlUnitTimedProgram::getYears() const
{
	const QDate &date = to_apply[DATE].toDate();
	return date.year();
}

void ThermalControlUnitTimedProgram::setYears(int newValue)
{
	QDate date = to_apply[DATE].toDate();
	int oldValue = date.year();
	if ((newValue - oldValue) == 0)
		return;
	QDate newDate = date.addYears(newValue - oldValue);
	to_apply[DATE] = newDate;
	emitDateSignals(date, newDate);
}

void ThermalControlUnitTimedProgram::apply()
{
	current = to_apply;

	int program_id = getProgramId();
	const QDate &date = to_apply[DATE].toDate();
	const QTime &time = to_apply[TIME].toTime();

	if (getObjectId() == ThermalControlUnit::IdHoliday)
		dev->setHolidayDateTime(date, time, program_id);
	else
		dev->setWeekendDateTime(date, time, program_id);
}


ThermalControlUnitOff::ThermalControlUnitOff(QString name, ThermalDevice *dev) :
	ThermalControlUnitObject(name, dev)
{
}

void ThermalControlUnitOff::apply()
{
	dev->setOff();
}


ThermalControlUnitManual::ThermalControlUnitManual(QString name, ThermalDevice *dev) :
	ThermalControlUnitObject(name, dev)
{
	current[TEMPERATURE] = (getMinimumManualTemperature() + getMaximumManualTemperature()) / 2;
	to_apply = current;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitManual::getTemperature() const
{
	return bt2Celsius(to_apply[TEMPERATURE].toInt());
}

void ThermalControlUnitManual::setTemperature(int temp)
{
	if ((temp < getMinimumManualTemperature()) || (temp > getMaximumManualTemperature()))
		return;
	if (celsius2Bt(temp) != to_apply[TEMPERATURE].toUInt())
	{
		to_apply[TEMPERATURE] = celsius2Bt(temp);
		emit temperatureChanged();
	}
}

int ThermalControlUnitManual::getMinimumManualTemperature() const
{
	return bt2Celsius(dev->minimumTemp());
}

int ThermalControlUnitManual::getMaximumManualTemperature() const
{
	return bt2Celsius(dev->maximumTemp());
}

void ThermalControlUnitManual::apply()
{
	current = to_apply;
	dev->setManualTemp(to_apply[TEMPERATURE].toInt());
}

void ThermalControlUnitManual::valueReceived(const DeviceValues &values_list)
{
	if (values_list.contains(ThermalDevice::DIM_TEMPERATURE))
	{
		int val = values_list[ThermalDevice::DIM_TEMPERATURE].toInt();
		if (val != current[TEMPERATURE].toInt())
		{
			current[TEMPERATURE] = val;
			to_apply = current;
			emit temperatureChanged();
		}
	}
}


ThermalControlUnitTimedManual::ThermalControlUnitTimedManual(QString name, ThermalDevice4Zones *_dev) :
	ThermalControlUnitManual(name, _dev)
{
	dev = _dev;
	current[TIME] = QTime::currentTime();
	to_apply = current;
}

void ThermalControlUnitTimedManual::emitTimeSignals(QTime oldTime, QTime newTime)
{
	if (oldTime.hour() != newTime.hour())
		emit hoursChanged();
	if (oldTime.minute() != newTime.minute())
		emit minutesChanged();
	if (oldTime.second() != newTime.second())
		emit secondsChanged();
}

int ThermalControlUnitTimedManual::getHours() const
{
	const QTime &time = to_apply[TIME].toTime();
	return time.hour();
}

void ThermalControlUnitTimedManual::setHours(int newValue)
{
	QTime time = to_apply[TIME].toTime();
	int oldValue = time.hour();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;
	QTime newTime = time.addSecs(diff * 60 * 60);
	to_apply[TIME] = newTime;
	emitTimeSignals(time, newTime);
}

int ThermalControlUnitTimedManual::getMinutes() const
{
	const QTime &time = to_apply[TIME].toTime();
	return time.minute();
}

void ThermalControlUnitTimedManual::setMinutes(int newValue)
{
	QTime time = to_apply[TIME].toTime();
	int oldValue = time.minute();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;
	QTime newTime = time.addSecs(diff * 60);
	to_apply[TIME] = newTime;
	emitTimeSignals(time, newTime);
}

int ThermalControlUnitTimedManual::getSeconds() const
{
	const QTime &time = to_apply[TIME].toTime();
	return time.second();
}

void ThermalControlUnitTimedManual::setSeconds(int newValue)
{
	QTime time = to_apply[TIME].toTime();
	int oldValue = time.second();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;
	QTime newTime = time.addSecs(diff);
	to_apply[TIME] = newTime;
	emitTimeSignals(time, newTime);
}

void ThermalControlUnitTimedManual::apply()
{
	current = to_apply;
	dev->setManualTempTimed(getTemperature(), to_apply[TIME].toTime());
}


ThermalControlUnitAntifreeze::ThermalControlUnitAntifreeze(QString name, ThermalDevice *dev) :
	ThermalControlUnitObject(name, dev)
{
}

void ThermalControlUnitAntifreeze::apply()
{
	dev->setProtection();
}


ThermalControlUnitScenario::ThermalControlUnitScenario(QString name, const ObjectDataModel *_programs, ThermalDevice99Zones *_dev) :
	ThermalControlUnitObject(name, _dev)
{
	dev = _dev;
	scenarios = _programs;
	current[SCENARIO_INDEX] = 0;
	to_apply = current;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitScenario::getScenarioIndex() const
{
	return to_apply[SCENARIO_INDEX].toInt();
}

void ThermalControlUnitScenario::setScenarioIndex(int index)
{
	if (to_apply[SCENARIO_INDEX].toInt() == index || index < 0 || index >= scenarios->getCount())
		return;

	to_apply[SCENARIO_INDEX] = index;
	emit scenarioChanged();
}

ObjectDataModel *ThermalControlUnitScenario::getScenarios() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel*>(scenarios);
}

int ThermalControlUnitScenario::getScenarioId() const
{
	return scenarios->getObject(to_apply[SCENARIO_INDEX].toInt())->getObjectId();
}

QString ThermalControlUnitScenario::getScenarioDescription() const
{
	return scenarios->getObject(to_apply[SCENARIO_INDEX].toInt())->getName();
}

void ThermalControlUnitScenario::apply()
{
	current = to_apply;
	dev->setScenario(getScenarioId());
}

void ThermalControlUnitScenario::valueReceived(const DeviceValues &values_list)
{
	if (values_list.contains(ThermalDevice99Zones::DIM_SCENARIO))
	{
		int val = values_list[ThermalDevice99Zones::DIM_SCENARIO].toInt();
		for (int i = 0; i < scenarios->getCount(); ++i)
		{
			if (scenarios->getObject(i)->getObjectId() == val)
			{
				qDebug() << "ThermalControlUnitScenario scenario changed:" << val;
				current[SCENARIO_INDEX] = i;
				to_apply = current;
				emit scenarioChanged();
				break;
			}
		}
	}
}

ThermalRegulationProgram::ThermalRegulationProgram(int number, const QString &name)
{
	program_number = number;
	program_name = name;
}
