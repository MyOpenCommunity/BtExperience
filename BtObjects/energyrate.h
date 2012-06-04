#ifndef ENERGYRATE_H
#define ENERGYRATE_H

#include "objectinterface.h"


// TODO add other fields
class EnergyRate : public ObjectInterface
{
	Q_OBJECT

	Q_PROPERTY(double rate READ getRate WRITE setRate NOTIFY rateChanged)

public:
	EnergyRate(double rate);

	void setRate(double rate);
	double getRate() const;

signals:
	void rateChanged();

private:
	double rate;
};

#endif
