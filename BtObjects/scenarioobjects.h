#ifndef SCENARIOOBJECTS_H
#define SCENARIOOBJECTS_H

/*!
	\defgroup Scenarios Scenarios
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues, RawDevice
#include "scenevodevicescond.h"

class ScenarioDevice;
class QDomNode;
class AdvancedScenario;

QList<ObjectPair> parseScenarioUnit(const QDomNode &xml_node);
QList<ObjectPair> parseScenarioModule(const QDomNode &xml_node);
QList<ObjectPair> parseScheduledScenario(const QDomNode &xml_node);
QList<ObjectPair> parseAdvancedScenario(const QDomNode &xml_node);

void updateAdvancedScenario(QDomNode node, AdvancedScenario *item);


/*!
	\ingroup Scenarios
	\brief A pre-programmed scenario

	Allows starting the scenario
*/
class SimpleScenario : public DeviceObjectInterface
{
	Q_OBJECT

public:
	SimpleScenario(int scenario, QString _name, ScenarioDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSimpleScenario;
	}

public slots:
	/*!
		\brief Activate the scenario
	*/
	void activate();

protected:
	int scenario_number;
	ScenarioDevice *dev;
};


/*!
	\ingroup Scenarios
	\brief A programmable scenario

	Allows programming a new set of events for the scenario.  Call \ref startProgramming()
	to enter edit mode and \ref stopProgramming() when finished.
*/
class ScenarioModule : public SimpleScenario
{
friend class TestScenarioModule;
	Q_OBJECT

	/*!
		\brief The status of this scenario
	*/
	Q_PROPERTY(Status status READ getStatus NOTIFY statusChanged)

	Q_ENUMS(Status)

public:
	ScenarioModule(int scenario, QString _name, ScenarioDevice *d);

	/// Status of this scenario
	enum Status
	{
		/// The scenario module is locked
		Locked = 1,
		/// The scenario module is not locked and this scenario is not in edit mode
		Unlocked,
		/// The scenario module is not locked and this scenario is in edit mode
		Editing
	};

	virtual int getObjectId() const
	{
		return ObjectInterface::IdScenarioModule;
	}

	Status getStatus();

public slots:
	/*!
		\brief Put the scenario in edit mode
	*/
	void startProgramming();

	/*!
		\brief Complete scenario editing
	*/
	void stopProgramming();

	/*!
		\brief Delete all the commands stored for this scenario
	*/
	void deleteScenario();

signals:
	void statusChanged();

private slots:
	void valueReceived(const DeviceValues &values_list);

private:
	void changeStatus(Status new_status);
	Status status;
};



/*!
	\ingroup Scenarios
	\brief A scheduled scenario

	The scheduled scenario automatically activates a number of controls at the
	occurrence of one or more specific actions or at a pre-set time.
	Call \ref enable() or \ref disable() to active or deactive the scenario, and
	\ref start() - \ref stop() to force start (or stop) a scenario regardless of
	the programmed condition.
*/
class ScheduledScenario : public ObjectInterface
{
	Q_OBJECT

	Q_PROPERTY(bool hasStart READ hasStart CONSTANT)
	Q_PROPERTY(bool hasStop READ hasStop CONSTANT)
	Q_PROPERTY(bool hasEnable READ hasEnable CONSTANT)
	Q_PROPERTY(bool hasDisable READ hasDisable CONSTANT)

public:
	ScheduledScenario(QString name, QString enable, QString start, QString stop, QString disable);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdScheduledScenario;
	}

	bool hasStart() const;
	bool hasStop() const;
	bool hasEnable() const;
	bool hasDisable() const;

public slots:
	/*!
		\brief Start the scenario
	*/
	void start();

	/*!
		\brief Stop the scenario
	*/
	void stop();

	/*!
		\brief Enable the scenario
	*/
	void enable();

	/*!
		\brief Disable the scenario
	*/
	void disable();

protected:
	QString enable_frame, start_frame, stop_frame, disable_frame;
	RawDevice *dev;
};


class ActionObject : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString target READ getTarget CONSTANT)
	Q_PROPERTY(QString description READ getDescription CONSTANT)

public:
	enum Type
	{
		ActionLight = 1,
		ActionDimmer,
		ActionTimedLights,
		ActionDimmer100,
		ActionShutter = 5,
		ActionCurtain,
		ActionAutomationGate,
		ActionLightinGate,
		ActionVideoDoorEntryGate,
		ActionTilting = 10,
		ActionFan,
		ActionWatering,
		ActionControlledSocket,
		ActionAutomationDoorLock,
		ActionVideoDoorEntryLock = 15,
		ActionScenarioUnit,
		ActionScenarioModule,
		ActionControlUnit3550,
		ActionZone3550,
		ActionAmplifier = 20,
		ActionControlUnit4695,
		ActionZone3550Fan,
		ActionCen,
		ActionCenPlus,
		ActionScenarioPlus = 25,
		ActionAux
	};


	ActionObject(QString target, QString frame, Type type, int command_id);

	void sendFrame();

	QString getTarget() const;
	QString getDescription() const;

private:
	void buildDescriptionMap();

	QString frame;
	QString target;
	RawDevice *dev;
	Type type;
	int command_id;
	QHash<int, QString> id_to_descr;
};


class TimeConditionObject : public QObject
{
	friend class TestScenarioAdvanced;
	friend class TestScenarioAdvancedTime;

	Q_OBJECT
	Q_PROPERTY(int hours READ getHours WRITE setHours NOTIFY hoursChanged)
	Q_PROPERTY(int minutes READ getMinutes WRITE setMinutes NOTIFY minutesChanged)

public:
	TimeConditionObject(int hours, int minutes);

	void setHours(int h);
	int getHours() const;
	void setMinutes(int m);
	int getMinutes() const;

	void save();
	void reset();

signals:
	void hoursChanged();
	void minutesChanged();
	void satisfied();

private slots:
	void resetTimer();

private:
	int hours, minutes;
	int condition_hours, condition_minutes;
	QTimer timer;
};


class DeviceConditionObject : public QObject, DeviceConditionDisplayInterface
{
	friend class TestScenarioAdvanced;
	friend class TestScenarioAdvancedDeviceEdit;

	Q_OBJECT
	Q_PROPERTY(Type type READ getConditionType CONSTANT)
	Q_PROPERTY(QString description READ getDescription CONSTANT)
	Q_PROPERTY(QVariant onOff READ getOnOff WRITE setOnOff NOTIFY onOffChanged)
	Q_PROPERTY(QVariantList rangeValues READ getRangeValues NOTIFY rangeChanged)
	Q_ENUMS(Type)


public:
	DeviceConditionObject(DeviceCondition::Type type, QString description, QString trigger, QString where, PullMode pull_mode);

	// We don't want to expose the 'original' condition type to the qml side because
	// we want the freedom of changing the implementation without breaking qml.
	enum Type
	{
		Light = DeviceCondition::LIGHT,
		Dimming = DeviceCondition::DIMMING,
		ExternalProbe = DeviceCondition::EXTERNAL_PROBE,
		Probe = DeviceCondition::PROBE,
		Temperature = DeviceCondition::TEMPERATURE,
		Aux = DeviceCondition::AUX,
		Amplifier = DeviceCondition::AMPLIFIER,
		Dimming100 = DeviceCondition::DIMMING100
	};

	Type getConditionType() const;
	QString getDescription() const;
	QVariant getOnOff() const;
	QVariantList getRangeValues() const;

	void setOnOff(QVariant value);

	bool isSatisfied() const;

	void save();
	void reset();

	// only used for configuration saving
	QString getTriggerAsString() const;

	void enableObject();

public slots:
	void conditionUp();
	void conditionDown();

signals:
	void onOffChanged();
	void rangeChanged();
	void satisfied();

protected:
	virtual void updateText(int min_condition_value, int max_condition_value);

private:
	bool on_off;
	QString description;
	QVariantList range_values;
	DeviceCondition *device_cond;
	DeviceCondition::Type condition_type;
	DeviceCondition::ConditionState on_state;
};



class AdvancedScenario : public ObjectInterface
{
	friend class TestScenarioAdvanced;

	Q_OBJECT
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
	Q_PROPERTY(QObject *deviceCondition READ getDeviceCondition CONSTANT)
	Q_PROPERTY(QObject *timeCondition READ getTimeCondition CONSTANT)
	Q_PROPERTY(QObject *action READ getAction CONSTANT)

public:
	AdvancedScenario(DeviceConditionObject *device, TimeConditionObject *time, ActionObject *action, bool _enabled, int _days, QString description);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAdvancedScenario;
	}

	bool isEnabled() const;
	void setEnabled(bool enable);

	QObject *getDeviceCondition() const;
	QObject *getTimeCondition() const;
	QObject *getAction() const;

	virtual void enableObject();

	// only used for configuration saving
	int getDays() const;

public slots:
	void start();
	void save();
	void reset();

	// 1-6 -> monday-saturday, 0 = 7 -> sunday, to work with both JavaScript and QDate
	bool isDayEnabled(int day) const;
	void setDayEnabled(int day, bool enabled);

signals:
	void enabledChanged();
	void daysChanged();
	void started();

private slots:
	void timeConditionSatisfied();
	void deviceConditionSatisfied();

private:
	bool enabled;
	int days;
	DeviceConditionObject *device_obj;
	TimeConditionObject *time_obj;
	ActionObject *action_obj;
};


#endif // SCENARIOOBJECTS_H
