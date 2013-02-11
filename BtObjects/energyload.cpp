#include "energyload.h"
#include "xmlobject.h"
#include "loads_device.h"
#include "devices_cache.h"
#include "energyrate.h"

#include <QDebug>


namespace
{
	EnergyLoadManagement::LoadStatus mapLoad(int level)
	{
		switch (level)
		{
		case LoadsDevice::LOAD_OK:
			return EnergyLoadManagement::Ok;
		case LoadsDevice::LOAD_WARNING:
			return EnergyLoadManagement::Warning;
		case LoadsDevice::LOAD_CRITICAL:
			return EnergyLoadManagement::Critical;
		default:
			return EnergyLoadManagement::Unknown;
		}
	}

	QString getPriorityFrom(const QString& where)
	{
		int pos = where.indexOf('#');

		if (pos == -1)
		{
			qWarning("%s Device where must have a '#' character: %s", __PRETTY_FUNCTION__, where.toLatin1().data());
			return QString();
		}

		// remove part after '#'
		QString priority = where.left(pos);
		// remove first 7
		priority = priority.mid(1);

		return priority;
	}
}


QList<ObjectPair> parseLoadDiagnostic(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		LoadsDevice *d = bt_global::add_device_to_cache(new LoadsDevice(v.value("where")));
		obj_list << ObjectPair(uii, new EnergyLoadManagement(d, v.value("descr"), getPriorityFrom(v.value("where")), ObjectInterface::IdLoadDiagnostic, 0, 0));
	}
	return obj_list;
}

QList<ObjectPair> parseLoadWithCU(const QDomNode &xml_node, QHash<int, EnergyRate *> rates)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		EnergyRate *rate = 0;
		int rate_decimals = 0;
		if (v.intValue("rate_enabled"))
		{
			int rate_id = v.intValue("rate_id");

			if (!rates.contains(rate_id))
			{
				qWarning() << "Invalid rate id" << rate_id;
				qFatal("Invalid rate id %d", rate_id);
			}
			rate = rates[rate_id];
			rate_decimals = v.intValue("rate_n_decimal_view");
		}

		LoadsDevice *d = bt_global::add_device_to_cache(new LoadsDevice(v.value("where")));
		obj_list << ObjectPair(uii, new EnergyLoadManagementWithControlUnit(d, v.intValue("advanced"), v.value("descr"), getPriorityFrom(v.value("where")), rate, rate_decimals));
	}
	return obj_list;
}

QList<ObjectPair> parseLoadWithoutCU(const QDomNode &xml_node, QHash<int, EnergyRate *> rates)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		EnergyRate *rate = 0;
		int rate_decimals = 0;
		if (v.intValue("rate_enabled"))
		{
			int rate_id = v.intValue("rate_id");

			if (!rates.contains(rate_id))
			{
				qWarning() << "Invalid rate id" << rate_id;
				qFatal("Invalid rate id %d", rate_id);
			}
			rate = rates[rate_id];
			rate_decimals = v.intValue("rate_n_decimal_view");
		}

		LoadsDevice *d = bt_global::add_device_to_cache(new LoadsDevice(v.value("where")));
		obj_list << ObjectPair(uii, new EnergyLoadManagement(d, v.value("descr"), getPriorityFrom(v.value("where")), ObjectInterface::IdLoadWithoutControlUnit, rate, rate_decimals));
	}
	return obj_list;
}


EnergyLoadTotal::EnergyLoadTotal(QObject *parent, EnergyRate *_rate) :
	QObject(parent)
{
	total = 0;
	rate = _rate;

	if (rate)
	{
		connect(this, SIGNAL(totalChanged()),
			this, SIGNAL(totalExpenseChanged()));
		connect(rate, SIGNAL(rateChanged()),
			this, SIGNAL(totalExpenseChanged()));
	}
}

double EnergyLoadTotal::getTotal() const
{
	return total;
}

void EnergyLoadTotal::setTotal(double _total)
{
	if (total == _total)
		return;

	total = _total;
	emit totalChanged();
}

double EnergyLoadTotal::getTotalExpense() const
{
	return rate ? total * rate->getRate() : 0;
}

QDateTime EnergyLoadTotal::getResetDateTime() const
{
	return reset_date_time;
}

void EnergyLoadTotal::setResetDateTime(QDateTime reset)
{
	if (reset_date_time == reset)
		return;

	reset_date_time = reset;
	emit resetDateTimeChanged();
}


EnergyLoadManagement::EnergyLoadManagement(LoadsDevice *_dev, QString _name, QString _priority, int _oid, EnergyRate *_rate, int _rate_decimals) :
	DeviceObjectInterface(_dev)
{
	dev = _dev;
	name = _name;
	rate = _rate;
	rate_decimals = _rate_decimals;
	status = Unknown;
	consumption = 0;
	oid = static_cast<ObjectInterface::ObjectId>(_oid);
	priority = _priority;

	period_totals.append(new EnergyLoadTotal(this, rate));
	period_totals.append(new EnergyLoadTotal(this, rate));

	connect(dev, SIGNAL(valueReceived(DeviceValues)),
		this, SLOT(valueReceived(DeviceValues)));

	if (rate)
	{
		connect(this, SIGNAL(consumptionChanged()),
			this, SIGNAL(expenseChanged()));
		connect(rate, SIGNAL(rateChanged()),
			this, SIGNAL(expenseChanged()));
	}
}

EnergyLoadManagement::LoadStatus EnergyLoadManagement::getLoadStatus() const
{
	return status;
}

QString EnergyLoadManagement::getUnit() const
{
	return "kW";
}

QString EnergyLoadManagement::getCurrentUnit() const
{
	return "kW";
}

QString EnergyLoadManagement::getCumulativeUnit() const
{
	return "kWh";
}

QString EnergyLoadManagement::getPriority() const
{
	return priority;
}

double EnergyLoadManagement::getConsumption() const
{
	return consumption;
}

EnergyRate *EnergyLoadManagement::getRate() const
{
	return rate;
}

double EnergyLoadManagement::getExpense() const
{
	return rate ? consumption * rate->getRate() : 0;
}

QVariantList EnergyLoadManagement::getPeriodTotals() const
{
	QVariantList res;

	res.append(QVariant::fromValue(static_cast<QObject *>(period_totals[0])));
	res.append(QVariant::fromValue(static_cast<QObject *>(period_totals[1])));

	return res;
}

void EnergyLoadManagement::requestLoadStatus()
{
	dev->requestLevel();
}

void EnergyLoadManagement::requestTotals()
{
	dev->requestTotal(0);
	dev->requestTotal(1);
}

void EnergyLoadManagement::requestConsumptionUpdateStart()
{
	dev->requestCurrentUpdateStart();
}

void EnergyLoadManagement::requestConsumptionUpdateStop()
{
	dev->requestCurrentUpdateStop();
}

void EnergyLoadManagement::resetTotal(int index)
{
	dev->resetTotal(index);
}

void EnergyLoadManagement::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case LoadsDevice::DIM_LOAD:
			if (mapLoad(it.value().toInt()) != status)
			{
				status = mapLoad(it.value().toInt());
				emit loadStatusChanged();
			}
			break;
		case LoadsDevice::DIM_PERIOD:
		{
			int period = it.value().toInt();
			QVariant reset = values_list[LoadsDevice::DIM_RESET_DATE];
			QVariant consumption = values_list[LoadsDevice::DIM_TOTAL];

			period_totals[period]->setTotal(consumption.toInt() / 1000.0);
			period_totals[period]->setResetDateTime(reset.toDateTime());

			break;
		}
		case LoadsDevice::DIM_CURRENT:
		{
			double new_value = it.value().toInt() / 1000.0;

			if (new_value != consumption)
			{
				consumption = new_value;
				emit consumptionChanged();
			}
		}
			break;
		}
		++it;
	}
}


EnergyLoadManagementWithControlUnit::EnergyLoadManagementWithControlUnit(LoadsDevice *dev, bool advanced, QString name, QString priority, EnergyRate *_rate, int _rate_decimals) :
	EnergyLoadManagement(dev, name, priority, ObjectInterface::IdLoadWithControlUnit, _rate, _rate_decimals)
{
	load_enabled = load_forced = false;
	is_advanced = advanced;
	force_duration = 150; // default value is 2h 30m
}

bool EnergyLoadManagementWithControlUnit::getHasConsumptionMeters() const
{
	return is_advanced;
}

bool EnergyLoadManagementWithControlUnit::getLoadEnabled() const
{
	return load_enabled;
}

bool EnergyLoadManagementWithControlUnit::getLoadForced() const
{
	return load_forced;
}

int EnergyLoadManagementWithControlUnit::getForceDuration() const
{
	return force_duration;
}

void EnergyLoadManagementWithControlUnit::forceOn()
{
	dev->enable();
}

void EnergyLoadManagementWithControlUnit::forceOn(int minutes)
{
	dev->forceOff(minutes);
}

void EnergyLoadManagementWithControlUnit::stopForcing()
{
	dev->forceOn();
}

void EnergyLoadManagementWithControlUnit::decreaseForceDuration()
{
	if (force_duration - LoadsDevice::FORCE_DURATION_STEP < LoadsDevice::FORCE_DURATION_MIN)
		return;
	force_duration -= LoadsDevice::FORCE_DURATION_STEP;
	emit forceDurationChanged();
}

void EnergyLoadManagementWithControlUnit::increaseForceDuration()
{
	if (force_duration + LoadsDevice::FORCE_DURATION_STEP > LoadsDevice::FORCE_DURATION_MAX)
		return;
	force_duration += LoadsDevice::FORCE_DURATION_STEP;
	emit forceDurationChanged();
}

void EnergyLoadManagementWithControlUnit::valueReceived(const DeviceValues &values_list)
{
	EnergyLoadManagement::valueReceived(values_list);

	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case LoadsDevice::DIM_ENABLED:
			if (it.value().toBool() != load_enabled)
			{
				load_enabled = it.value().toBool();
				emit loadEnabledChanged();
			}
			break;
		case LoadsDevice::DIM_FORCED:
			if (it.value().toBool() != load_forced)
			{
				load_forced = it.value().toBool();
				emit loadForcedChanged();
			}
			break;
		}
		++it;
	}
}
