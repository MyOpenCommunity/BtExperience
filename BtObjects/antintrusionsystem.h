#ifndef ANTINTRUSIONSYSTEM_H
#define ANTINTRUSIONSYSTEM_H

/*!
	\defgroup Antintrusion Anti-intrusion system

	In addition to monitoring intrusions, this system provides an anti-panic alarm
	and technical alarms throught an auxiliary input channel (for example for fire or flooding).

	There are up to 8 zones that can be monitored for intrusion and up to 16 auxiliary inputs for
	technical alarms.

	The user can partialize (disable) individual zones or activate a scenario (a predefined set
	of zones that will be enabled, partializing the rest).

	Every change to system status is protected by a password.

	The #AntintrusionSystem class is the single entry point for the whole system.

	After changing partialization state, either using AntintrusionZone::partialization or
	AntintrusionScenario::apply(), call AntintrusionSystem::requestPartialization() or
	AntintrusionSystem::toggleActivation() to apply the new state.

	Notification of new alarms goes through AntintrusionSystem::newAlarm() and the list of currently-active
	alarms can be retrieved using AntintrusionSystem::alarms.
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
		#AntintrusionSystem::requestPartialization() or #AntintrusionSystem::toggleActivation()
		to transmit the setting to the control unit.
	*/
	Q_PROPERTY(bool partialization READ getPartialization WRITE setGraphicPartialization NOTIFY partializationChanged)

	/*!
		\brief The device partialization state

		This is the state of the zone as received by the device. It cannot be changed by user
		but it can only be acquired from frames. Every time we receive a notification on zone
		status we have to reset the graphic state, too.
	  */
	Q_PROPERTY(bool devicePartialization READ getDevicePartialization NOTIFY deviceChanged)

public:
	AntintrusionZone(int id, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAntintrusionZone;
	}

	bool getPartialization() const;
	bool getDevicePartialization() const;
	void setGraphicPartialization(bool p);
	void setDevicePartialization(bool p);

signals:
	void partializationChanged(); // emitted when QML state changes
	void deviceChanged(); // emitted when device state changes
	void requestPartialization(int zone_number, bool partialize);

private:
	bool partialized_device; // the state on the device as read from frames
	bool partialized_graphic; // the state on QML
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

		%Note that this reflects the zone status in the program, and is not synchronized
		with the control unit unless #AntintrusionSystem::requestPartialization() or
		#AntintrusionSystem::toggleActivation() is called.
	*/
	Q_PROPERTY(bool selected READ isSelected NOTIFY selectionChanged)

	/// Description for the scenario
	Q_PROPERTY(QString description READ getDescription CONSTANT)

public:
	AntintrusionScenario(QString name, QList<int> scenario_zones, QList<AntintrusionZone*> zones);

	// return the description of the scenario, used by the omonymous role
	Q_INVOKABLE QString getDescription() const;

	/*!
		\brief Applies the scenario

		After applying the scenario, call #AntintrusionSystem::requestPartialization() or
		#AntintrusionSystem::toggleActivation() to transmit the setting to the control unit.
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

	Provides access to the alarm #type, the zone #number the alarm has been reported in
	and a description of the zone, if available.
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

		For alarms coming from a normal antintrusion zone (#Intrusion, some #Tamper alarms)
		this is the antintrusion zone number (1-8) and \c name is set to the zone name.

		For alarms coming from an auxiliary input (#Technical) this is the input id (1-16)
		and \c name is set to the description of the input.

		For alarms coming from a special zone (#Tamper) this is the special zone number
		(9-16) and \c name is empty.

		For #Antipanic alarms, this is the fixed value 9 and \c name is empty.
	*/
	Q_PROPERTY(int number READ getNumber CONSTANT)

	/*!
		\brief The source of the alarm

		Only set for #Technical, #Intrusion and #Tamper alarms coming from a normal
		antintrusion zone (1-8).
	*/
	Q_PROPERTY(ObjectInterface *source READ getSource CONSTANT)

	/*!
		\brief The time at which the alarm has been received by the UI
	*/
	Q_PROPERTY(QDateTime date_time READ getDateTime CONSTANT)

	Q_ENUMS(AlarmType)

public:
	/// Alarm type
	// Defined the same as AntintrusionDevice for convenience
	enum AlarmType
	{
		/// Anti-panic alarm
		Antipanic,
		/// Intrusion alarm
		Intrusion,
		/// Tampering
		Tamper,
		/// Technical alarm (from auxiliary input channel)
		Technical
	};

	AntintrusionAlarm(AlarmType type, const AntintrusionAlarmSource *source, int number, QDateTime time);

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

	Access global system configuration (list of zones and scenarios) and global system status (list of alarms,
	active/inactive system).
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

	/*!
		\brief Send when receiving a new alarm
	*/
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
	int zones_to_check;
	bool code_right;
};


#endif // ANTINTRUSIONSYSTEM_H
