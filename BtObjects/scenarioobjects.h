#ifndef SCENARIOOBJECTS_H
#define SCENARIOOBJECTS_H

/*!
	\defgroup Scenarios Scenarios
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues

class ScenarioDevice;
class QDomNode;

QList<ObjectInterface *> createScenarioSystem(const QDomNode &xml_node, int id);


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


class AdvancedScenario : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(bool enabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

public:
	AdvancedScenario();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAdvancedScenario;
	}

	bool isEnabled() const;
	void setEnabled(bool enable);

public slots:
	void start();

signals:
	void enabledChanged();

private:
	bool enabled;
};


#endif // SCENARIOOBJECTS_H
