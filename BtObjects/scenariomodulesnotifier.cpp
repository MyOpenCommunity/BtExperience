/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#include "scenariomodulesnotifier.h"
#include "objectmodel.h"
#include "scenarioobjects.h"

#include <QDebug>


ScenarioModulesNotifier::ScenarioModulesNotifier()
{
	is_recording = false;
	recorder = 0;

	// creates an ObjectModel to select scenario modules objects
	scenario_modules_model = new ObjectModel(this);
	scenario_modules_model->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdScenarioModule);

	// connects statusChanged signal of scenario modules objects to our updateRecordingInfo
	// signal
	for(int i = 0; i < scenario_modules_model->getCount(); ++i)
	{
		ItemInterface *item = scenario_modules_model->getObject(i);
		ScenarioModule *scenarioModule = qobject_cast<ScenarioModule *>(item);
		Q_ASSERT_X(scenarioModule, __PRETTY_FUNCTION__, "Unexpected NULL object");
		connect(scenarioModule, SIGNAL(statusChanged(ScenarioModule *)), this, SLOT(updateRecordingInfo()));
		connect(scenarioModule, SIGNAL(statusChanged(ScenarioModule *)), this, SIGNAL(scenarioModuleChanged(ScenarioModule *)));
		connect(scenarioModule, SIGNAL(programmingStopped(ScenarioModule*)), this, SIGNAL(scenarioProgrammingStopped(ScenarioModule*)));
	}

	// creates an ObjectModel to select all scenarios
	scenarios_model = new ObjectModel(this);
	scenarios_model->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdAdvancedScenario
								<< ObjectModelFilters() << "objectId" << ObjectInterface::IdScheduledScenario);

	for(int i = 0; i < scenarios_model->getCount(); ++i)
	{
		ItemInterface *item = scenarios_model->getObject(i);
		AdvancedScenario *scenario = qobject_cast<AdvancedScenario *>(item);
		ScheduledScenario *sched_scenario = qobject_cast<ScheduledScenario *>(item);
		if (scenario)
		{
			connect(scenario, SIGNAL(started(QString)), this, SIGNAL(commandSent(QString)));
		}
		else if (sched_scenario)
		{
			connect(sched_scenario, SIGNAL(started(QString)), this, SIGNAL(commandSent(QString)));
			connect(sched_scenario, SIGNAL(stopped(QString)), this, SIGNAL(commandSent(QString)));
			connect(sched_scenario, SIGNAL(enabled(QString)), this, SIGNAL(commandSent(QString)));
			connect(sched_scenario, SIGNAL(disabled(QString)), this, SIGNAL(commandSent(QString)));
		}
		else
		{
			Q_ASSERT_X(false, __PRETTY_FUNCTION__, "Unexpected NULL object");
		}
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
			if (recorder != scenarioModule)
			{
				recorder = scenarioModule;
				emit recorderChanged();
			}
			break;
		}
	}

	if (is_one_recording != is_recording)
	{
		is_recording = is_one_recording;
		emit recordingChanged();
	}

	if (!is_one_recording && recorder)
	{
		recorder = 0;
		emit recorderChanged();
	}
}
