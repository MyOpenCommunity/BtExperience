#ifndef ENERGYDATA_H
#define ENERGYDATA_H

/*!
	\defgroup EnergyDataSystem Energy data

	This system provides data consumption values for various energy types.

	Each interface is represented with a \ref EnergyData object. Scalar values
	are retrieved using \ref EnergyData::getValue(), graph data is retrieved
	using \ref EnergyData::getGraph().

	\ref EnergyData automatically caches requested values in order to minimize
	request frames.
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QDate>
#include <QCache>
#include <QTimer>
#include <QVector>
#include <QSharedPointer>
#include <QWeakPointer>

class EnergyDevice;
class EnergyGraph;
class EnergyItem;
class EnergyRate;
class EnergyData;
class QDomNode;

#ifndef TEST_ENERGY_DATA
#define TEST_ENERGY_DATA 0
#endif


struct CacheKey
{
	CacheKey(int _type, const QDate &_date, bool _is_currency = false)
	{
		type = _type;
		date = _date;
		is_currency = _is_currency;
	}

	int type;
	QDate date;
	bool is_currency;
};

inline bool operator==(const CacheKey &first, const CacheKey &second)
{
	return first.type == second.type && first.date == second.date && first.is_currency == second.is_currency;
}

inline bool operator!=(const CacheKey &first, const CacheKey &second)
{
	return first.type != second.type || first.date != second.date || first.is_currency != second.is_currency;
}

inline uint qHash(const QDate &date)
{
	// TODO qHash(uint) returns the integer value; find a better hash for dates
	return qHash((date.year() << 0) | (date.month() << 12) | (date.day() << 17));
}

inline uint qHash(const CacheKey &key)
{
	return qHash(key.type) ^ qHash(key.date) ^ uint(key.is_currency);
}


/*!
	\brief Used to group energy lines

	This object does not correspond to an \c \<ist\> tag; the \ref objectKey attribute
	can be used to filter the list of interfaces that belong to the family.
*/
class EnergyFamily : public ObjectInterface
{
	Q_OBJECT

	Q_ENUMS(FamilyType)

public:
	enum FamilyType
	{
		Electricity,
		Water,
		Gas,
		DomesticHotWater,
		HeatingCooling,
		Custom
	};

	EnergyFamily(QString _name, FamilyType _type)
	{
		name = _name;
		type = _type;
	}

	virtual int getObjectId() const { return IdEnergyFamily; }
	virtual QString getObjectKey() const { return QString::number(type); }

private:
	FamilyType type;
};


QList<ObjectPair> parseEnergyData(const QDomNode &xml_node, EnergyFamily::FamilyType family, QHash<int, EnergyRate *> rates, QString family_name);

void updateEnergyData(QDomNode node, EnergyData *item);


/*!
	\ingroup EnergyDataSystem
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

	Each value is returned as either a \ref EnergyItem or \ref EnergyGraph.  The value is requested asynchronously,
	hence the returned value will typically be invalid and become valid only some time later.
*/
class EnergyData : public DeviceObjectInterface
{
	friend class EnergyGraph;
	friend class EnergyItem;

	friend class TestEnergyData;
	friend class TestEnergyItem;
	friend class TestEnergyGraph;

	Q_OBJECT

	/// The type of energy measured by this object
	Q_PROPERTY(EnergyType energyType READ getEnergyType CONSTANT)


	Q_PROPERTY(EnergyFamily::FamilyType familyType READ getFamilyType CONSTANT)
	Q_PROPERTY(QString familyName READ getFamilyName CONSTANT)

	/// Energy to currency conversion rate
	Q_PROPERTY(EnergyRate *rate READ getRate CONSTANT)

	/*!
		\brief Current threshold state

		Returns the number of thresholds that have been exceeded
	*/
	Q_PROPERTY(int thresholdLevel READ getThresholdLevel NOTIFY thresholdLevelChanged)

	/*!
		\brief Returns the thresholds set on the device

		Returns a two-element array, the values can be invalid when the device does not
		support thresholds, or the value has not been received yet
	*/
	Q_PROPERTY(QVariantList thresholds READ getThresholds WRITE setThresholds NOTIFY thresholdsChanged)

	/*!
		\brief Set/get whether the corresponding threshold is enabled or not

		Returns a two-element array of booleans
	*/
	Q_PROPERTY(QVariantList thresholdEnabled READ getThresholdEnabled WRITE setThresholdEnabled NOTIFY thresholdEnabledChanged)

	/*!
		\brief Return the monthly consumption goal

		This is a 12-element list where each element is a valid double value.
	*/
	Q_PROPERTY(QVariantList goals READ getGoals WRITE setGoals NOTIFY goalsChanged)

	/*!
		\brief Set/get whether the goals are enabled or not
	*/
	Q_PROPERTY(bool goalsEnabled READ getGoalsEnabled WRITE setGoalsEnabled NOTIFY goalsEnabledChanged)

	/*!
		\brief Get whether the goal for this month has been exceeded

		The property is reset to false at the start of the month
	*/
	Q_PROPERTY(bool goalExceeded READ getGoalExceeded NOTIFY goalExceededChanged)

	/*!
		\brief Measure unit symbol, as specified in configuration file

		This can be either an istantaneous or cumulative measure.

		\sa currentUnit
		\sa cumulativeUnit
	*/
	Q_PROPERTY(QString unit READ getUnit CONSTANT)

	/*!
		\brief Measure unit symbol for current consumption/production
	*/
	Q_PROPERTY(QString currentUnit READ getCurrentUnit CONSTANT)

	/*!
		\brief Measure unit symbol for cumulative consumption/production
	*/
	Q_PROPERTY(QString cumulativeUnit READ getCumulativeUnit CONSTANT)

	/*!
		\brief Number of decimals to be used to approximate economic data
	*/
	Q_PROPERTY(int decimals READ getDecimals CONSTANT)

	/*!
		\brief Whether this is and advanced energy device

		Advanced devices store more than 12 months of data and (for electricity)
		can have consumption thresholds.

		The property starts \c false and can change state at most once, becoming \c true.
	*/
	Q_PROPERTY(bool advanced READ getAdvanced NOTIFY advancedChanged)

	Q_ENUMS(GraphType ValueType EnergyType MeasureType)

public:
	/// Type of graph data
	enum GraphType
	{
		/// Average consumption for each hour in a day (computed over a month)
		DailyAverageGraph = 1,
		/// Consumption for each hour in a day
		CumulativeDayGraph,
		/// Total consumption for each day in a month
		CumulativeMonthGraph,
		/// Total consumption for each month in the current year
		CumulativeYearGraph,
		/// Total consumption for each month in the last year (current month and the previous 11 months)
		CumulativeLastYearGraph
	};

	/// Type of value data
	enum ValueType
	{
		/// Current consumption
		CurrentValue = 6,
		/// Total consumption over a day.
		CumulativeDayValue,
		/// Total consumption over a month.
		CumulativeMonthValue,
		/// Total consumption for the current year
		CumulativeYearValue,
		/// Total consumption for the last year (current month and the previous 11 months)
		CumulativeLastYearValue,
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

	/// Type of measure in graph/value
	enum MeasureType
	{
		/// Consumption (electricity, water, ...)
		Consumption = 0,
		/// Expense/gain (currency)
		Currency    = 1
	};

	EnergyData(EnergyDevice *dev, QString name, EnergyFamily::FamilyType family, QString unit, QVariantList goals, bool goals_enabled,
			   QVariantList thresholds_enabled, EnergyRate *rate, int rate_decimals, QString family_name = QString());

	virtual int getObjectId() const;

	virtual QString getObjectKey() const;

	/*!
		\brief Returns an \ref EnergyGraph holding graph data for the specified measure/time

		Data is requested asynchronously, hence the returned object might receive graph
		data at some later time.

		If this energy device does not have an associated tariff, passing \ref Currency as measure
		returns NULL.
	*/
	QSharedPointer<QObject> getGraph(GraphType type, QDate date, MeasureType measure = Consumption);

	/*!
		\brief Returns an \ref EnergyItem holding the value for the specified measure/time

		Data is requested asynchronously, hence the returned object might receive the value
		at some later time.

		If this energy device does not have an associated tariff, passing \ref Currency as measure
		returns NULL.
	*/
	QSharedPointer<QObject> getValue(ValueType type, QDate date, MeasureType measure = Consumption);

	/*!
		\brief Checks if the date argument is valid.
	*/
	Q_INVOKABLE bool isValidDate(QDate date) const;

	EnergyType getEnergyType() const;
	EnergyFamily::FamilyType getFamilyType() const;
	EnergyRate *getRate() const;

	int getThresholdLevel() const;

	void setThresholds(QVariantList thresholds);
	QVariantList getThresholds() const;

	void setGoals(QVariantList goals);
	QVariantList getGoals() const;

	void setGoalsEnabled(bool enabled);
	bool getGoalsEnabled() const;

	QString getUnit() const;
	QString getCurrentUnit() const;
	QString getCumulativeUnit() const;

	int getDecimals() const;
	int getRateDecimals() const;

	void setThresholdEnabled(QVariantList enabled);
	QVariantList getThresholdEnabled() const;

	bool getGoalExceeded() const;

	bool getAdvanced() const;

	QString getFamilyName() const;

public slots:
	/*!
		\brief Request automatic updates for the current consumption value
	*/
	void requestCurrentUpdateStart();

	/*!
		\brief Stop automatic updates for the current consumption value
	*/
	void requestCurrentUpdateStop();

signals:
	void thresholdsChanged(QVariantList thresholds);
	void thresholdLevelChanged(int level);
	void thresholdEnabledChanged(QVariantList enabled);
	void advancedChanged();
	void goalsChanged();
	void goalsEnabledChanged();
	void goalExceededChanged();

private slots:
	// remove destroyed objects from graphCache/itemChache
	void graphDestroyed(QObject *obj);
	void itemDestroyed(QObject *obj);

	void valueReceived(const DeviceValues &values_list);

	void trimCache();

	// called on first day of month to check consumption goals
	void checkConsumptionGoals();

private:
	enum RequestOptions
	{
		None   = 0,
		Force  = 1
	};

	enum RequestStatus
	{
		Pending  = 0,
		Complete = 1
	};

	// add a value/graph to the cache, updating EnergyItem/EnergyGraph objects
	void cacheValueData(ValueType type, QDate date, qint64 value);
	void cacheGraphData(GraphType type, QDate date, QMap<int, unsigned int> graph);

	// called when receiving a cumulative month value, constructs cumulative
	// year value and graph
	void cacheYearGraphData(QDate date, double month_value);
	void cacheLastYearGraphData(QDate date, double month_value);

	// check whether the cache entry for a cumulative year graph contains valid
	// values for the year
	bool checkYearGraphDataIsValid(QDate date, const QVector<double> &values);
	bool checkLastYearGraphDataIsValid(const QVector<double> &values);

	// create EnergyGraphbar objects for a graph
	QList<QObject *> createGraph(GraphType type, const QVector<double> &values, EnergyRate *rate = 0);

	// request an update for the specified value/graph; takes into account pending requests
	// and avoids requesting again cached data
	void requestUpdate(int type, QDate date, RequestOptions options = None);

	// requests the cumulative month value for all months in the year
	void requestCumulativeYear(QDate date, RequestOptions options);
	void requestCumulativeLastYear(RequestOptions options);

	// check whether consumption goal was exceeded
	void checkConsumptionGoal(QDate date, double month_value);

	typedef QPair<quint64, RequestStatus> RequestInfo;

	EnergyDevice *dev;
	EnergyRate *rate;
	// cache for objects returned to QML
	QHash<CacheKey, QWeakPointer<EnergyGraph> > graph_cache;
	QHash<CacheKey, QWeakPointer<EnergyItem> > item_cache;
	// cached values received from the device
	QCache<CacheKey, QVector<double> > value_cache;
	// pending requests (all values) and completed requests (for timespans including today)
	QHash<CacheKey, RequestInfo> requests;
	QTimer trim_cache;

	// current consumption thresholds
	QVariantList thresholds, last_thresholds;
	int threshold_level;
	QVariantList thresholds_enabled;

	// Consumption goals
	QVariantList goals;
	bool goals_enabled, goal_exceeded;
	int goal_month_check;

	// Unit symbol (es. kW, dm3, ...)
	QString energy_unit;
	// conversion factor from device units to energy_unit
	// f.e. if unit is yd3, unit_conversion is 0.0013079506
	double unit_conversion;

	int decimals; // the number of decimals in the current measure unit
	int rate_decimals;

	EnergyFamily::FamilyType family;
	QString family_name;

#if TEST_ENERGY_DATA
private slots:
	void testValueData(EnergyData::ValueType type, QDate date);
	void testGraphData(EnergyData::GraphType type, QDate date);
	void testAutomaticUpdates();
private:
	QTimer automatic_updates;
#endif //TEST_ENERGY_DATA
};


/*!
	\ingroup EnergyDataSystem
	\brief Encapsulates a scalar consumption value
*/
class EnergyItem : public QObject
{
	friend class TestEnergyData;
	friend class TestEnergyItem;
	friend class TestEnergyGraph;

	Q_OBJECT

	/*!
		\brief The kind of value contained in this object (current, cumulative, average)
	*/
	Q_PROPERTY(EnergyData::ValueType valueType READ getValueType CONSTANT)

	/*!
		\brief The value for the measure

		Since the value is requested asynchronously, the value might be invalid when the
		\ref EnergyItem object is returned.  Once the value becomes valid, it stays valid.

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
		\brief Whether the value returned by \ref value is valid

		\sa value
	*/
	Q_PROPERTY(bool isValid READ isValid NOTIFY validChanged)

	/*!
		\brief Number of decimals to be used to approximate economic data
	*/
	Q_PROPERTY(int decimals READ getDecimals CONSTANT)

	/*!
		\brief Consumption goal for this month cumulative value.

		If a goal is not set for a particular interface or energy type, this
		value is invalid.
	*/
	Q_PROPERTY(QVariant consumptionGoal READ getConsumptionGoal CONSTANT)

	/*!
		\brief Return whether the goal is enabled or not
	*/
	Q_PROPERTY(bool goalEnabled READ getGoalEnabled CONSTANT)

	/*!
		\brief Measure unit in which the value is expressed

		\sa value
	*/
	Q_PROPERTY(QString measureUnit READ getMeasureUnit CONSTANT)

public:
	EnergyItem(EnergyData *data, EnergyData::ValueType type, QDate date, QVariant value, EnergyRate *rate = 0);

	QVariant getValue() const;

	EnergyData::ValueType getValueType() const;

	QDate getDate() const;

	bool isValid() const;

	void setValue(QVariant value);

	virtual QString getMeasureUnit() const;

	QVariant getConsumptionGoal() const;
	bool getGoalEnabled() const;

	int getDecimals() const;

public slots:
	/*!
		\brief Can be used to force a value update for the device

		It should never be needed (cache/request logic is handled transparently
		by \ref EnergyData).
	*/
	void requestUpdate();

signals:
	void valueChanged();
	void validChanged();

protected:
	EnergyData *data;
	EnergyRate *rate;

private:
	EnergyData::ValueType type;
	QDate date;
	QVariant value;
	QString measure_unit;
};


/*!
	\ingroup EnergyDataSystem
	\brief Encapsulates current consumption value

	In addition to the methods for other scalar values, adds properties to
	retrieve consumption thresholds and notifies when thresholds are exceeded.
*/
class EnergyItemCurrent : public EnergyItem
{
	Q_OBJECT

	/*!
		\brief Current threshold state

		Returns the number of thresholds that have been exceeded
	*/
	Q_PROPERTY(int thresholdLevel READ getThresholdLevel NOTIFY thresholdLevelChanged)

	/*!
		\brief Returns the thresholds set on the device
	*/
	Q_PROPERTY(QVariantList thresholds READ getThresholds WRITE setThresholds NOTIFY thresholdsChanged)

public:
	EnergyItemCurrent(EnergyData *data, EnergyData::ValueType type, QDate date, QVariant value, EnergyRate *rate = 0);

	int getThresholdLevel() const;

	void setThresholds(QVariantList thresholds);
	QVariantList getThresholds() const;

	virtual QString getMeasureUnit() const;

signals:
	void thresholdsChanged(QVariantList thresholds);
	void thresholdLevelChanged(int level);
};


/*!
	\ingroup EnergyDataSystem
	\brief Object for a column composing the energy graph
*/
class EnergyGraphBar : public QObject
{
	friend class TestEnergyData;
	friend class TestEnergyItem;
	friend class TestEnergyGraph;

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
		\ref EnergyItem object is returned.  Once the value becomes valid, it stays valid.

		\sa EnergyGraph::isValid
	*/
	Q_PROPERTY(QVariant value READ getValue NOTIFY valueChanged)

public:
	EnergyGraphBar(QVariant index, QString label, QVariant value, EnergyRate *rate = 0);

	QVariant getIndex() const;
	QString getLabel() const;
	QVariant getValue() const;

signals:
	void valueChanged();

private:
	QVariant index;
	QString label;
	QVariant value;
	EnergyRate *rate;
};


/*!
	\ingroup EnergyDataSystem
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
		\ref EnergyItem object is returned.  Once the value becomes valid, it stays valid.

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
		\brief Whether the bars returned by \ref graph contain valid values

		\sa graph
	*/
	Q_PROPERTY(bool isValid READ isValid NOTIFY validChanged)

	/*!
		\brief The maximum value contained in the graph.
	*/
	Q_PROPERTY(QVariant maxValue READ getMaxValue NOTIFY maxValueChanged)

public:
	EnergyGraph(EnergyData *data, EnergyData::GraphType type, QDate date, QList<QObject*> graph);

	QList<QObject*> getGraph() const;

	EnergyData::GraphType getGraphType() const;

	QDate getDate() const;

	bool isValid() const;

	void setGraph(QList<QObject*> graph);

	QVariant getMaxValue() const;

	Q_INVOKABLE QObject *getGraphBar(int index) const;

public slots:
	/*!
		\brief Can be used to force a graph update for the device

		It should never be needed (cache/request logic is handled transparently
		by \ref EnergyData).
	*/
	void requestUpdate();

signals:
	void graphChanged();
	void validChanged();
	void maxValueChanged();

private:
	static bool graphEqual(QList<QObject*> first, QList<QObject*> second);

	double max_value;
	EnergyData *data;
	EnergyData::GraphType type;
	QDate date;
	QList<QObject*> graph;
};

Q_DECLARE_METATYPE(EnergyData::ValueType)
Q_DECLARE_METATYPE(EnergyData::GraphType)


/*!
	\brief Holds a reference to an EnergyGraph object

	Example usage:

	\verbatim
	EnergyGraphObject {
		id: modelGraphValue
		energyData: component.energyData
		graphType: EnergyData.CumulativeDayGraph
		date: component.graphDate
		measureType: component.showCurrency ? EnergyData.Currency : EnergyData.Consumption
	}
	\endverbatim

	And in the code use \c modelGraphValue.graph to get the graph reference.

	This class in necessary because of QTBUG-15997 (properties/bindings do not count as
	object references for JS-owned  objects)
*/
class EnergyGraphObject : public QObject
{
	Q_OBJECT

	Q_PROPERTY(EnergyData::GraphType graphType READ getGraphType WRITE setGraphType NOTIFY graphTypeChanged)

	Q_PROPERTY(QDate date READ getDate WRITE setDate NOTIFY dateChanged)

	Q_PROPERTY(EnergyData::MeasureType measureType READ getMeasureType WRITE setMeasureType NOTIFY measureTypeChanged)

	Q_PROPERTY(QObject *graph READ getGraph NOTIFY graphChanged)

	Q_PROPERTY(EnergyData *energyData READ getEnergyData WRITE setEnergyData NOTIFY energyDataChanged)

public:
	EnergyGraphObject(QObject *parent = 0);

	void setGraphType(EnergyData::GraphType type);
	EnergyData::GraphType getGraphType() const;

	void setDate(QDate date);
	QDate getDate() const;

	void setMeasureType(EnergyData::MeasureType type);
	EnergyData::MeasureType getMeasureType() const;

	void setEnergyData(EnergyData* data);
	EnergyData *getEnergyData() const;

	QObject *getGraph() const;

signals:
	void graphTypeChanged();
	void dateChanged();
	void measureTypeChanged();
	void graphChanged();
	void energyDataChanged();

private:
	void updateGraph();

	EnergyData *energy;
	int graph_type;
	int measure;
	QDate date;
	QSharedPointer<QObject> graph;
};


/*!
	\brief Holds a reference to an EnergyItem object

	Example usage:

	\verbatim
	EnergyItemObject {
		id: consumptionValue
		energyData: delegate.itemObject
		valueType: EnergyData.CumulativeMonthValue
		date: new Date()
		measureType: EnergyData.Consumption
	}
	\endverbatim

	And in the code use \c consumptionValue.item to get the value reference.

	This class in necessary because of QTBUG-15997 (properties/bindings do not count as
	object references for JS-owned  objects)
*/
class EnergyItemObject : public QObject
{
	Q_OBJECT

	Q_PROPERTY(EnergyData::ValueType valueType READ getValueType WRITE setValueType NOTIFY valueTypeChanged)

	Q_PROPERTY(QDate date READ getDate WRITE setDate NOTIFY dateChanged)

	Q_PROPERTY(EnergyData::MeasureType measureType READ getMeasureType WRITE setMeasureType NOTIFY measureTypeChanged)

	Q_PROPERTY(QObject *item READ getItem NOTIFY itemChanged)

	Q_PROPERTY(EnergyData *energyData READ getEnergyData WRITE setEnergyData NOTIFY energyDataChanged)

public:
	EnergyItemObject(QObject *parent = 0);

	void setValueType(EnergyData::ValueType type);
	EnergyData::ValueType getValueType() const;

	void setDate(QDate date);
	QDate getDate() const;

	void setMeasureType(EnergyData::MeasureType type);
	EnergyData::MeasureType getMeasureType() const;

	void setEnergyData(EnergyData* data);
	EnergyData *getEnergyData() const;

	QObject *getItem() const;

signals:
	void valueTypeChanged();
	void dateChanged();
	void measureTypeChanged();
	void itemChanged();
	void energyDataChanged();

private:
	void updateItem();

	EnergyData *energy;
	int value_type;
	int measure;
	QDate date;
	QSharedPointer<QObject> item;
};

#endif
