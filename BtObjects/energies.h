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
	void thresholdExceeded(EnergyData *energyDevice);
	void goalReached(EnergyData *energyDevice);
	void goalsEnabledChanged(int goals);

private slots:
	void updateThresholdsGoals();
	void updateGoalsEnabled();

private:
	ObjectModel *energies_model;
	int goals_enabled;
};

#endif // ENERGIES_H
