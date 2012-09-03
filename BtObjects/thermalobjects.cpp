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
			obj_list << ObjectPair(uii, new ThermalControlledProbeFancoil(v.value("descr"), "0", ThermalControlledProbe::CentralUnit99Zones, d));
		else
			obj_list << ObjectPair(uii, new ThermalControlledProbe(v.value("descr"), "0", ThermalControlledProbe::CentralUnit99Zones, d));
	}
	return obj_list;
}

QList<ThermalRegulationProgram *> parsePrograms(const QDomNode &parent, QString tag)
{
	QList<ThermalRegulationProgram *> programs;

	foreach (const QDomNode &program, getChildren(parent, tag))
	{
		ThermalControlUnit::SeasonType season = getIntAttribute(program, "type") == 0 ? ThermalControlUnit::Winter : ThermalControlUnit::Summer;
		int num = getIntAttribute(program, "num");
		QString descr = getAttribute(program, "descr");

		programs << new ThermalRegulationProgram(num, season, descr);
	}
	return programs;
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
		ThermalControlUnit99Zones *cu = new ThermalControlUnit99Zones(v.value("descr"), "0", d);
		cu->setPrograms(parsePrograms(ist.firstChildElement("programs"), "program"));
		cu->setScenarios(parsePrograms(ist.firstChildElement("scenarios"), "scenario"));
		obj_list << ObjectPair(uii, cu);
	}
	Q_ASSERT_X(obj_list.count() == 1, "parseControlUnit99", "Can't have more than one 99-zones control unit");
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
		return ObjectPair(uii, new ThermalControlledProbeFancoil(v.value("descr"), control_unit_where, ThermalControlledProbe::CentralUnit4Zones, d));
	else
		return ObjectPair(uii, new ThermalControlledProbe(v.value("descr"), control_unit_where, ThermalControlledProbe::CentralUnit4Zones, d));
}

QList<ObjectPair> parseControlUnit4(const QDomNode &obj, QHash<int, QPair<QDomNode, QDomNode> > zones)
{
	QList<ObjectPair> obj_list;
	XmlObject v(obj);

	foreach (const QDomNode &ist, getChildren(obj, "ist"))
	{
		v.setIst(ist);
		int cu_uii = getIntAttribute(ist, "uii");
		QString cu_where = v.value("where");

		ThermalDevice4Zones *d = bt_global::add_device_to_cache(new ThermalDevice4Zones("0#" + cu_where));
		ThermalControlUnit4Zones *cu = new ThermalControlUnit4Zones(v.value("descr"), cu_where, d);
		cu->setPrograms(parsePrograms(ist.firstChildElement("programs"), "program"));
		obj_list << ObjectPair(cu_uii, cu);

		foreach (const QDomNode &link, getChildren(ist.firstChildElement("zones"), "link"))
		{
			int zone_uii = getIntAttribute(link, "uii");

			if (!zones.contains(zone_uii))
			{
				qWarning() << "Invalid uii" << zone_uii << "in thermal control unit";
				continue;
			}

			obj_list << parseZone4(zones[zone_uii].first, zones[zone_uii].second, cu_where);
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
	programs = &summer_programs;
	current_modality_index = -1;

	// The objects list should contain only one item per id
	// TODO: fix the the timed programs
	modalities << new ThermalControlUnitProgram("Weekly", ThermalControlUnit::IdWeeklyPrograms, &summer_programs, &winter_programs, dev);
	// for unknown reasons these are reverted
	modalities << new ThermalControlUnitTimedProgram("Weekday", ThermalControlUnit::IdHoliday, &summer_programs, &winter_programs, dev);
	modalities << new ThermalControlUnitTimedProgram("Holiday", ThermalControlUnit::IdWeekday, &summer_programs, &winter_programs, dev);
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

void ThermalControlUnit::setPrograms(QList<ThermalRegulationProgram *> _programs)
{
	// can only be called once during parsing
	Q_ASSERT(summer_programs.getCount() == 0 && winter_programs.getCount() == 0);

	foreach (ThermalRegulationProgram *p, _programs)
	{
		if (p->getSeason() == ThermalControlUnit::Summer)
			summer_programs << p;
		else
			winter_programs << p;
	}
}

ObjectDataModel *ThermalControlUnit::getPrograms() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel*>(programs);
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
	scenarios = &summer_scenarios;
	modalities << new ThermalControlUnitScenario("Scenarios", &summer_scenarios, &winter_scenarios, dev);
}

void ThermalControlUnit99Zones::setScenarios(QList<ThermalRegulationProgram *> _scenarios)
{
	// can only be called once during parsing
	Q_ASSERT(summer_scenarios.getCount() == 0 && winter_scenarios.getCount() == 0);

	foreach (ThermalRegulationProgram *s, _scenarios)
	{
		if (s->getSeason() == ThermalControlUnit::Summer)
			summer_scenarios << s;
		else
			winter_scenarios << s;
	}
}

ObjectDataModel *ThermalControlUnit99Zones::getScenarios() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel*>(scenarios);
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


ThermalControlUnitProgram::ThermalControlUnitProgram(QString name, int _object_id, const ObjectDataModel *_summer_programs, const ObjectDataModel *_winter_programs, ThermalDevice *dev) :
	ThermalControlUnitObject(name, dev)
{
	object_id = _object_id;
	summer_programs = _summer_programs;
	winter_programs = _winter_programs;
	programs = summer_programs;
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
	if (values_list.contains(ThermalDevice::DIM_SEASON))
	{
		const ObjectDataModel *old_programs = programs;

		ThermalDevice::Season s = static_cast<ThermalDevice::Season>(values_list[ThermalDevice::DIM_SEASON].toInt());
		programs = s == ThermalDevice::SE_SUMMER ? summer_programs : winter_programs;

		if (old_programs != programs)
			emit programsChanged();
	}
	if (values_list.contains(ThermalDevice::DIM_PROGRAM))
	{
		int val = values_list[ThermalDevice::DIM_PROGRAM].toInt();
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


ThermalControlUnitTimedProgram::ThermalControlUnitTimedProgram(QString name, int _object_id, ObjectDataModel *summer_programs, ObjectDataModel *winter_programs, ThermalDevice *dev) :
	ThermalControlUnitProgram(name, _object_id, summer_programs, winter_programs, dev)
{
	current[DATE] = QDate(0, 0, 0);
	current[TIME] = QTime(0, 0);
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
	if (!oldDate.isValid() && newDate.isValid())
	{
		emit daysChanged();
		emit monthsChanged();
		emit yearsChanged();
		return;
	}
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
	QDate newDate = date.isValid() ? date.addYears(newValue - oldValue) : QDate(newValue, 1, 1);
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

void ThermalControlUnitTimedProgram::valueReceived(const DeviceValues &values_list)
{
	ThermalControlUnitProgram::valueReceived(values_list);

	if (values_list.contains(ThermalDevice::DIM_DATE))
	{
		QDate val = values_list[ThermalDevice::DIM_DATE].toDate();
		if (val.isValid())
		{
			QDate old = current[DATE].toDate();
			current[DATE] = val;
			to_apply = current;
			emitDateSignals(old, val);
		}
	}
	if (values_list.contains(ThermalDevice::DIM_TIME))
	{
		QTime val = values_list[ThermalDevice::DIM_TIME].toTime();
		if (val.isValid())
		{
			QTime old = current[TIME].toTime();
			current[TIME] = val;
			to_apply = current;
			emitTimeSignals(old, val);
		}
	}
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
	QVariant v;
	BtTime bt;
	bt.setMaxHours(25);
	v.setValue(bt);
	current[TIME] = v;
	to_apply = current;
}

void ThermalControlUnitTimedManual::emitTimeSignals(QVariant oldTime, QVariant newTime)
{
	BtTime oldBtTime, newBtTime;

	if (oldTime.canConvert<BtTime>())
		oldBtTime = oldTime.value<BtTime>();

	if (newTime.canConvert<BtTime>())
		newBtTime = newTime.value<BtTime>();

	if (oldBtTime.hour() != newBtTime.hour())
		emit hoursChanged();
	if (oldBtTime.minute() != newBtTime.minute())
		emit minutesChanged();
	if (oldBtTime.second() != newBtTime.second())
		emit secondsChanged();
}

int ThermalControlUnitTimedManual::toHours(const QVariant &btTime) const
{
	BtTime t;

	if (!btTime.canConvert<BtTime>())
		return 0;

	t = btTime.value<BtTime>();
	return t.hour();
}

int ThermalControlUnitTimedManual::toMinutes(const QVariant &btTime) const
{
	BtTime t;

	if (!btTime.canConvert<BtTime>())
		return 0;

	t = btTime.value<BtTime>();
	return t.minute();
}

int ThermalControlUnitTimedManual::toSeconds(const QVariant &btTime) const
{
	BtTime t;

	if (!btTime.canConvert<BtTime>())
		return 0;

	t = btTime.value<BtTime>();
	return t.second();
}

int ThermalControlUnitTimedManual::getHours() const
{
	return toHours(to_apply[TIME]);
}

void ThermalControlUnitTimedManual::setHours(int newValue)
{
	int oldValue = getHours();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;

	if (!to_apply[TIME].canConvert<BtTime>())
		return;

	QVariant time = to_apply[TIME];
	to_apply[TIME].setValue(to_apply[TIME].value<BtTime>().addSecond(diff * 60 * 60));

	emitTimeSignals(time, to_apply[TIME]);
}

int ThermalControlUnitTimedManual::getMinutes() const
{
	return toMinutes(to_apply[TIME]);
}

void ThermalControlUnitTimedManual::setMinutes(int newValue)
{
	int oldValue = getMinutes();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;

	if (!to_apply[TIME].canConvert<BtTime>())
		return;

	QVariant time = to_apply[TIME];
	to_apply[TIME].setValue(to_apply[TIME].value<BtTime>().addSecond(diff * 60));

	emitTimeSignals(time, to_apply[TIME]);
}

int ThermalControlUnitTimedManual::getSeconds() const
{
	return toSeconds(to_apply[TIME]);
}

void ThermalControlUnitTimedManual::setSeconds(int newValue)
{
	int oldValue = getSeconds();
	int diff = newValue - oldValue;
	if (newValue == oldValue)
		return;

	if (!to_apply[TIME].canConvert<BtTime>())
		return;

	QVariant time = to_apply[TIME];
	to_apply[TIME].setValue(to_apply[TIME].value<BtTime>().addSecond(diff));

	emitTimeSignals(time, to_apply[TIME]);
}

void ThermalControlUnitTimedManual::apply()
{
	current = to_apply;
	dev->setManualTempTimed(getTemperature(), to_apply[TIME].toTime());
}

void ThermalControlUnitTimedManual::valueReceived(const DeviceValues &values_list)
{
	ThermalControlUnitManual::valueReceived(values_list);

	if (values_list.contains(ThermalDevice::DIM_DURATION))
	{
		QVariant val = values_list[ThermalDevice::DIM_DURATION];
		if (val.canConvert<BtTime>())
		{
			val.value<BtTime>().setMaxHours(25);
			QVariant old = current[TIME];
			current[TIME] = val;
			to_apply = current;
			emitTimeSignals(old, val);
		}
	}
}


ThermalControlUnitAntifreeze::ThermalControlUnitAntifreeze(QString name, ThermalDevice *dev) :
	ThermalControlUnitObject(name, dev)
{
}

void ThermalControlUnitAntifreeze::apply()
{
	dev->setProtection();
}


ThermalControlUnitScenario::ThermalControlUnitScenario(QString name, const ObjectDataModel *_summer_scenarios, const ObjectDataModel *_winter_scenarios, ThermalDevice99Zones *_dev) :
	ThermalControlUnitObject(name, _dev)
{
	dev = _dev;
	summer_scenarios = _summer_scenarios;
	winter_scenarios = _winter_scenarios;
	scenarios = summer_scenarios;
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
	if (values_list.contains(ThermalDevice::DIM_SEASON))
	{
		const ObjectDataModel *old_scenarios = scenarios;

		ThermalDevice::Season s = static_cast<ThermalDevice::Season>(values_list[ThermalDevice::DIM_SEASON].toInt());
		scenarios = s == ThermalDevice::SE_SUMMER ? summer_scenarios : winter_scenarios;

		if (old_scenarios != scenarios)
			emit scenariosChanged();
	}
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

ThermalRegulationProgram::ThermalRegulationProgram(int number, ThermalControlUnit::SeasonType _season, const QString &name)
{
	season = _season;
	program_number = number;
	program_name = name;
}
