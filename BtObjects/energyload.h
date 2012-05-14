#ifndef ENERGYLOAD_H
#define ENERGYLOAD_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QDateTime>

class LoadsDevice;


/*!
	\brief Total amount and last reset date/time for a consumption counter

	Exposes two read-only properties with the total consumption since last
	counter reset and the date/time of the last counter reset.
*/
class EnergyLoadTotal : public QObject
{
	Q_OBJECT

	/*!
		\brief Gets total consumption since last counter reset, in Watts
	*/
	Q_PROPERTY(int total READ getTotal NOTIFY totalChanged)

	/*!
		\brief Gets date/time of the last counter reset
	*/
	Q_PROPERTY(QDateTime resetDateTime READ getResetDateTime NOTIFY resetDateTimeChanged)

public:
	EnergyLoadTotal(QObject *parent = 0);

	int getTotal() const;
	void setTotal(int total);

	QDateTime getResetDateTime() const;
	void setResetDateTime(QDateTime reset);

signals:
	void totalChanged();
	void resetDateTimeChanged();

private:
	int total;
	QDateTime reset_date_time;
};


/*!
	\ingroup EnergyManagement
	\brief Reads the electricity load status of a monitored object

	The monitored object can be consuming a normal amount of power, an higher than
	normal amount of power and a critical/fault status.

	Additionally, the object could have consumption meters to read current and cumulative
	consumption.

	The object id is \a ObjectInterface::IdEnergyLoad, the object key is empty.
*/
class EnergyLoadManagement : public ObjectInterface
{
	friend class TestEnergyLoadManagement;

	Q_OBJECT

	/*!
		\brief The ok/warning/critical status of the device

		Call \a requestLoadStatus() to request a status update.
	*/
	Q_PROPERTY(LoadStatus loadStatus READ getLoadStatus NOTIFY loadStatusChanged)
\
	/*!
		\brief Electricity consumption, in Watts.

		Call \a requestConsumptionUpdateStart() and \a requestConsumptionUpdateStop()
		to start/stop automatic consumption updates.

		\sa hasConsumptionMeters
	*/
	Q_PROPERTY(int consumption READ getConsumption NOTIFY consumptionChanged)

	/*!
		\brief Information about period totals and reset time.

		Returns a 2-element array where each element is a \a EnergyLoadTotal instance.

		\sa hasConsumptionMeters
	*/
	Q_PROPERTY(QVariantList periodTotals READ getPeriodTotals NOTIFY periodTotalsChanged)

	/*!
		\brief Whether this actuator has a control unit.

		If this property is \c true then the load can be disabled by the control unit
		and forced to active by the user.

		\sa EnergyLoadManagementWithControlUnit
	*/
	Q_PROPERTY(bool hasControlUnit READ getHasControlUnit CONSTANT)

	/*!
		\brief Whether this actuator has consumption meters

		If this property is \c false, \a consumption and \a periodTotals are
		always zero.
	*/
	Q_PROPERTY(bool hasConsumptionMeters READ getHasConsumptionMeters CONSTANT)

	Q_ENUMS(LoadStatus)

public:
	enum LoadStatus
	{
		Unknown = 0,
		Ok = 1,
		Warning,
		Critical
	};

	EnergyLoadManagement(LoadsDevice *dev, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdEnergyLoad;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::EnergyManagement;
	}

	LoadStatus getLoadStatus() const;

	int getConsumption() const;

	QVariantList getPeriodTotals() const;

	virtual bool getHasControlUnit() const { return false; }
	virtual bool getHasConsumptionMeters() const { return true; }

public slots:
	/*!
		\brief Request a status update for load status
	*/
	void requestLoadStatus();

	/*!
		\brief Request a status update for counter totals
	*/
	void requestTotals();

	/*!
		\brief Start automatic updates for current consumption
	*/
	void requestConsumptionUpdateStart();

	/*!
		\brief Stop automatic updates for current consumption
	*/
	void requestConsumptionUpdateStop();

	/*!
		\brief Reset one of the two cumulative consumption counters
		\param index the total to reset (0 or 1)
	*/
	void resetTotal(int index);

signals:
	void loadStatusChanged();
	void periodTotalsChanged();
	void consumptionChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	LoadsDevice *dev;

private:
	LoadStatus status;
	int consumption;
	QList<EnergyLoadTotal *> period_totals;
};


/*!
	\ingroup EnergyManagement
	\brief Additional properties/methods for actuators with control unit

	Actuators with a control unit can be disabled by the control unit in case
	of excessive load and force-enabled by the user
*/
class EnergyLoadManagementWithControlUnit : public EnergyLoadManagement
{
	friend class TestEnergyLoadManagementWithControlUnit;

	Q_OBJECT

	/*!
		\brief Whether the load is active or not

		If the load has been disabled (for excessive load) by the control unit, it can
		be enabled by calling \a forceOn()
	*/
	Q_PROPERTY(bool loadEnabled READ getLoadEnabled NOTIFY loadEnabledChanged)

	/*!
		\brief Whether the load has been forced by calling \a forceOn()

		Call \a stopForcing() to stop forcing the load to on.
	*/
	Q_PROPERTY(bool loadForced READ getLoadForced NOTIFY loadForcedChanged)

public:
	EnergyLoadManagementWithControlUnit(LoadsDevice *dev, bool is_advanced, QString name);

	virtual bool getHasControlUnit() const { return true; }
	virtual bool getHasConsumptionMeters() const;

	bool getLoadEnabled() const;

	bool getLoadForced() const;

public slots:
	/*!
		\brief Enable the energy load for 4 hours, outside central unit control

		If called when \a loadEnabled is \c false, will re-enable the load, otherwise will
		just disable central unit control.
	*/
	void forceOn();

	/*!
		\brief Enable the energy load for the specified time, outside central unit control

		If called when \a loadEnabled is \c false, will re-enable the load, otherwise will
		just disable central unit control.
	*/
	void forceOn(int minutes);

	/*!
		\brief Put the energy load under central control unit control

		Can be called when \a loadForced is \c true.
	*/
	void stopForcing();

signals:
	void loadEnabledChanged();
	void loadForcedChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	bool load_enabled, load_forced, is_advanced;
};

#endif
