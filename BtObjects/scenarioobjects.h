#ifndef SCENARIOOBJECTS_H
#define SCENARIOOBJECTS_H

/*!
	\defgroup Scenarios Scenarios
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues
#include "scenevodevicescond.h"

class ScenarioDevice;
class QDomNode;

QList<ObjectInterface *> createScenarioSystem(const QDomNode &xml_node, int id);
QList<ObjectPair> parseAdvancedScenario(const QDomNode &xml_node);


/*!
	\ingroup Scenarios
	\brief A pre-programmed scenario

	Allows starting the scenario
*/
class SimpleScenario : public ObjectInterface
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

public:
	ScheduledScenario(QString name, QString enable, QString start, QString stop, QString disable);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdScheduledScenario;
	}

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
};



class TimeConditionObject : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int hours READ getHours WRITE setHours NOTIFY hoursChanged)
	Q_PROPERTY(int minutes READ getMinutes WRITE setMinutes NOTIFY minutesChanged)

public:
	TimeConditionObject();

	void setHours(int h);
	int getHours() const;
	void setMinutes(int m);
	int getMinutes() const;

signals:
	void hoursChanged();
	void minutesChanged();

private:
	int hours, minutes;
};


class DeviceConditionObject : public QObject, DeviceConditionDisplayInterface
{
	Q_OBJECT
	Q_PROPERTY(QString description READ getDescription CONSTANT)
	Q_PROPERTY(QVariant onOff READ getOnOff WRITE setOnOff NOTIFY onOffChanged)
	Q_PROPERTY(QVariant range READ getRange NOTIFY rangeChanged)

public:
	DeviceConditionObject(DeviceCondition::Type type, QString description, QString trigger, QString where, PullMode pull_mode);
	QString getDescription() const;
	QVariant getOnOff() const;
	QVariant getRange() const;

	void setOnOff(QVariant value);

public slots:
	void conditionUp();
	void conditionDown();

signals:
	void onOffChanged();
	void rangeChanged();

protected:
	virtual void updateText(int min_condition_value, int max_condition_value);

private:
	bool on_off;
	QString range_description;
	QString description;
	DeviceCondition *device_cond;
	DeviceCondition::Type condition_type;
	DeviceCondition::ConditionState on_state;
};



class AdvancedScenario : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
	Q_PROPERTY(QObject *deviceCondition READ getDeviceCondition CONSTANT)
	Q_PROPERTY(QObject *timeCondition READ getTimeCondition CONSTANT)

public:
	AdvancedScenario(DeviceConditionObject *device, TimeConditionObject *time, bool enabled, int days, QString action_frame, QString action_description, QString description);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAdvancedScenario;
	}

	bool isEnabled() const;
	void setEnabled(bool enable);

	// 1-6 -> monday-saturday, 0 = 7 -> sunday, to work with both JavaScript and QDate
	bool isDayEnabled(int day);
	void setDayEnabled(int day, bool enabled);

	QObject *getDeviceCondition() const;
	QObject *getTimeCondition() const;

public slots:
	void start();

signals:
	void enabledChanged();
	void daysChanged();

private:
	bool enabled;
	int days;
	DeviceConditionObject *device_obj;
	TimeConditionObject *time_obj;
	QString action_frame;
	QString action_description;
};


#endif // SCENARIOOBJECTS_H
