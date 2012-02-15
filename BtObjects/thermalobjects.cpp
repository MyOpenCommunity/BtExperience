#include "thermalobjects.h"
#include "thermal_device.h"
#include "scaleconversion.h" // bt2Celsius
#include "objectlistmodel.h"

#include <QDebug>


enum ThermalRegulationStateKeys
{
	PROGRAM_INDEX,
	DATE,
	TIME,
	TEMPERATURE,
	SCENARIO_INDEX
};


ThermalControlUnit::ThermalControlUnit(QString _name, QString _key, ThermalDevice *d)
{
	name = _name;
	key = _key;
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
	season = Summer;
	programs << qMakePair(1, QString("P1")) << qMakePair(3, QString("P3")) << qMakePair(5, QString("P5"));
	current_modality = -1;

	// The objects list should contain only one item per id
	objs << new ThermalControlUnitProgram("Settimanale", ThermalControlUnit::IdWeeklyPrograms, this, dev);
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

QObject* ThermalControlUnit::getCurrentModality() const
{
	return current_modality == -1 ? 0 : objs.at(current_modality);
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
				break; // Not implemented for now
			case ThermalDevice::ST_WEEKEND:
				id = ThermalControlUnit::IdVacation;
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

			for (int i = 0; i < objs.length(); ++i)
			{
				if (objs[i]->getObjectId() == id)
				{
					if (i != current_modality)
					{
						current_modality = i;
						emit currentModalityChanged();
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
}


ThermalControlUnit99Zones::ThermalControlUnit99Zones(QString _name, QString _key, ThermalDevice99Zones *d) :
	ThermalControlUnit(_name, _key, d)
{
	dev = d;
	scenarios << qMakePair(1, QString("S1")) << qMakePair(3, QString("S3")) << qMakePair(5, QString("S5"));
	objs << new ThermalControlUnitScenario("Scenari", this, dev);
}

ThermalRegulationProgramList ThermalControlUnit99Zones::getScenarios() const
{
	return scenarios;
}


ThermalControlUnitObject::ThermalControlUnitObject(QString _name, ThermalDevice *_dev)
{
	dev = _dev;
	name = _name;
}

QString ThermalControlUnitObject::getObjectKey() const
{
	return QString();
}

QString ThermalControlUnitObject::getName() const
{
	return name;
}

void ThermalControlUnitObject::reset()
{
	to_apply = current;
}


ThermalControlUnitProgram::ThermalControlUnitProgram(QString name, int _object_id, const ThermalControlUnit *unit, ThermalDevice *dev) :
	ThermalControlUnitObject(name, dev)
{
	object_id = _object_id;
	programs = unit->getPrograms();
	current[PROGRAM_INDEX] = 0;
	to_apply = current;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitProgram::getProgramCount() const
{
	return programs.count();
}

int ThermalControlUnitProgram::getProgramIndex() const
{
	return to_apply[PROGRAM_INDEX].toInt();
}

void ThermalControlUnitProgram::setProgramIndex(int index)
{
	if (to_apply[PROGRAM_INDEX].toInt() == index || index < 0 || index >= programs.count())
		return;

	to_apply[PROGRAM_INDEX] = index;
	emit programChanged();
}

int ThermalControlUnitProgram::getProgramId() const
{
	return programs[to_apply[PROGRAM_INDEX].toInt()].first;
}

QString ThermalControlUnitProgram::getProgramDescription() const
{
	return programs[to_apply[PROGRAM_INDEX].toInt()].second;
}

void ThermalControlUnitProgram::apply()
{
	current = to_apply;
	dev->setWeekProgram(programs[to_apply[PROGRAM_INDEX].toInt()].first);
}

void ThermalControlUnitProgram::valueReceived(const DeviceValues &values_list)
{
	if (values_list.contains(ThermalDevice99Zones::DIM_PROGRAM))
	{
		int val = values_list[ThermalDevice99Zones::DIM_PROGRAM].toInt();
		for (int i = 0; i < programs.length(); ++i)
		{
			if (programs[i].first == val)
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


ThermalControlUnitTimedProgram::ThermalControlUnitTimedProgram(QString name, int _object_id, const ThermalControlUnit *unit, ThermalDevice *dev) :
	ThermalControlUnitProgram(name, _object_id, unit, dev)
{
	current[DATE] = QDate::currentDate();
	current[TIME] = QTime::currentTime();
	to_apply = current;
}

QDate ThermalControlUnitTimedProgram::getDate() const
{
	return to_apply[DATE].toDate();
}

void ThermalControlUnitTimedProgram::setDate(QDate date)
{
	if (to_apply[DATE].toDate() == date)
		return;

	to_apply[DATE] = date;
	emit dateChanged();
}

QTime ThermalControlUnitTimedProgram::getTime() const
{
	return to_apply[TIME].toTime();
}

void ThermalControlUnitTimedProgram::setTime(QTime time)
{
	if (to_apply[TIME].toTime() == time)
		return;

	to_apply[TIME] = time;
	emit timeChanged();
}

void ThermalControlUnitTimedProgram::apply()
{
	current = to_apply;

	int program_id = getProgramId();
	const QDate &date = to_apply[DATE].toDate();
	const QTime &time = to_apply[TIME].toTime();

	if (getObjectId() == ThermalControlUnit::IdHoliday)
		dev->setWeekendDateTime(date, time, program_id);
	else
		dev->setHolidayDateTime(date, time, program_id);
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
	current[TEMPERATURE] = 0;
	to_apply = current;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitManual::getTemperature() const
{
	return bt2Celsius(to_apply[TEMPERATURE].toInt());
}

void ThermalControlUnitManual::setTemperature(int temp)
{
	if (celsius2Bt(temp) != to_apply[TEMPERATURE].toInt())
	{
		to_apply[TEMPERATURE] = celsius2Bt(temp);
		emit temperatureChanged();
	}
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
			qDebug() << "ThermalControlUnitManual temperature received:" << val;
			current[TEMPERATURE] = val;
			to_apply = current;
			emit temperatureChanged();
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


ThermalControlUnitScenario::ThermalControlUnitScenario(QString name, const ThermalControlUnit99Zones *unit, ThermalDevice99Zones *_dev) :
	ThermalControlUnitObject(name, _dev)
{
	dev = _dev;
	scenarios = unit->getScenarios();
	current[SCENARIO_INDEX] = 0;
	to_apply = current;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

int ThermalControlUnitScenario::getScenarioCount() const
{
	return scenarios.count();
}

int ThermalControlUnitScenario::getScenarioIndex() const
{
	return to_apply[SCENARIO_INDEX].toInt();
}

void ThermalControlUnitScenario::setScenarioIndex(int index)
{
	if (to_apply[SCENARIO_INDEX].toInt() == index || index < 0 || index >= scenarios.count())
		return;

	to_apply[SCENARIO_INDEX] = index;
	emit scenarioChanged();
}

int ThermalControlUnitScenario::getScenarioId() const
{
	return scenarios[to_apply[SCENARIO_INDEX].toInt()].first;
}

QString ThermalControlUnitScenario::getScenarioDescription() const
{
	return scenarios[to_apply[SCENARIO_INDEX].toInt()].second;
}

void ThermalControlUnitScenario::apply()
{
	current = to_apply;
	dev->setScenario(scenarios[to_apply[SCENARIO_INDEX].toInt()].first);
}

void ThermalControlUnitScenario::valueReceived(const DeviceValues &values_list)
{
	if (values_list.contains(ThermalDevice99Zones::DIM_SCENARIO))
	{
		int val = values_list[ThermalDevice99Zones::DIM_SCENARIO].toInt();
		for (int i = 0; i < scenarios.length(); ++i)
		{
			if (scenarios[i].first == val)
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
