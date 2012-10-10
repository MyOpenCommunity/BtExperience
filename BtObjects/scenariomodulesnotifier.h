#ifndef SCENARIO_MODULES_NOTIFIER_H
#define SCENARIO_MODULES_NOTIFIER_H

#include "objectinterface.h"

#include <QObject>


class ObjectModel;
class ScenarioModule;


/*!
	\brief Collects and notifies data about scenario modules objects.

	This class collects data about scenario modules objects that are in recording
	(editing) state.

	The object id is \a ObjectInterface::IdScenarioModulesNotifier.
*/
class ScenarioModulesNotifier : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Is at least one scenario module in editing state?
	*/
	Q_PROPERTY(bool recording READ getRecording NOTIFY recordingChanged)

public:
	ScenarioModulesNotifier();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdScenarioModulesNotifier;
	}

	int getRecording() const { return is_recording; }

signals:
	void recordingChanged();
	void scenarioModuleChanged(ScenarioModule *scenario);

private slots:
	void updateRecordingInfo();

private:
	ObjectModel *scenario_modules_model;
	bool is_recording;
};

#endif // SCENARIO_MODULES_NOTIFIER_H
