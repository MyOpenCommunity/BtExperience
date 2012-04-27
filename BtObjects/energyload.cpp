#include "energyload.h"

#include "loads_device.h"

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
}


EnergyLoadTotal::EnergyLoadTotal(QObject *parent) :
	QObject(parent)
{
	total = 0;
}

int EnergyLoadTotal::getTotal() const
{
	return total;
}

void EnergyLoadTotal::setTotal(int _total)
{
	if (total == _total)
		return;

	total = _total;
	emit totalChanged();
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


EnergyLoadManagement::EnergyLoadManagement(LoadsDevice *_dev, QString _name)
{
	dev = _dev;
	name = _name;
	status = Unknown;
	consumption = 0;

	period_totals.append(new EnergyLoadTotal(this));
	period_totals.append(new EnergyLoadTotal(this));

	connect(dev, SIGNAL(valueReceived(DeviceValues)),
		this, SLOT(valueReceived(DeviceValues)));
}

EnergyLoadManagement::LoadStatus EnergyLoadManagement::getLoadStatus() const
{
	return status;
}

int EnergyLoadManagement::getConsumption() const
{
	return consumption;
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

			period_totals[period]->setTotal(consumption.toInt());
			period_totals[period]->setResetDateTime(reset.toDateTime());

			break;
		}
		case LoadsDevice::DIM_CURRENT:
			if (it.value().toInt() != consumption)
			{
				consumption = it.value().toInt();
				emit consumptionChanged();
			}
		}
		++it;
	}
}


EnergyLoadManagementWithControlUnit::EnergyLoadManagementWithControlUnit(LoadsDevice *dev, bool advanced, QString name) :
	EnergyLoadManagement(dev, name)
{
	load_enabled = load_forced = false;
	is_advanced = advanced;
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
