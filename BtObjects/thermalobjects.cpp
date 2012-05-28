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
	programs.insertWithoutUii(new ThermalRegulationProgram(1, QString("P1")));
	programs.insertWithoutUii(new ThermalRegulationProgram(3, QString("P3")));
	programs.insertWithoutUii(new ThermalRegulationProgram(5, QString("P5")));
	current_modality = -1;

	// The objects list should contain only one item per id
	// TODO: fix the the timed programs
	modalities.insertWithoutUii(new ThermalControlUnitProgram("Settimanale", ThermalControlUnit::IdWeeklyPrograms, &programs, dev));
	modalities.insertWithoutUii(new ThermalControlUnitTimedProgram("Festivi", ThermalControlUnit::IdHoliday, &programs, dev));
	modalities.insertWithoutUii(new ThermalControlUnitTimedProgram("Vacanze", ThermalControlUnit::IdWorking, &programs, dev));
	modalities.insertWithoutUii(new ThermalControlUnitAntifreeze("Antigelo", dev));
	modalities.insertWithoutUii(new ThermalControlUnitManual("Manuale", dev));
	modalities.insertWithoutUii(new ThermalControlUnitOff("Off", dev));
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

ObjectListModel *ThermalControlUnit::getPrograms() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectListModel*>(&programs);
}

ObjectListModel *ThermalControlUnit::getModalities() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectListModel*>(&modalities);
}

QObject* ThermalControlUnit::getCurrentModality() const
{
	return current_modality == -1 ? 0 : modalities.getObject(current_modality);
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
				id = ThermalControlUnit::IdWorking;
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

			for (int i = 0; i < modalities.getSize(); ++i)
			{
				if (modalities.getObject(i)->getObjectId() == id)
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
	modalities.insertWithoutUii(new ThermalControlUnitTimedManual("Manuale temporizzato", d));
}


ThermalControlUnit99Zones::ThermalControlUnit99Zones(QString _name, QString _key, ThermalDevice99Zones *d) :
	ThermalControlUnit(_name, _key, d)
{
	dev = d;
	scenarios.insertWithoutUii(new ThermalRegulationProgram(1, QString("S1")));
	scenarios.insertWithoutUii(new ThermalRegulationProgram(3, QString("S3")));
	scenarios.insertWithoutUii(new ThermalRegulationProgram(5, QString("S5")));
	modalities.insertWithoutUii(new ThermalControlUnitScenario("Scenari", &scenarios, dev));
}

ObjectListModel *ThermalControlUnit99Zones::getScenarios() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectListModel*>(&scenarios);
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


ThermalControlUnitProgram::ThermalControlUnitProgram(QString name, int _object_id, const ObjectListModel *_programs, ThermalDevice *dev) :
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

ObjectListModel *ThermalControlUnitProgram::getPrograms() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectListModel *>(programs);
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


ThermalControlUnitTimedProgram::ThermalControlUnitTimedProgram(QString name, int _object_id, ObjectListModel *programs, ThermalDevice *dev) :
	ThermalControlUnitProgram(name, _object_id, programs, dev)
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
	if (celsius2Bt(temp) != to_apply[TEMPERATURE].toUInt())
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


ThermalControlUnitTimedManual::ThermalControlUnitTimedManual(QString name, ThermalDevice4Zones *_dev) :
	ThermalControlUnitManual(name, _dev)
{
	dev = _dev;
	current[TIME] = QTime::currentTime();
	to_apply = current;
}

QTime ThermalControlUnitTimedManual::getTime() const
{
	return to_apply[TIME].toTime();
}

void ThermalControlUnitTimedManual::setTime(QTime time)
{
	if (to_apply[TIME].toTime() == time)
		return;

	to_apply[TIME] = time;
	emit timeChanged();
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


ThermalControlUnitScenario::ThermalControlUnitScenario(QString name, const ObjectListModel *_programs, ThermalDevice99Zones *_dev) :
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
	if (to_apply[SCENARIO_INDEX].toInt() == index || index < 0 || index >= scenarios->getSize())
		return;

	to_apply[SCENARIO_INDEX] = index;
	emit scenarioChanged();
}

ObjectListModel *ThermalControlUnitScenario::getScenarios() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectListModel*>(scenarios);
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
		for (int i = 0; i < scenarios->getSize(); ++i)
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
