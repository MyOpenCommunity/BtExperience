#ifndef ENERGYRATE_H
#define ENERGYRATE_H

#include "objectinterface.h"


class EnergyRate;


QList<ObjectPair> parseEnergyRate(const QDomNode &xml_node);
void updateEnergyRate(QDomNode node, EnergyRate *item);


/*!
	\ingroup LoadManagement
	\ingroup EnergyDataSystem
	\brief Information about an energy conversion rate

	The rate object is used implictly by \ref EnergyLoadManagement and \ref EnergyData.
*/
class EnergyRate : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Conversion rate

		The value should always be positive
	*/
	Q_PROPERTY(double rate READ getRate WRITE setRate NOTIFY rateChanged)

	/*!
		\brief Energy rate minimum increment

		Used when changing rate: the GUI should increment/decrement rate
		value using this increment.
	*/
	Q_PROPERTY(double rateDelta READ getRateDelta CONSTANT)

	/// Internal rate identifier
	Q_PROPERTY(int rateId READ getRateId CONSTANT)

	/// Number of integer digits to display when changing the rate
	Q_PROPERTY(int displayIntegers READ getDisplayIntegers CONSTANT)

	/// Number of decimal digits to display when changing the rate
	Q_PROPERTY(int displayDecimals READ getDisplayDecimals CONSTANT)

	/// ISO currency code (EUR, USD, ...)
	Q_PROPERTY(QString currencyName READ getCurrencyName CONSTANT)

	/// Currency symbol
	Q_PROPERTY(QString currencySymbol READ getCurrencySymbol CONSTANT)

	/// Energy measure unit (kWh, m3, ...)
	Q_PROPERTY(QString measureUnit READ getMeasureUnit CONSTANT)

	/// Whether this rate applied to energy consumption or production
	Q_PROPERTY(RateType rateType READ getRateType CONSTANT)

	/// Type of energy
	Q_PROPERTY(EnergyType energyType READ getEnergyType CONSTANT)

	Q_ENUMS(RateType EnergyType)

public:
	/// Whether this rate applies to energy consumption or production
	enum RateType
	{
		Consumption = 1,
		Production
	};

	enum EnergyType
	{
		Electricity,
		Water,
		Gas,
		HotWater,
		Heat
	};

	EnergyRate(QString name, EnergyType energy_type, int id, double rate, double delta,
		   QString currency_name, QString currency_symbol,
		   RateType rate_type, QString measure_unit, int integers, int decimals);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdEnergyRate;
	}

	void setRate(double rate);
	double getRate() const;

	int getRateId() const;

	double getRateDelta() const;
	int getDisplayIntegers() const;
	int getDisplayDecimals() const;
	QString getCurrencyName() const;
	QString getCurrencySymbol() const;
	QString getMeasureUnit() const;
	RateType getRateType() const;
	EnergyType getEnergyType() const;

	// used by tests
	EnergyRate(double delta);

signals:
	void rateChanged();

private:
	int id, integers, decimals;
	double rate, delta;
	QString currency_name, currency_symbol, measure_unit;
	RateType rate_type;
	EnergyType energy_type;
};

#endif
