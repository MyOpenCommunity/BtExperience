#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

#include "objectinterface.h"
#include "objectlistmodel.h"
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

typedef QHash<int, QVariant> ThermalRegulationState;

class ThermalRegulationProgram : public ObjectInterface
{
	Q_OBJECT

public:
	ThermalRegulationProgram(int number, const QString &name);
	virtual int getObjectId() const { return program_number; }

	virtual QString getObjectKey() const { return QString(); }

	virtual ObjectCategory getCategory() const { return ThermalRegulation; }

	virtual QString getName() const { return program_name; }

private:
	int program_number;
	QString program_name;
};


class ThermalControlUnit : public ObjectInterface
{
	friend class TestThermalControlUnit;
	friend class TestThermalControlUnitObject;

	Q_OBJECT
	Q_ENUMS(SeasonType)
	Q_ENUMS(ThermalControlUnitId)
	Q_PROPERTY(SeasonType season READ getSeason WRITE setSeason NOTIFY seasonChanged)
	Q_PROPERTY(ObjectListModel *modalities READ getModalities NOTIFY modalitiesChanged)
	Q_PROPERTY(ObjectListModel *programs READ getPrograms NOTIFY programsChanged)
	Q_PROPERTY(QObject *currentModality READ getCurrentModality NOTIFY currentModalityChanged)

public:
	enum ThermalControlUnitId
	{
		IdHoliday,
		IdOff,
		IdAntifreeze,
		IdManual,
		IdTimedManual,
		IdWeeklyPrograms,
		IdVacation,
		IdScenarios
	};

	enum SeasonType
	{
		Summer,
		Winter
	};

	ThermalControlUnit(QString name, QString key, ThermalDevice *d);

	virtual QString getObjectKey() const;

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::ThermalRegulation;
	}

	virtual QString getName() const;

	SeasonType getSeason() const;
	void setSeason(SeasonType s);

	ObjectListModel *getModalities() const;
	ObjectListModel *getPrograms() const;

	QObject* getCurrentModality() const;

signals:
	void seasonChanged();
	void modalitiesChanged();
	void programsChanged();
	void currentModalityChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	ObjectListModel modalities;

private:
	QString name;
	QString key;
	int temperature;
	SeasonType season;
	ObjectListModel programs;
	ThermalDevice *dev;
	int current_modality;
};


class ThermalControlUnit4Zones : public ThermalControlUnit
{
	friend class TestThermalControlUnit4Zones;

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
	friend class TestThermalControlUnit99Zones;

	Q_OBJECT

public:
	ThermalControlUnit99Zones(QString name, QString key, ThermalDevice99Zones *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdThermalControlUnit99;
	}

	ObjectListModel *getScenarios() const;

private:
	ThermalDevice99Zones *dev;
	ObjectListModel scenarios;
};


class ThermalControlUnitObject : public ObjectInterface
{
	friend class TestThermalControlUnitObject;

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
	friend class TestThermalControlUnitProgram;

	Q_OBJECT
	Q_PROPERTY(int programIndex READ getProgramIndex WRITE setProgramIndex NOTIFY programChanged)
	Q_PROPERTY(QString programDescription READ getProgramDescription NOTIFY programChanged)
	Q_PROPERTY(ObjectListModel *programs READ getPrograms CONSTANT)

public:
	ThermalControlUnitProgram(QString name, int object_id, const ObjectListModel *_programs, ThermalDevice *dev);

	virtual int getObjectId() const
	{
		return object_id;
	}

	int getProgramIndex() const;
	void setProgramIndex(int index);

	int getProgramId() const;
	QString getProgramDescription() const;
	ObjectListModel *getPrograms() const;

public slots:
	virtual void apply();

signals:
	void programChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	const ObjectListModel *programs;
	int object_id;
};


class ThermalControlUnitTimedProgram : public ThermalControlUnitProgram
{
	Q_OBJECT
	Q_PROPERTY(QDate date READ getDate WRITE setDate NOTIFY dateChanged)
	Q_PROPERTY(QTime time READ getTime WRITE setTime NOTIFY timeChanged)

public:
	ThermalControlUnitTimedProgram(QString name, int object_id, ObjectListModel *programs, ThermalDevice *dev);

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
	friend class TestThermalControlUnitManual;

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
	virtual void valueReceived(const DeviceValues &values_list);
};


class ThermalControlUnitTimedManual : public ThermalControlUnitManual
{
	friend class TestThermalControlUnitTimedManual;

	Q_OBJECT
	Q_PROPERTY(QTime time READ getTime WRITE setTime NOTIFY timeChanged)

public:
	ThermalControlUnitTimedManual(QString name, ThermalDevice4Zones *dev);

	virtual int getObjectId() const
	{
		return ThermalControlUnit::IdTimedManual;
	}

	QTime getTime() const;
	void setTime(QTime time);


public slots:
	virtual void apply();

signals:
	void timeChanged();

private:
	ThermalDevice4Zones *dev;
};


class ThermalControlUnitScenario : public ThermalControlUnitObject
{
	friend class TestThermalControlUnitScenario;

	Q_OBJECT
	Q_PROPERTY(int scenarioIndex READ getScenarioIndex WRITE setScenarioIndex NOTIFY scenarioChanged)
	Q_PROPERTY(QString scenarioDescription READ getScenarioDescription NOTIFY scenarioChanged)
	Q_PROPERTY(ObjectListModel *scenarios READ getScenarios CONSTANT)

public:
	ThermalControlUnitScenario(QString name, const ObjectListModel *scenarios, ThermalDevice99Zones *dev);

	virtual int getObjectId() const
	{
		return ThermalControlUnit::IdScenarios;
	}

	int getScenarioIndex() const;
	void setScenarioIndex(int index);

	ObjectListModel *getScenarios() const;

	QString getScenarioDescription() const;

public slots:
	virtual void apply();

signals:
	void scenarioChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	int getScenarioId() const;

	ThermalDevice99Zones *dev;
	const ObjectListModel *scenarios;
};


#endif // THERMALOBJECTS_H
