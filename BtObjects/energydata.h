#ifndef ENERGYDATA_H
#define ENERGYDATA_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QDate>

class EnergyDevice;
class EnergyGraph;
class EnergyItem;
class QDomNode;

#define TEST_ENERGY_DATA 1


/*!
	\ingroup EnergyManagement
	\brief Reads energy consumption data for a monitored object (current and historic data)

	Allows reading current energy consumption, and records hourly/daily/monthly totals and graphs.

	Energy types are:
	- Electricity (watt)
	- Water (liter)
	- Gas (dm3, liter)
	- Hot water (calories)
	- Heating/cooling (calories)
*/
class EnergyData : public ObjectInterface
{
	Q_OBJECT

	/// The type of energy measured by this object
	Q_PROPERTY(EnergyType energyType READ getEnergyType CONSTANT)

	Q_ENUMS(GraphType ValueType EnergyType)

public:
	/// Type of graph data
	enum GraphType
	{
		/// Average consumption for each hour in a day (computed over a month)
		DailyAverageGraph,
		/// Consumption for each hour in a day
		CumulativeDayGraph,
		/// Total consumption for each day in a month
		CumulativeMonthGraph,
		/// Total consumption for each month in the last year (current month and the previous 11 months)
		CumulativeYearGraph
	};

	/// Type of value data
	enum ValueType
	{
		/// Current consumption
		CurrentValue,
		/// Total consumption over a day.
		CumulativeDayValue,
		/// Total consumption over a month.
		CumulativeMonthValue,
		/// Total consumption over the last year (current month and the previous 11 months).
		CumulativeYearValue,
		/// Average consumption value for the days in a month.
		MonthlyAverage
	};

	/// Type of energy measured by this device
	enum EnergyType
	{
		/// Electricity (watt)
		Electricity,
		/// Water (liter)
		Water,
		/// Gas (dm3, liter)
		Gas,
		/// Hot water (calories)
		HotWater,
		/// heating/cooling (calories)
		Heat
	};

	EnergyData(EnergyDevice *dev, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdEnergyData;
	}

	virtual QString getObjectKey() const
	{
		return QString();
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::EnergyManagement;
	}

	virtual QString getName() const
	{
		return name;
	}

	/*!
		\brief Returns an object holding graph data for the specified measure/time

		Data is requested asynchronously, hence the returned object might receive graph
		data at some later time.
	*/
	Q_INVOKABLE EnergyGraph *getGraph(GraphType type, QDate date);

	/*!
		\brief Returns an object holding the value for the specified measure/time

		Data is requested asynchronously, hence the returned object might receive the value
		at some later time.
	*/
	Q_INVOKABLE EnergyItem *getValue(ValueType type, QDate date);

	EnergyType getEnergyType() const;

public slots:
	/*!
		\brief Request automatic updates for the current consumption value
	*/
	void requestCurrentUpdateStart();

	/*!
		\brief Stop automatic updates for the current consumption value
	*/
	void requestCurrentUpdateStop();

private slots:
	void graphDestroyed(QObject *obj);
	void itemDestroyed(QObject *obj);

private:
	QDate normalizeDate(GraphType type, QDate date);
	QDate normalizeDate(ValueType type, QDate date);

	EnergyDevice *dev;
	QList<EnergyGraph *> graphCache;
	QList<EnergyItem *> valueCache;
	QString name;
};


/*!
	\brief Encapsulates a scalar consumption value
*/
class EnergyItem : public QObject
{
	Q_OBJECT

	Q_PROPERTY(EnergyData::ValueType valueType READ getValueType CONSTANT)
	Q_PROPERTY(QVariant value READ getValue NOTIFY valueChanged)
	Q_PROPERTY(QDate date READ getDate CONSTANT)
	Q_PROPERTY(bool isValid READ isValid NOTIFY validChanged)

public:
	EnergyItem(EnergyData *data, EnergyData::ValueType type, QDate date, QVariant value);

	QVariant getValue() const;

	EnergyData::ValueType getValueType() const;

	QDate getDate() const;

	bool isValid() const;

public slots:
	void requestUpdate();

signals:
	void valueChanged();
	void validChanged();

private:
	EnergyData *data;
	EnergyData::ValueType type;
	QDate date;
	QVariant value;
};


/*!
	\brief Encapsulates a consumption graph (set of consumption values)
*/
class EnergyGraph : public QObject
{
	Q_OBJECT

	Q_PROPERTY(EnergyData::GraphType graphType READ getGraphType CONSTANT)
	Q_PROPERTY(QVariantMap graph READ getGraph NOTIFY graphChanged)
	Q_PROPERTY(QDate date READ getDate CONSTANT)
	Q_PROPERTY(bool isValid READ isValid NOTIFY validChanged)

public:
	EnergyGraph(EnergyData *data, EnergyData::GraphType type, QDate date, QVariantMap graph);

	QVariantMap getGraph() const;

	EnergyData::GraphType getGraphType() const;

	QDate getDate() const;

	bool isValid() const;

public slots:
	void requestUpdate();

signals:
	void graphChanged();
	void validChanged();

private:
	EnergyData *data;
	EnergyData::GraphType type;
	QDate date;
	QVariantMap graph;
};

QList<ObjectInterface *> createEnergyData(const QDomNode &xml_node, int id);

#endif
