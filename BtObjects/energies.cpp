#include "energies.h"
#include "objectmodel.h"
#include "energydata.h"

#include <QDebug>


EnergyThresholdsGoals::EnergyThresholdsGoals()
{
	// creates and ObjectModel and selects energy objects
	energies_model = new ObjectModel(this);
	energies_model->setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdEnergyData);

	// connects notifying signals to out updateThresholdsGoals slot
	for (int i = 0; i < energies_model->getCount(); ++i)
	{
		ItemInterface *item = energies_model->getObject(i);
		EnergyData *energyData = qobject_cast<EnergyData *>(item);
		Q_ASSERT_X(energyData, __PRETTY_FUNCTION__, "Unexpected NULL object");
		connect(energyData, SIGNAL(thresholdLevelChanged(int)), this, SLOT(updateThresholdsGoals()));
		connect(energyData, SIGNAL(goalExceededChanged()), this, SLOT(updateThresholdsGoals()));
	}

	// inits everything
	updateThresholdsGoals();
}

void EnergyThresholdsGoals::updateThresholdsGoals()
{
	for (int i = 0; i < energies_model->getCount(); ++i)
	{
		ItemInterface *item = energies_model->getObject(i);
		EnergyData *energyData = qobject_cast<EnergyData *>(item);
		Q_ASSERT_X(energyData, __PRETTY_FUNCTION__, "Unexpected NULL object");

		if (energyData->getThresholdLevel() > 0)
			emit thresholdExceeded(energyData);

		if (energyData->getGoalExceeded())
			emit goalReached(energyData);
	}
}
