#ifndef ANTINTRUSIONSYSTEM_H
#define ANTINTRUSIONSYSTEM_H

/*!
	\defgroup Antintrusion Anti-intrusion system
*/

#include "objectinterface.h"
#include "objectmodel.h"
#include "device.h" // DeviceValues

#include <QString>
#include <QDateTime>

class AntintrusionSystem;
class AntintrusionDevice;
class AntintrusionZone;
class AntintrusionAlarmSource;
class AntintrusionScenario;
class ObjectDataModel;
class QDomNode;


QList<ObjectPair> parseAntintrusionZone(const QDomNode &obj);
QList<ObjectPair> parseAntintrusionAux(const QDomNode &obj);
QList<ObjectPair> parseAntintrusionScenario(const QDomNode &obj, const UiiMapper &uii_map, QList<AntintrusionZone *> zones);

AntintrusionSystem *createAntintrusionSystem(QList<AntintrusionZone *> zones, QList<AntintrusionAlarmSource *> aux, QList<AntintrusionScenario *> scenarios);


/*!
	\ingroup Antintrusion
	\brief The source for an alarm (either a zone or an aux input)

	The \c name property holds the zone/aux description (if any)
*/
class AntintrusionAlarmSource : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief The zone or aux number.

		Can be 1-8 for configured zones, 9-16 for special zones and 1-16 for aux inputs.
	*/
	Q_PROPERTY(int number READ getNumber CONSTANT)

public:
	AntintrusionAlarmSource(int number, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAntintrusionAux;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	int getNumber() const;

private:
	int number;
};


/*!
	\ingroup Antintrusion
	\brief An antintrusion zone

	In addition to the properties for a generic alarm source, antintrusion zones can be
	partialized (alarms will not be triggered/reported for partialized zones).
*/
class AntintrusionZone : public AntintrusionAlarmSource
{
	Q_OBJECT

	/*!
		\brief When a zone is partialized the system does not report alarms for this zone

		After setting desired zone status on all antintrusion zones, call
		\a requestPartialization() or \a toggleActivation() to transmit the setting to the control unit.
	*/
	Q_PROPERTY(bool partialization READ getPartialization WRITE setPartialization NOTIFY partializationChanged)

public:
	AntintrusionZone(int id, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAntintrusionZone;
	}

	bool getPartialization() const;
	void setPartialization(bool p, bool request_partialization = true);

signals:
	void partializationChanged();
	void requestPartialization(int zone_number, bool partialize);

private:
	bool partialized;
};


/*!
	\ingroup Antintrusion
	\brief A set of antintrusion zones that can be enabled together
*/
class AntintrusionScenario : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Whether this scenario is active

		This property becomes \c true when all the zones in this scenario are active
		(not partialized).

		Note that this reflects the zone status in the program, and is not synchronized
		with the control unit unless \a requestPartialization() or \a toggleActivation()
		is called.
	*/
	Q_PROPERTY(bool selected READ isSelected NOTIFY selectionChanged)

	/// Description for the scenario
	Q_PROPERTY(QString description READ getDescription CONSTANT)

public:
	AntintrusionScenario(QString name, QList<int> scenario_zones, QList<AntintrusionZone*> zones);

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	// return the description of the scenario, used by the omonymous role
	Q_INVOKABLE QString getDescription() const;

	/*!
		\brief Applies the scenario

		After applying the scenario, call \a requestPartialization() or
		\a toggleActivation() to transmit the setting to the control unit.
	*/
	Q_INVOKABLE void apply();

	// check if the scenario is selected
	bool isSelected() const;

signals:
	void selectionChanged();

private slots:
	void verifySelection(bool notify = true);

private:
	QList<int> scenario_zones;
	QList<AntintrusionZone*> zones;
	bool selected;
};


/*!
	\ingroup Antintrusion
	\brief A single antintrusion alarm
*/
class AntintrusionAlarm : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief The alarm type

		\sa AlarmType
	*/
	Q_PROPERTY(AlarmType type READ getType CONSTANT)

	/*!
		\brief Alarm source id

		For alarms coming from a normal antintrusion zone (\c Intrusion, some \c Tampering alarms)
		this is the antintrusion zone number (1-8) and \c name is set to the zone name.

		For alarms coming from an auxiliary input (\c Technical) this is the input id (1-16)
		and \c name is set to the description of the input.

		For alarms coming from a special zone (\c Tampering) this is the special zone number
		(9-16) and \c name is empty.

		For \c Antipanic alarms, this is the fixed value 9 and \c name is empty.
	*/
	Q_PROPERTY(int number READ getNumber CONSTANT)

	/*!
		\brief The source of the alarm

		Only set for \c Technical, \c Intrusion and \c Tamper alarms coming from a normal
		antintrusion zone (1-8).
	*/
	Q_PROPERTY(ObjectInterface *source READ getSource CONSTANT)

	/*!
		\brief The time at which the alarm has been received by the UI
	*/
	Q_PROPERTY(QDateTime date_time READ getDateTime CONSTANT)

	Q_ENUMS(AlarmType)

public:
	// Defined the same as AntintrusionDevice for convenience
	enum AlarmType
	{
		Antipanic,
		Intrusion,
		Tamper,
		Technical,
	};

	AntintrusionAlarm(AlarmType type, const AntintrusionAlarmSource *source, int number, QDateTime time);

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	AlarmType getType();
	ObjectInterface *getSource();
	QDateTime getDateTime();

	int getNumber() const;
	virtual QString getName() const;

private:
	const AntintrusionAlarmSource *source;
	AlarmType type;
	int number;
	QDateTime date_time;
};


/*!
	\ingroup Antintrusion
	\brief Antintrusion control unit object
*/
class AntintrusionSystem : public ObjectInterface
{
friend class TestAntintrusionSystem;

	Q_OBJECT

	/// List of configured zones (contains \c AntintrusionZone objects)
	Q_PROPERTY(ObjectDataModel *zones READ getZones CONSTANT)

	/// List of configured scenarios (contains \c AntintrusionScenario objects)
	Q_PROPERTY(ObjectDataModel *scenarios READ getScenarios CONSTANT)

	/// List of active alarms (contains \c AntintrusionAlarm objects)
	Q_PROPERTY(ObjectDataModel *alarms READ getAlarms NOTIFY alarmsChanged)

	/// Returns \c true when the antintrusion system is active
	Q_PROPERTY(bool status READ getStatus NOTIFY statusChanged)

	/// The currently-selected antintrusion scenario
	Q_PROPERTY(QObject *currentScenario READ getCurrentScenario NOTIFY currentScenarioChanged)

public:
	AntintrusionSystem(AntintrusionDevice *d, QList<AntintrusionScenario*> _scenarios, QList<AntintrusionAlarmSource *> _aux, QList<AntintrusionZone*> _zones);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAntintrusionSystem;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	ObjectDataModel *getZones() const;
	ObjectDataModel *getScenarios() const;
	ObjectDataModel *getAlarms() const;

	/*!
		\brief Apply the current partialization state to the control unit

		Only call it when the antintrusion system is active, otherwise call
		\a toggleActivation() that activates the system and sets the partialization.
	*/
	Q_INVOKABLE void requestPartialization(const QString &password);

	/*!
		\brief Toggle activation status for the system

		When activating the system, it also sets the current partialization status
	*/
	Q_INVOKABLE void toggleActivation(const QString &password);

	bool getStatus() const
	{
		return status;
	}

	QObject *getCurrentScenario() const;

signals:
	void alarmsChanged();
	void newAlarm(AntintrusionAlarm *alarm);

	void statusChanged();
	void currentScenarioChanged();

	void codeAccepted();
	void codeRefused();
	void codeTimeout();

private slots:
	virtual void valueReceived(const DeviceValues &values_list);
	void handleCodeTimeout();

private:
	void addAlarm(AntintrusionAlarm::AlarmType t, int zone_num);
	void removeAlarm(AntintrusionAlarm::AlarmType t, int zone_num);
	bool isDuplicateAlarm(AntintrusionAlarm::AlarmType t, int zone_num);
	AntintrusionDevice *dev;
	ObjectDataModel zones;
	ObjectDataModel aux;
	ObjectDataModel scenarios;
	ObjectDataModel alarms;
	bool status;
	bool initialized;
	bool waiting_response;
	int current_scenario;
};


#endif // ANTINTRUSIONSYSTEM_H
