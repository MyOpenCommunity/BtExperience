#include "energyrate.h"
#include "xmlobject.h"


QList<ObjectPair> parseEnergyRate(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		EnergyRate::RateType rate_type = v.intValue("type") == 1 ? EnergyRate::Production : EnergyRate::Consumption;
		EnergyRate::EnergyType energy_type;

		switch (v.intValue("mode"))
		{
		case 1:
			energy_type = EnergyRate::Electricity;
			break;
		case 2:
			energy_type = EnergyRate::Water;
			break;
		case 3:
			energy_type = EnergyRate::Gas;
			break;
		case 4:
			energy_type = EnergyRate::HotWater;
			break;
		case 5:
			energy_type = EnergyRate::Heat;
			break;
		default:
			qFatal("Invalid energy type in energy rate");
		}

		obj_list << ObjectPair(uii, new EnergyRate(v.value("descr"), energy_type, v.intValue("rate_id"),
							   v.doubleValue("tariff"), v.doubleValue("delta"), v.value("name"),
							   v.value("symbol"), rate_type, v.value("measure"),
							   v.intValue("n_integer"), v.intValue("n_decimal")));
	}
	return obj_list;
}


EnergyRate::EnergyRate(double _rate)
{
	rate = _rate;
}

EnergyRate::EnergyRate(QString _name, EnergyType _energy_type, int _id, double _rate, double _delta,
		       QString _currency_name, QString _currency_symbol,
		       RateType _rate_type, QString _measure_unit, int _integers, int _decimals)
{
	name = _name;
	id = _id;
	rate = _rate;
	delta = _delta;
	energy_type = _energy_type;
	currency_name = _currency_name;
	currency_symbol = _currency_symbol;
	rate_type = _rate_type;
	measure_unit = _measure_unit;
	integers = _integers;
	decimals = _decimals;
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

int EnergyRate::getRateId() const
{
	return id;
}

double EnergyRate::getRateDelta() const
{
	return delta;
}

int EnergyRate::getDisplayIntegers() const
{
	return integers;
}

int EnergyRate::getDisplayDecimals() const
{
	return decimals;
}

QString EnergyRate::getCurrencyName() const
{
	return currency_name;
}

QString EnergyRate::getCurrencySymbol() const
{
	return currency_symbol;
}

QString EnergyRate::getMeasureUnit() const
{
	return measure_unit;
}

EnergyRate::RateType EnergyRate::getRateType() const
{
	return rate_type;
}

EnergyRate::EnergyType EnergyRate::getEnergyType() const
{
	return energy_type;
}
