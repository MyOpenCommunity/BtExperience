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

#ifndef ENERGIES_H
#define ENERGIES_H

#include "objectinterface.h"

#include <QObject>


class ObjectModel;
class EnergyData;


/*!
	\brief Collects and notifies data about energy thresholds and goals

	This class collects data about energy thresholds and goals. This
	information will be used to trigger popups when a threshold is exceeded or
	a goal is reached.

	The object id is \a ObjectInterface::IdEnergies.
*/
class EnergyThresholdsGoals : public ObjectInterface
{
	Q_OBJECT

public:
	EnergyThresholdsGoals();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdEnergies;
	}

signals:
	void thresholdChanged(EnergyData *energyDevice);
	void goalReached(EnergyData *energyDevice);
	void goalsEnabledChanged(int goals);

private slots:
	void energyThresholdChanged();
	void goalExceededChanged();
	void updateGoalsEnabled();

private:
	ObjectModel *energies_model;
	int goals_enabled;
};

#endif // ENERGIES_H
