#ifndef THERMALOBJECTS_H
#define THERMALOBJECTS_H

/*!
	\defgroup ThermalRegulation Thermal regulation
*/

#include "objectinterface.h"
#include "objectmodel.h"
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
class ObjectDataModel;
class ThermalControlUnitObject;
class QDomNode;

typedef QHash<int, QVariant> ThermalRegulationState;


QList<ObjectPair> parseControlUnit99(const QDomNode &obj);
QList<ObjectPair> parseControlUnit4(const QDomNode &obj, QHash<int, QPair<QDomNode, QDomNode> > zones);
QList<ObjectPair> parseZone99(const QDomNode &obj);


/*!
	\ingroup ThermalRegulation
	\brief Container for a thermal regulation program or scenario

	The program/scenario number is in the object id, the program/scenario name in the object name.
*/
class ThermalRegulationProgram : public ObjectInterface
{
	Q_OBJECT

public:
	ThermalRegulationProgram(int number, const QString &name);
	virtual int getObjectId() const { return program_number; }

	virtual QString getName() const { return program_name; }

private:
	int program_number;
	QString program_name;
};


/*!
	\ingroup ThermalRegulation
	\brief Base class for the 4 zones and 99 zones control units

	The only difference is that only the 4 zones control unit has timed manual mode
	and only 99 zones control unit has scenario mode.
*/
class ThermalControlUnit : public ObjectInterface
{
	friend class TestThermalControlUnit;
	friend class TestThermalControlUnitObject;

	Q_OBJECT
	Q_ENUMS(SeasonType)
	Q_ENUMS(ThermalControlUnitId)

	/*!
		\brief Sets and gets the current season
	*/
	Q_PROPERTY(SeasonType season READ getSeason WRITE setSeason NOTIFY seasonChanged)

	/*!
		\brief Gets the list of modality object configured for this control unit

		Each object can be used to set the control unit to a different modality.

		\see ThermalControlUnitObject
		\see ThermalControlUnitProgram
		\see ThermalControlUnitTimedProgram
		\see ThermalControlUnitOff
		\see ThermalControlUnitAntifreeze
		\see ThermalControlUnitManual
		\see ThermalControlUnitTimedManual
		\see ThermalControlUnitScenario

	*/
	Q_PROPERTY(ObjectDataModel *modalities READ getModalities NOTIFY modalitiesChanged)

	/*!
		\brief The list of \ref ThermalRegulationProgram configured for the control unit
	*/
	Q_PROPERTY(ObjectDataModel *programs READ getPrograms NOTIFY programsChanged)

	/*!
		\brief A \ref ThermalControlUnitObject subclass representing the current modality

		\see ThermalControlUnitObject
		\see ThermalControlUnitProgram
		\see ThermalControlUnitTimedProgram
		\see ThermalControlUnitOff
		\see ThermalControlUnitAntifreeze
		\see ThermalControlUnitManual
		\see ThermalControlUnitTimedManual
		\see ThermalControlUnitScenario
	*/
	Q_PROPERTY(QObject *currentModality READ getCurrentModality NOTIFY currentModalityChanged)

	/*!
		\brief The \ref ThermalControlUnitId corresponding to the \ref currentModality
	*/
	Q_PROPERTY(ThermalControlUnitId currentModalityId READ getCurrentModalityId NOTIFY currentModalityIdChanged)

public:
	enum ThermalControlUnitId
	{
		IdHoliday,
		IdOff,
		IdAntifreeze,
		IdManual,
		IdTimedManual,
		IdWeeklyPrograms,
		IdWeekday,
		IdScenarios
	};

	enum SeasonType
	{
		Summer,
		Winter
	};

	ThermalControlUnit(QString name, QString key, ThermalDevice *d);

	virtual QString getObjectKey() const;

	SeasonType getSeason() const;
	void setSeason(SeasonType s);

	ObjectDataModel *getModalities() const;
	ObjectDataModel *getPrograms() const;

	QObject* getCurrentModality() const;
	ThermalControlUnitId getCurrentModalityId() const;

signals:
	void seasonChanged();
	void modalitiesChanged();
	void programsChanged();
	void currentModalityChanged();
	void currentModalityIdChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	ObjectDataModel modalities;

private:
	QString key;
	int temperature;
	SeasonType season;
	ObjectDataModel programs;
	ThermalDevice *dev;
	int current_modality_index;
};


/*!
	\ingroup ThermalRegulation
	\brief Manages a 4 zones control unit

	The object id is \a ObjectInterface::IdThermalControlUnit4
*/
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


/*!
	\ingroup ThermalRegulation
	\brief Manages a 99 zones control unit

	The object id is \a ObjectInterface::IdThermalControlUnit99
*/
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

	ObjectDataModel *getScenarios() const;

private:
	ThermalDevice99Zones *dev;
	ObjectDataModel scenarios;
};


/*!
	\ingroup ThermalRegulation
	\brief Base class for thermal control unit modality objects

	The objects contain two states: the current state for the modality (read
	from the device) and the editing state (used when the user sets new parameters
	before applying the modality to the control unit).

	The properties only alter the editing state of the object; the state is applied
	to the device when calling \ref apply().

	\see ThermalControlUnitProgram
	\see ThermalControlUnitTimedProgram
	\see ThermalControlUnitOff
	\see ThermalControlUnitAntifreeze
	\see ThermalControlUnitManual
	\see ThermalControlUnitTimedManual
	\see ThermalControlUnitScenario
*/
class ThermalControlUnitObject : public ObjectInterface
{
	friend class TestThermalControlUnitObject;

	Q_OBJECT

public:
	ThermalControlUnitObject(QString name, ThermalDevice *dev);

public slots:
	/*!
		\brief Apply the modality to the control unit

		Switches the control unit to the new modality using the parameters
		contained in the editing state and sets current state to the editing state.
	*/
	virtual void apply() = 0;

	/*!
		\brief Reset the editing state to the device state
	*/
	virtual void reset();

protected:
	ThermalRegulationState current, to_apply;

protected:
	ThermalDevice *dev;
};


/*!
	\ingroup ThermalRegulation
	\brief Switch to preset program mode

	The object id is \a ThermalControlUnit::IdWeeklyPrograms.
*/
class ThermalControlUnitProgram : public ThermalControlUnitObject
{
	friend class TestThermalControlUnitProgram;

	Q_OBJECT

	/*!
		\brief Sets and gets the program index
	*/
	Q_PROPERTY(int programIndex READ getProgramIndex WRITE setProgramIndex NOTIFY programChanged)

	/*!
		\brief Gets the description for the current program
	*/
	Q_PROPERTY(QString programDescription READ getProgramDescription NOTIFY programChanged)

	/*!
		\brief The list of \ref ThermalRegulationProgram configured for the control unit
	*/
	Q_PROPERTY(ObjectDataModel *programs READ getPrograms CONSTANT)

public:
	ThermalControlUnitProgram(QString name, int object_id, const ObjectDataModel *_programs, ThermalDevice *dev);

	virtual int getObjectId() const
	{
		return object_id;
	}

	int getProgramIndex() const;
	void setProgramIndex(int index);

	int getProgramId() const;
	QString getProgramDescription() const;
	ObjectDataModel *getPrograms() const;

public slots:
	virtual void apply();

signals:
	void programChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	const ObjectDataModel *programs;
	int object_id;
};


/*!
	\ingroup ThermalRegulation
	\brief Switch to holiday or weekday mode.

	The object id is either ThermalControlUnit::IdHoliday or ThermalControlUnit::IdWeekday

	In holiday mode, run the given program until the specified date/time, then switch to the
	specified weekly program.

	In weekday mode, go to antifreeze mode until the specified date/time, then switch to the specified program.
*/
class ThermalControlUnitTimedProgram : public ThermalControlUnitProgram
{
	Q_OBJECT

	/*!
		\brief Sets and gets hour in holiday or weekend timed program
	*/
	Q_PROPERTY(int hours READ getHours WRITE setHours NOTIFY hoursChanged)
	/*!
		\brief Sets and gets minute in holiday or weekend timed program
	*/
	Q_PROPERTY(int minutes READ getMinutes WRITE setMinutes NOTIFY minutesChanged)
	/*!
		\brief Sets and gets second in holiday or weekend timed program
	*/
	Q_PROPERTY(int seconds READ getSeconds WRITE setSeconds NOTIFY secondsChanged)
	/*!
		\brief Sets and gets day in holiday or weekend timed program
	*/
	Q_PROPERTY(int days READ getDays WRITE setDays NOTIFY daysChanged)
	/*!
		\brief Sets and gets month in holiday or weekend timed program
	*/
	Q_PROPERTY(int months READ getMonths WRITE setMonths NOTIFY monthsChanged)
	/*!
		\brief Sets and gets year in holiday or weekend timed program
	*/
	Q_PROPERTY(int years READ getYears WRITE setYears NOTIFY yearsChanged)

public:
	ThermalControlUnitTimedProgram(QString name, int object_id, ObjectDataModel *programs, ThermalDevice *dev);

	int getHours() const;
	void setHours(int newValue);
	int getMinutes() const;
	void setMinutes(int newValue);
	int getSeconds() const;
	void setSeconds(int newValue);
	int getDays() const;
	void setDays(int newValue);
	int getMonths() const;
	void setMonths(int newValue);
	int getYears() const;
	void setYears(int newValue);

public slots:
	virtual void apply();

signals:
	void hoursChanged();
	void minutesChanged();
	void secondsChanged();
	void daysChanged();
	void monthsChanged();
	void yearsChanged();

private:
	void emitDateSignals(QDate oldDate, QDate newDate);
	void emitTimeSignals(QTime oldTime, QTime newTime);
};


/*!
	\ingroup ThermalRegulation
	\brief Turn off the control unit

	The object id is ThermalControlUnit::IdOff.
*/
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


/*!
	\ingroup ThermalRegulation
	\brief Switch to anti-freeze mode.

	The object id is ThermalControlUnit::IdAntifreeze.
*/
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


/*!
	\ingroup ThermalRegulation
	\brief Switch to manual mode.

	The object id is ThermalControlUnit::IdManual.
*/
class ThermalControlUnitManual : public ThermalControlUnitObject
{
	friend class TestThermalControlUnitManual;

	Q_OBJECT

	/*!
		\brief Sets and gets the temperature to use in the program (in Celsius degrees * 10)
	*/
	Q_PROPERTY(int temperature READ getTemperature WRITE setTemperature NOTIFY temperatureChanged)

	/*!
		\brief Gets the mimimum allowed temperature for manual mode (in Celsius degrees * 10)
	*/
	Q_PROPERTY(int minimumManualTemperature READ getMinimumManualTemperature CONSTANT)

	/*!
		\brief Gets the maximum allowed temperature for manual mode (in Celsius degrees * 10)
	*/
	Q_PROPERTY(int maximumManualTemperature READ getMaximumManualTemperature CONSTANT)

public:
	ThermalControlUnitManual(QString name, ThermalDevice *dev);

	virtual int getObjectId() const
	{
		return ThermalControlUnit::IdManual;
	}

	int getTemperature() const;
	void setTemperature(int temp);

	int getMinimumManualTemperature() const;
	int getMaximumManualTemperature() const;

public slots:
	virtual void apply();

signals:
	void temperatureChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);
};


/*!
	\ingroup ThermalRegulation
	\brief Switch to manual mode for up to 24 hours

	The object id is ThermalControlUnit::IdTimedManual.
*/
class ThermalControlUnitTimedManual : public ThermalControlUnitManual
{
	friend class TestThermalControlUnitTimedManual;

	Q_OBJECT

	/*!
		\brief Sets and gets hour for timed program
	*/
	Q_PROPERTY(int hours READ getHours WRITE setHours NOTIFY hoursChanged)
	/*!
		\brief Sets and gets minute for timed program
	*/
	Q_PROPERTY(int minutes READ getMinutes WRITE setMinutes NOTIFY minutesChanged)
	/*!
		\brief Sets and gets second for timed program
	*/
	Q_PROPERTY(int seconds READ getSeconds WRITE setSeconds NOTIFY secondsChanged)

public:
	ThermalControlUnitTimedManual(QString name, ThermalDevice4Zones *dev);

	virtual int getObjectId() const
	{
		return ThermalControlUnit::IdTimedManual;
	}

	int getHours() const;
	void setHours(int newValue);
	int getMinutes() const;
	void setMinutes(int newValue);
	int getSeconds() const;
	void setSeconds(int newValue);

public slots:
	virtual void apply();

signals:
	void hoursChanged();
	void minutesChanged();
	void secondsChanged();

private:
	void emitTimeSignals(QTime oldTime, QTime newTime);

	ThermalDevice4Zones *dev;
};


/*!
	\ingroup ThermalRegulation
	\brief Switch to preset scenario mode

	The object id is \a ThermalControlUnit::IdScenarios.
*/
class ThermalControlUnitScenario : public ThermalControlUnitObject
{
	friend class TestThermalControlUnitScenario;

	Q_OBJECT

	/*!
		\brief Sets and gets the scenario index
	*/
	Q_PROPERTY(int scenarioIndex READ getScenarioIndex WRITE setScenarioIndex NOTIFY scenarioChanged)

	/*!
		\brief Gets the description for the current scenario
	*/
	Q_PROPERTY(QString scenarioDescription READ getScenarioDescription NOTIFY scenarioChanged)

	/*!
		\brief The list of \ref ThermalRegulationProgram configured for the control unit
	*/
	Q_PROPERTY(ObjectDataModel *scenarios READ getScenarios CONSTANT)

public:
	ThermalControlUnitScenario(QString name, const ObjectDataModel *scenarios, ThermalDevice99Zones *dev);

	virtual int getObjectId() const
	{
		return ThermalControlUnit::IdScenarios;
	}

	int getScenarioIndex() const;
	void setScenarioIndex(int index);

	ObjectDataModel *getScenarios() const;

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
	const ObjectDataModel *scenarios;
};

#endif // THERMALOBJECTS_H
