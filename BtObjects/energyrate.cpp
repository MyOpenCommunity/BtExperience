#include "energyrate.h"


EnergyRate::EnergyRate(double _rate)
{
	rate = _rate;
}

void EnergyRate::setRate(double _rate)
{
	if (rate == _rate)
		return;
	rate = _rate;
	emit rateChanged();
}

double EnergyRate::getRate() const
{
	return rate;
}
