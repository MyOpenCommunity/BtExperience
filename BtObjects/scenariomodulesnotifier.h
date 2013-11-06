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

	/*!
		\brief The only one possible scenario object in recording state if any
	*/
	Q_PROPERTY(ScenarioModule *recorder READ getRecorder NOTIFY recorderChanged)

public:
	ScenarioModulesNotifier();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdScenarioModulesNotifier;
	}

	int getRecording() const { return is_recording; }
	ScenarioModule *getRecorder() const { return recorder; }

signals:
	void recorderChanged();
	void recordingChanged();
	void scenarioModuleChanged(ScenarioModule *scenario);
	void commandSent(QString description);
	void scenarioProgrammingStopped(ScenarioModule *scenario);

private slots:
	void updateRecordingInfo();

private:
	ObjectModel *scenario_modules_model, *scenarios_model;
	bool is_recording;
	ScenarioModule *recorder;
};

#endif // SCENARIO_MODULES_NOTIFIER_H
