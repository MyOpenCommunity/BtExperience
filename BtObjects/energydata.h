#ifndef ENERGYDATA_H
#define ENERGYDATA_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QDate>

class EnergyDevice;
class EnergyGraph;
class EnergyItem;
class QDomNode;

// TODO scrivere test quando rimuoveremo l'implementazione random
#define TEST_ENERGY_DATA 1

#if TEST_ENERGY_DATA
	class QTimer;
#endif //TEST_ENERGY_DATA


/*!
	\ingroup EnergyManagement
	\brief Reads energy consumption data for a monitored object (current and historic data)

	Allows reading current energy consumption, and records hourly/daily/monthly totals and graphs.

	Energy types are:
	- Electricity (kilowatt)
	- Water (liter)
	- Gas (dm3, liter)
	- Hot water (calories)
	- Heating/cooling (calories)

	This object gives access to multiple scalar values (current consumption, averages, cumulative values)
	and graphs (average and cumulative).

	Each value is returned as either a \c EnergyItem or \c EnergyGraph.  The value is requested asynchronously,
	hence the returned value will typically be invalid and become valid only some time later.
*/
class EnergyData : public ObjectInterface
{
	Q_OBJECT

	/// The type of energy measured by this object
	Q_PROPERTY(EnergyType energyType READ getEnergyType CONSTANT)

	/// Is this a general or line counter?
	Q_PROPERTY(bool general READ isGeneral CONSTANT)

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
		MonthlyAverageValue
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

	EnergyData(EnergyDevice *dev, QString name, bool general);

	virtual int getObjectId() const;

	virtual QString getObjectKey() const;

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::EnergyManagement;
	}

	/*!
		\brief Returns an object holding graph data for the specified measure/time

		Data is requested asynchronously, hence the returned object might receive graph
		data at some later time.
	*/
	Q_INVOKABLE QObject *getGraph(GraphType type, QDate date, bool inCurrency=false);

	/*!
		\brief Returns an object holding the value for the specified measure/time

		Data is requested asynchronously, hence the returned object might receive the value
		at some later time.
	*/
	Q_INVOKABLE QObject *getValue(ValueType type, QDate date, bool inCurrency=false);

	EnergyType getEnergyType() const;
	bool isGeneral() const;

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
	bool general;
};


/*!
	\brief Encapsulates a scalar consumption value
*/
class EnergyItem : public QObject
{
	Q_OBJECT

	/*!
		\brief The kind of value contained in this object (current, cumulative, average)
	*/
	Q_PROPERTY(EnergyData::ValueType valueType READ getValueType CONSTANT)

	/*!
		\brief The value for the measure

		Since the value is requested asynchronously, the value might be invalid when the
		\c EnergyItem object is returned.  Once the value becomes valid, it stays valid.

		\sa isValid
	*/
	Q_PROPERTY(QVariant value READ getValue NOTIFY valueChanged)

	/*!
		\brief The date this value refers to

		For monthly values, the day is normalized to 1, for yearly dates,
		both month and day are normalized to 1.
	*/
	Q_PROPERTY(QDate date READ getDate CONSTANT)

	/*!
		\brief Whether the value returned by \c value is valid

		\sa value
	*/
	Q_PROPERTY(bool isValid READ isValid NOTIFY validChanged)

public:
	EnergyItem(EnergyData *data, EnergyData::ValueType type, QDate date, QVariant value);

	QVariant getValue() const;

	EnergyData::ValueType getValueType() const;

	QDate getDate() const;

	bool isValid() const;

public slots:
	/*!
		\brief Can be used to force a value update for the device

		It should never be needed (cache/request logic is handled transparently
		by \c EnergyData).
	*/
	void requestUpdate();

signals:
	void valueChanged();
	void validChanged();

private:
	EnergyData *data;
	EnergyData::ValueType type;
	QDate date;
	QVariant value;

#if TEST_ENERGY_DATA
private slots:
	void timerEvent();
private:
	QTimer *timer;
#endif //TEST_ENERGY_DATA
};


/*!
	\brief Object for a column composing the energy graph
*/
class EnergyGraphBar : public QObject
{
	Q_OBJECT

	/*!
		\brief Numeric, 0-based index of the bar in the graph
	*/
	Q_PROPERTY(QVariant index READ getIndex CONSTANT)

	/*!
		\brief Descriptive label for the bar
	*/
	Q_PROPERTY(QString label READ getLabel CONSTANT)

	/*!
		\brief The value for the bar

		Since the value is requested asynchronously, the value might be invalid when the
		\c EnergyItem object is returned.  Once the value becomes valid, it stays valid.

		\sa EnergyGraph::isValid
	*/
	Q_PROPERTY(QVariant value READ getValue CONSTANT)

public:
	EnergyGraphBar(QVariant index, QString label, QVariant value)
	{
		this->index = index;
		this->label = label;
		this->value = value;
	}

	QVariant getIndex() const { return index; }
	QString getLabel() const { return label; }
	QVariant getValue() const { return value; }

private:
	QVariant index;
	QString label;
	QVariant value;
};


/*!
	\brief Encapsulates a consumption graph (set of consumption values)
*/
class EnergyGraph : public QObject
{
	Q_OBJECT

	/*!
		\brief The kind of graph contained in this object (cumulative, average)
	*/
	Q_PROPERTY(EnergyData::GraphType graphType READ getGraphType CONSTANT)

	/*!
		\brief List of bars composing the graph

		Since the value is requested asynchronously, the value might be invalid when the
		\c EnergyItem object is returned.  Once the value becomes valid, it stays valid.

		\sa isValid
	*/
	Q_PROPERTY(QList<QObject*> graph READ getGraph NOTIFY graphChanged)

	/*!
		\brief The date this value refers to

		For monthly values, the day is normalized to 1, for yearly dates,
		both month and day are normalized to 1.
	*/
	Q_PROPERTY(QDate date READ getDate CONSTANT)

	/*!
		\brief Whether the bars returned by \c graph contain valid values

		\sa graph
	*/
	Q_PROPERTY(bool isValid READ isValid NOTIFY validChanged)

public:
	EnergyGraph(EnergyData *data, EnergyData::GraphType type, QDate date, QList<QObject*> graph);

	QList<QObject*> getGraph() const;

	EnergyData::GraphType getGraphType() const;

	QDate getDate() const;

	bool isValid() const;

public slots:
	/*!
		\brief Can be used to force a graph update for the device

		It should never be needed (cache/request logic is handled transparently
		by \c EnergyData).
	*/
	void requestUpdate();

signals:
	void graphChanged();
	void validChanged();

private:
	EnergyData *data;
	EnergyData::GraphType type;
	QDate date;
	QList<QObject*> graph;
};

QList<ObjectInterface *> createEnergyData(const QDomNode &xml_node, int id);

#endif
