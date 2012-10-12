#include "scenariomodulesnotifier.h"
#include "objectmodel.h"
#include "scenarioobjects.h"

#include <QDebug>


ScenarioModulesNotifier::ScenarioModulesNotifier()
{
	is_recording = false;

	// creates an ObjectModel to select scenario modules objects
	scenario_modules_model = new ObjectModel(this);
	QVariantList filters;
	QVariantMap filter;

	// sets filters to select scenario modules objects
	filter["objectId"] = ObjectInterface::IdScenarioModule;
	filters << filter;
	filter.clear();

	// filters
	scenario_modules_model->setFilters(filters);

	// connects statusChanged signal of scenario modules objects to our updateRecordingInfo
	// signal
	for(int i = 0; i < scenario_modules_model->getCount(); ++i)
	{
		ItemInterface *item = scenario_modules_model->getObject(i);
		ScenarioModule *scenarioModule = qobject_cast<ScenarioModule *>(item);
		Q_ASSERT_X(scenarioModule, __PRETTY_FUNCTION__, "Unexpected NULL object");
		connect(scenarioModule, SIGNAL(statusChanged(ScenarioModule *)), this, SLOT(updateRecordingInfo()));
		connect(scenarioModule, SIGNAL(statusChanged(ScenarioModule *)), this, SIGNAL(scenarioModuleChanged(ScenarioModule *)));
	}

	// creates an ObjectModel to select all scenarios
	scenarios_model = new ObjectModel(this);

	// sets filters to select advanced scenario objects
	filters.clear();
	filter["objectId"] = ObjectInterface::IdAdvancedScenario;
	filters << filter;
	filter.clear();

	scenarios_model->setFilters(filters);

	for(int i = 0; i < scenarios_model->getCount(); ++i)
	{
		ItemInterface *item = scenarios_model->getObject(i);
		AdvancedScenario *scenario = qobject_cast<AdvancedScenario *>(item);
		Q_ASSERT_X(scenario, __PRETTY_FUNCTION__, "Unexpected NULL object");
		connect(scenario, SIGNAL(started(QString)), this, SIGNAL(scenarioActivated(QString)));
	}

	// inits everything
	updateRecordingInfo();
}

void ScenarioModulesNotifier::updateRecordingInfo()
{
	bool is_one_recording = false;

	// cycles over all scenario module objects and computes if at least one is recording
	for(int i = 0; i < scenario_modules_model->getCount(); ++i)
	{
		ItemInterface *item = scenario_modules_model->getObject(i);
		ScenarioModule *scenarioModule = qobject_cast<ScenarioModule *>(item);

		Q_ASSERT_X(scenarioModule, __PRETTY_FUNCTION__, "Unexpected NULL object");

		ScenarioModule::Status st = scenarioModule->getStatus();
		if (st == ScenarioModule::Editing)
		{
			is_one_recording = true;
			break;
		}
	}

	if (is_one_recording != is_recording)
	{
		is_recording = is_one_recording;
		emit recordingChanged();
	}
}
