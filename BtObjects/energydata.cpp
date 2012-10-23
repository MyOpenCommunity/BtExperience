#include "energydata.h"
#include "energyrate.h"
#include "energy_device.h"
#include "devices_cache.h"
#include "xmlobject.h"

#include <stdlib.h> // rand

#include <QDebug> // qDebug
#include <QVector>

#if TEST_ENERGY_DATA
#include <QTimer>
#include "delayedslotcaller.h"
#endif //TEST_ENERGY_DATA

#define INVALID_VALUE -1

// the number of seconds the cached value for consumptions including today is considered valid
#define CURRENT_VALUE_EXPIRATION_MSECS 60000
// maximum cost for the cache
#define VALUE_CACHE_MAX_COST 2000
// trim the cache to this size...
#define VALUE_CACHE_TRIM_COST 31
// ...after this inactivity timeout
#define CACHE_TRIM_INTERVAL_MSEC 300 * 1000 // 5 min
// consumption goals check interval
#define GOAL_CHECK_INTERVAL (50 * 60 * 1000)

/*
	EnergyData tries to reduce the amount of requests performed by the object, it does so by:
	- not issuing duplicate requests when one is already pending
	- keeping a cache of recently-received data (uses a QCache with max cost 2000, each value has cost 1)
	  - if a cached value includes the value for today, it is requeried at most every 60 seconds
	  - if a cached value does not include today's values, it is never requeried

	EnergyGraph and EnergyItem are created on-demand, and cached until QML deletes them; the
	cache key is <type, date, is_currency>.

	Request flow:
	- the user calls getValue(type, date, is_currency)
	- if an EnergyItem for the triplet is already in cache, it's returned
	    - if the time interval for the data includes today, and the last request for this
	      time interval was more than 60 seconds ago, the object requests again the data to the device
	- a new EnergyItem is allocated and added to the item cache
	- if there is cached data for the given <type, date> pair, it is used to fill the value for
	  the EnergyItem
	    - if the time interval for the data includes today, and the last request for this
	      time interval was more than 60 seconds ago, the object requests again the data to the device

	- when the object makes a request to the device, it adds a pair <timestamp, false> to the
	  request map
	- when the device response arrives
	    - for time intervals that include today, the pair is replaced with <timestamp, true>
	    - for other time intervals, the pair is deleted from the map
*/
namespace
{
	// remove the given value from an hash
	template<class K, class V>
	void removeValue(QHash<K, V> &map, const V &value)
	{
		typedef typename QHash<K, V>::iterator iter;

		for (iter it = map.begin(), end = map.end(); it != end; ++it)
		{
			if (it.value() == value)
			{
				map.erase(it);
				break;
			}
		}
	}

	EnergyData::ValueType mapDimensionToItemType(int dimension)
	{
		switch (dimension)
		{
		case EnergyDevice::DIM_CURRENT:
			return EnergyData::CurrentValue;
		case EnergyDevice::DIM_CUMULATIVE_DAY:
			return EnergyData::CumulativeDayValue;
		case EnergyDevice::DIM_CUMULATIVE_MONTH:
			return EnergyData::CumulativeMonthValue;
		case EnergyDevice::DIM_CUMULATIVE_YEAR:
			return EnergyData::CumulativeYearValue;
		case EnergyDevice::DIM_MONTLY_AVERAGE:
			return EnergyData::MonthlyAverageValue;
		default:
			Q_ASSERT_X(0, "mapDimensionToItemType", "invalid dimension");
			return static_cast<EnergyData::ValueType>(-1);
		}
	}

	EnergyData::GraphType mapDimensionToGraphType(int dimension)
	{
		switch (dimension)
		{
		case EnergyDevice::DIM_CUMULATIVE_MONTH_GRAPH:
			return EnergyData::CumulativeMonthGraph;
		case EnergyDevice::DIM_CUMULATIVE_YEAR_GRAPH:
			return EnergyData::CumulativeYearGraph;
		case EnergyDevice::DIM_DAILY_AVERAGE_GRAPH:
			return EnergyData::DailyAverageGraph;
		case EnergyDevice::DIM_DAY_GRAPH:
			return EnergyData::CumulativeDayGraph;
		default:
			Q_ASSERT_X(0, "mapDimensionToGraphType", "invalid dimension");
			return static_cast<EnergyData::GraphType>(-1);
		}
	}

	// normalize the date according to type:
	// - for daily values simply returns the date
	// - for monthly values sets the day to 1
	// - for yearly values seths day and month to 1
	QDate normalizeDate(int type, QDate date)
	{
		switch (type)
		{
		case EnergyData::CurrentValue:
			return QDate::currentDate();
		case EnergyData::DailyAverageGraph:
		case EnergyData::CumulativeDayValue:
		case EnergyData::CumulativeDayGraph:
			return date;
		case EnergyData::MonthlyAverageValue:
		case EnergyData::CumulativeMonthValue:
		case EnergyData::CumulativeMonthGraph:
			return QDate(date.year(), date.month(), 1);
		case EnergyData::CumulativeYearValue:
		case EnergyData::CumulativeYearGraph:
			return QDate(date.year(), 1, 1);
		case EnergyData::CumulativeLastYearValue:
		case EnergyData::CumulativeLastYearGraph:
			return QDate();
		}

		Q_ASSERT_X(0, "EnergyData::normalizeDate", "Invalid value for ValueType");
		return QDate();
	}

	// retuns true is the time interval for the value includes today
	bool dateContainsToday(int type, QDate date)
	{
		return date == normalizeDate(type, QDate::currentDate());
	}

#if TEST_ENERGY_DATA
	int valueRange(EnergyData::EnergyType type)
	{
		return type == EnergyData::Electricity ? 3000 : 100;
	}
#endif

	double unitConversionFactor(EnergyData::EnergyType type, QString unit)
	{
		if (type == EnergyData::Electricity && unit == "Kw")
			return 1000;

		return 1;
	}

	static QStringList goal_names = QStringList()
			<< "january" << "february" << "march" << "april" << "may" << "june"
			<< "july" << "august" << "september" << "october" << "november" << "december";
}


QList<ObjectPair> parseEnergyData(const QDomNode &xml_node, EnergyFamily::FamilyType family, QHash<int, EnergyRate *> rates)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		EnergyDevice *d = bt_global::add_device_to_cache(new EnergyDevice(v.value("where"), v.intValue("mode")));
		QVariantList goals, thresholds_enabled;

		EnergyRate *rate = 0;
		int rate_decimals = 0;
		if (v.intValue("rate_enabled"))
		{
			int rate_id = v.intValue("rate_id");

			if (!rates.contains(rate_id))
				qFatal("Invalid rate id %d", rate_id);
			rate = rates[rate_id];
			rate_decimals = v.intValue("rate_n_decimal_view");
		}

		bool goals_enabled = v.intValue("consumption_goal_enabled");

		for (int i = 0; i < 12; ++i)
			goals.append(QVariant(0));

		QDomNodeList childs = ist.firstChildElement("consumption_goal").childNodes();

		for (int i = 0; i < childs.size(); ++i)
		{
			const QDomNode &month = childs.at(i);
			if (!month.isElement())
				continue;
			int index = goal_names.indexOf(month.toElement().tagName());

			if (index != -1)
				goals[index] = month.toElement().text().toFloat();
		}

		thresholds_enabled << bool(v.intValue("threshold_one_enable"));
		thresholds_enabled << bool(v.intValue("threshold_two_enable"));

		obj_list << ObjectPair(uii, new EnergyData(d, v.value("descr"), family, v.value("measure"), goals, goals_enabled, thresholds_enabled, rate, rate_decimals));
	}
	return obj_list;
}


void updateEnergyData(QDomNode node, EnergyData *item)
{
	setAttribute(node, "consumption_goal_enabled", QString::number(item->getGoalsEnabled()));
	setAttribute(node, "threshold_one_enable", QString::number(item->getThresholdEnabled()[0].toInt()));
	setAttribute(node, "threshold_two_enable", QString::number(item->getThresholdEnabled()[1].toInt()));

	QVariantList values = item->getGoals();

	QDomNode goals = node.namedItem("consumption_goal");
	if (goals.isNull())
	{
		goals = node.ownerDocument().createElement("consumption_goal");
		goals = node.appendChild(goals);
	}

	for (int i = 0; i < 12; ++i)
		setTextChild(goals, goal_names[i], QString::number(values[i].toDouble()));
}

EnergyData::EnergyData(EnergyDevice *_dev, QString _name, EnergyFamily::FamilyType _family, QString _unit, QVariantList _goals, bool _goals_enabled, QVariantList _thresholds_enabled, EnergyRate *_rate, int _rate_decimals)
{
	name = _name;
	family = _family;
	dev = _dev;
	rate = _rate;
	energy_unit = _unit;
	goals = _goals;
	rate_decimals = _rate_decimals;
	unit_conversion = unitConversionFactor(getEnergyType(), _unit);
	thresholds_enabled = _thresholds_enabled;
	goals_enabled = _goals_enabled;
	goal_exceeded = false;
	goal_month_check = -1;
	thresholds = QVariantList() << 0.0 << 0.0;
	threshold_level = 0;

	decimals = getEnergyType() == Electricity ? 2 : 0;
	value_cache.setMaxCost(VALUE_CACHE_MAX_COST);

	trim_cache.setSingleShot(true);
	trim_cache.setInterval(CACHE_TRIM_INTERVAL_MSEC);
	connect(&trim_cache, SIGNAL(timeout()), this, SLOT(trimCache()));

	trim_cache.setSingleShot(true);
	trim_cache.setInterval(CACHE_TRIM_INTERVAL_MSEC);
	connect(&trim_cache, SIGNAL(timeout()), this, SLOT(trimCache()));

#if TEST_ENERGY_DATA
	thresholds = QVariantList() << 2.2 << 3.80;

	automatic_updates.setInterval(5000);
	connect(&automatic_updates, SIGNAL(timeout()), this, SLOT(testAutomaticUpdates()));
#endif

	QTimer *goal_check_timer = new QTimer(this);

	goal_check_timer->setInterval(GOAL_CHECK_INTERVAL);
	goal_check_timer->start();

	connect(goal_check_timer, SIGNAL(timeout()), this, SLOT(checkConsumptionGoals()));

	connect(this, SIGNAL(thresholdEnabledChanged(QVariantList)), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(goalsChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(goalsEnabledChanged()), this, SIGNAL(persistItem()));

	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));
}

EnergyData::~EnergyData()
{
	foreach (EnergyItem *value, item_cache.values())
		delete value;
	foreach (EnergyGraph *graph, graph_cache.values())
		delete graph;
}

QVariantList EnergyData::getGoals() const
{
	return goals;
}

void EnergyData::setGoals(QVariantList _goals)
{
	if (_goals == goals)
		return;

	goals = _goals;
	emit goalsChanged();
}

bool EnergyData::getGoalsEnabled() const
{
	return goals_enabled;
}

void EnergyData::setGoalsEnabled(bool enabled)
{
	if (enabled == goals_enabled)
		return;

	goals_enabled = enabled;
	emit goalsEnabledChanged();
}

QString EnergyData::getUnit() const
{
	return energy_unit;
}

QString EnergyData::getCurrentUnit() const
{
	// it's more correct to do this per-unit rather than per-energy type; for
	// example heating/cooling can have Kw and cal in the configuration
	if (energy_unit == "Kw")
		return energy_unit;
	else
		return energy_unit + "/h";
}

QString EnergyData::getCumulativeUnit() const
{
	// see comment in getCurrentUnit()
	if (energy_unit == "Kw")
		return "Kwh";
	else
		return energy_unit;
}

int EnergyData::getDecimals() const
{
	return decimals;
}

int EnergyData::getRateDecimals() const
{
	return rate_decimals;
}

void EnergyData::setThresholdEnabled(QVariantList enabled)
{
	if (enabled == thresholds_enabled)
		return;

	// update device thresholds
	for (int i = 0; i < 2; ++i)
		if (enabled[i] != thresholds_enabled[i])
			dev->setThresholdValue(i, enabled[i].toBool() ? thresholds[i].toDouble() * unit_conversion : 0);

	thresholds_enabled = enabled;
	emit thresholdEnabledChanged(thresholds_enabled);
}

QVariantList EnergyData::getThresholdEnabled() const
{
	return thresholds_enabled;
}

bool EnergyData::getGoalExceeded() const
{
	return goal_exceeded;
}

bool EnergyData::getAdvanced() const
{
	return dev->isAdvanced();
}

QObject *EnergyData::getGraph(GraphType type, QDate date, MeasureType measure)
{
	if (measure == Currency && !rate)
		return 0;

	// (re)start trim cache timeout
	trim_cache.start();

	QList<QObject*> values;
	QDate actual_date = normalizeDate(type, date);
	CacheKey key(type, actual_date, measure), value_key(type, actual_date);

	if (EnergyGraph *graph = graph_cache.value(key))
	{
		// re-request for cached timespans that include today's value
		if (dateContainsToday(type, actual_date))
			requestUpdate(type, actual_date);

		return graph;
	}

	QVector<double> *cached = value_cache.object(value_key);
	// for cumulative year graph we might have some valid values received as part of navigating month graphs
	if (cached && !(type == CumulativeYearGraph && !checkYearGraphDataIsValid(date, *cached)) &&
		      !(type == CumulativeLastYearGraph && !checkLastYearGraphDataIsValid(*cached)))
		values = createGraph(type, *cached, measure == Currency ? rate : 0);

	EnergyGraph *graph = new EnergyGraph(this, type, actual_date, values);

	graph_cache[key] = graph;
	connect(graph, SIGNAL(destroyed(QObject*)), this, SLOT(graphDestroyed(QObject*)));

	// re-request for cached timespans that include today's value
	if (!cached || dateContainsToday(type, actual_date))
		requestUpdate(type, actual_date);

	return graph;
}

QObject *EnergyData::getValue(ValueType type, QDate date, MeasureType measure)
{
	if (measure == Currency && !rate)
		return 0;

	// (re)start trim cache timeout
	trim_cache.start();

	QVariant val;
	QDate actual_date = normalizeDate(type, date);
	CacheKey key(type, actual_date, measure), value_key(type, actual_date);

	if (EnergyItem *item = item_cache.value(key))
	{
		// re-request for cached timespans that include today's value
		if (dateContainsToday(type, actual_date))
			requestUpdate(type, actual_date);

		return item;
	}

	QVector<double> *cached = value_cache.object(value_key);
	if (cached)
		val = (*cached)[0];


	EnergyItem *value;

	if (type == CurrentValue)
	{
		value = new EnergyItemCurrent(this, type, actual_date, val, measure == Currency ? rate : 0);

		connect(this, SIGNAL(thresholdLevelChanged(int)),
			value, SIGNAL(thresholdLevelChanged(int)));
		connect(this, SIGNAL(thresholdsChanged(QVariantList)),
			value, SIGNAL(thresholdsChanged(QVariantList)));
	}
	else
		value = new EnergyItem(this, type, actual_date, val, measure == Currency ? rate : 0);

	item_cache[key] = value;
	connect(value, SIGNAL(destroyed(QObject*)), this, SLOT(itemDestroyed(QObject*)));

	// re-request for cached timespans that include today's value
	if (!cached || dateContainsToday(type, actual_date))
		requestUpdate(type, actual_date);

	return value;
}

int EnergyData::getObjectId() const
{
	return IdEnergyData;
}

QString EnergyData::getObjectKey() const
{
	return QString("type:%1,%2").arg(static_cast<int>(getEnergyType())).arg(static_cast<int>(family));
}

EnergyData::EnergyType EnergyData::getEnergyType() const
{
	switch (dev->getEnergyType())
	{
	case 1:
		return Electricity;
	case 2:
		return Water;
	case 3:
		return Gas;
	case 4:
		return HotWater;
	case 5:
		return Heat;
	}

	Q_ASSERT_X(0, "EnergyData::getEnergyType", "Invalid value for energy type");

	return Electricity;
}

EnergyFamily::FamilyType EnergyData::getFamilyType() const
{
	return family;
}

void EnergyData::requestCurrentUpdateStart()
{
#if TEST_ENERGY_DATA
	automatic_updates.start();
#endif
	dev->requestCurrentUpdateStart();
}

void EnergyData::requestCurrentUpdateStop()
{
#if TEST_ENERGY_DATA
	automatic_updates.stop();
#endif
	dev->requestCurrentUpdateStop();
}

void EnergyData::cacheValueData(ValueType type, QDate date, qint64 value)
{
	value_cache.insert(CacheKey(type, date), new QVector<double>(1, value / unit_conversion), 1);

	// update values in returned EnergyItem objects
	if (EnergyItem *item = item_cache.value(CacheKey(type, date, false)))
		item->setValue(value / unit_conversion);
	if (EnergyItem *item = item_cache.value(CacheKey(type, date, true)))
		item->setValue(value / unit_conversion);

	// see comment in valueReceived()
	if (type == CumulativeMonthValue)
	{
		cacheYearGraphData(date, value / unit_conversion);
		cacheLastYearGraphData(date, value / unit_conversion);
		checkConsumptionGoal(date, value / unit_conversion);
	}
}

void EnergyData::cacheGraphData(GraphType type, QDate date, QMap<int, unsigned int> graph)
{
	QVector<double> *values = new QVector<double>(graph.size());

	value_cache.insert(CacheKey(type, date), values, graph.size());

	for (int i = 0; i < graph.size(); ++i)
		(*values)[i] = graph[i + 1] / unit_conversion;

	// update values in returned EnergyGraph objects
	if (EnergyGraph *graph = graph_cache.value(CacheKey(type, date, false)))
		graph->setGraph(createGraph(type, *values));
	if (EnergyGraph *graph = graph_cache.value(CacheKey(type, date, true)))
		graph->setGraph(createGraph(type, *values, rate));
}

void EnergyData::cacheYearGraphData(QDate date, double month_value)
{
	QDate actual_date = QDate(date.year(), 1, 1);
	CacheKey key(CumulativeYearGraph, actual_date);
	QVector<double> *values = value_cache.object(key);
	int index = date.month() - 1;

	// add new value to the cache
	if (!values)
	{
		values = new QVector<double>();
		values->reserve(12);
		value_cache.insert(key, values, 12);
	}

	while (values->size() <= index)
		values->append(INVALID_VALUE);

	double old_value = (*values)[index];

	(*values)[index] = month_value;

	// if the new value is different from the old one and we have all the data for the
	// year, update EnergyGraph/EnergyItem objects
	if (old_value == month_value || !checkYearGraphDataIsValid(actual_date, *values))
		return;

	// compute cumulative year value and insert it into the cache
	double cumulative_value = 0.0;

	for (int i = 0; i < values->count(); ++i)
		cumulative_value += (*values)[i];

	value_cache.insert(CacheKey(CumulativeYearValue, actual_date), new QVector<double>(1, cumulative_value), 1);

	// update year graph objects
	if (EnergyGraph *graph = graph_cache.value(CacheKey(CumulativeYearGraph, actual_date, false)))
		graph->setGraph(createGraph(CumulativeYearGraph, *values));
	if (EnergyGraph *graph = graph_cache.value(CacheKey(CumulativeYearGraph, actual_date, true)))
		graph->setGraph(createGraph(CumulativeYearGraph, *values, rate));
	// update cumulative year value objects
	if (EnergyItem *value = item_cache.value(CacheKey(CumulativeYearValue, actual_date, false)))
		value->setValue(cumulative_value);
	if (EnergyItem *value = item_cache.value(CacheKey(CumulativeYearValue, actual_date, true)))
		value->setValue(cumulative_value);
}

void EnergyData::cacheLastYearGraphData(QDate date, double month_value)
{
	QDate today = QDate::currentDate();
	int delta = (today.year() - date.year()) * 12 + (today.month() - date.month());
	if (delta >= 12)
		return;

	QDate actual_date = QDate();
	CacheKey key(CumulativeLastYearGraph, actual_date);
	QVector<double> *values = value_cache.object(key);
	int index = 11 - ((QDate::currentDate().month() - date.month() + 12) % 12);

	// add new value to the cache
	if (!values)
	{
		values = new QVector<double>();
		values->reserve(12);
		value_cache.insert(key, values, 12);
	}

	while (values->size() <= index)
		values->append(INVALID_VALUE);

	double old_value = (*values)[index];

	(*values)[index] = month_value;

	// if the new value is different from the old one and we have all the data for the
	// year, update EnergyGraph/EnergyItem objects
	if (old_value == month_value || !checkLastYearGraphDataIsValid(*values))
		return;

	// compute cumulative year value and insert it into the cache
	double cumulative_value = 0.0;

	for (int i = 0; i < values->count(); ++i)
		cumulative_value += (*values)[i];

	value_cache.insert(CacheKey(CumulativeLastYearValue, actual_date), new QVector<double>(1, cumulative_value), 1);

	// update year graph objects
	if (EnergyGraph *graph = graph_cache.value(CacheKey(CumulativeLastYearGraph, actual_date, false)))
		graph->setGraph(createGraph(CumulativeLastYearGraph, *values));
	if (EnergyGraph *graph = graph_cache.value(CacheKey(CumulativeLastYearGraph, actual_date, true)))
		graph->setGraph(createGraph(CumulativeLastYearGraph, *values, rate));
	// update cumulative year value objects
	if (EnergyItem *value = item_cache.value(CacheKey(CumulativeLastYearValue, actual_date, false)))
		value->setValue(cumulative_value);
	if (EnergyItem *value = item_cache.value(CacheKey(CumulativeLastYearValue, actual_date, true)))
		value->setValue(cumulative_value);
}

bool EnergyData::checkYearGraphDataIsValid(QDate date, const QVector<double> &values)
{
	QDate today = QDate::currentDate();
	int count = date.year() == today.year() ? today.month() : 12;

	if (values.size() < count)
		return false;

	for (int i = 0; i < count; ++i)
		if (values[i] == INVALID_VALUE)
			return false;

	return true;
}

bool EnergyData::checkLastYearGraphDataIsValid(const QVector<double> &values)
{
	if (values.size() < 12)
		return false;

	for (int i = 0; i < 12; ++i)
		if (values[i] == INVALID_VALUE)
			return false;

	return true;
}

QList<QObject *> EnergyData::createGraph(GraphType type, const QVector<double> &values, EnergyRate *rate)
{
	QList<QObject *> bars;
	QList<QString> keys;

	switch (type)
	{
	case DailyAverageGraph:
		for (int i = 0; i < values.count(); ++i)
			keys << QString("%1-%2").arg(i).arg(i + 1);
		break;
	case CumulativeMonthGraph:
	case CumulativeDayGraph:
		for (int i = 0; i < values.count(); ++i)
			keys << QString::number(i + 1);
		break;
	case CumulativeLastYearGraph:
	{
		QDate today = QDate::currentDate();
		QStringList all_keys = QStringList()
			 << tr("Jan") << tr("Feb") << tr("Mar")
			 << tr("Apr") << tr("May") << tr("Jun")
			 << tr("Jul") << tr("Aug") << tr("Sep")
			 << tr("Oct") << tr("Nov") << tr("Dec");

		today = today.addMonths(-11);
		for (int i = 0; i < 12; ++i)
		{
			keys.append(all_keys[today.month() - 1]);
			today = today.addMonths(+1);
		}

		break;
	}
	case CumulativeYearGraph:
		keys << tr("Jan") << tr("Feb") << tr("Mar")
			 << tr("Apr") << tr("May") << tr("Jun")
			 << tr("Jul") << tr("Aug") << tr("Sep")
			 << tr("Oct") << tr("Nov") << tr("Dec");
		break;
	}

	for (int i = 0; i < values.count(); ++i)
		bars.append(new EnergyGraphBar(i, keys[i], values[i], rate));

	return bars;
}

void EnergyData::requestUpdate(int type, QDate date, RequestOptions options)
{
	CacheKey key(type, normalizeDate(type, date));
	quint64 msec_now = QDateTime::currentMSecsSinceEpoch();

	if (type != CumulativeYearGraph && type != CumulativeYearValue &&
	    type != CumulativeLastYearGraph && type != CumulativeLastYearValue && options != Force)
	{
		// there is a cached response and the timespan does not include today
		if (!dateContainsToday(type, key.date) && value_cache.contains(key))
			return;

		if (requests.contains(key))
		{
			bool timed_out = msec_now - requests[key].first > CURRENT_VALUE_EXPIRATION_MSECS;

			// there is a pending request for this value (with timeout check just in case)
			if (requests[key].second == Pending && !timed_out)
				return;

			// the timespan includes today but there was a request less than 60 seconds ago
			if (requests[key].second == Complete && value_cache.contains(key) && !timed_out)
				return;
		}
	}

	if (type != CumulativeYearGraph && type != CumulativeYearValue &&
	    type != CumulativeLastYearGraph && type != CumulativeLastYearValue)
		requests[key] = qMakePair(msec_now, Pending);

#if TEST_ENERGY_DATA
	switch (type)
	{
	case CurrentValue:
	case CumulativeDayValue:
	case CumulativeMonthValue:
	case MonthlyAverageValue:
	{
		DelayedSlotCaller *caller = new DelayedSlotCaller;
		caller->setSlot(this, SLOT(testValueData(EnergyData::ValueType,QDate)), 0);
		caller->addArgument(static_cast<ValueType>(type));
		caller->addArgument(key.date);
	}
		break;
	case DailyAverageGraph:
	case CumulativeDayGraph:
	case CumulativeMonthGraph:
	{
		DelayedSlotCaller *caller = new DelayedSlotCaller;
		caller->setSlot(this, SLOT(testGraphData(EnergyData::GraphType,QDate)), 0);
		caller->addArgument(static_cast<GraphType>(type));
		caller->addArgument(key.date);
	}
		break;
	}
#endif

	switch (type)
	{
	case DailyAverageGraph:
		dev->requestDailyAverageGraph(key.date);
		break;
	case CumulativeDayGraph:
		dev->requestCumulativeDayGraph(key.date);
		break;
	case CumulativeMonthGraph:
		dev->requestCumulativeMonthGraph(key.date);
		break;
	case CumulativeYearGraph:
		// see comment in valueReceived()
		requestCumulativeYear(key.date, options);
		break;
	case CumulativeLastYearGraph:
		requestCumulativeLastYear(options);
		break;
	case CurrentValue:
		dev->requestCurrent();
		break;
	case CumulativeDayValue:
		dev->requestCumulativeDay(key.date);
		break;
	case CumulativeMonthValue:
		dev->requestCumulativeMonth(key.date);
		break;
	case CumulativeYearValue:
		// see comment in valueReceived()
		requestCumulativeYear(key.date, options);
		break;
	case CumulativeLastYearValue:
		requestCumulativeLastYear(options);
		break;
	case MonthlyAverageValue:
		dev->requestMontlyAverage(key.date);
		break;
	}
}

void EnergyData::requestCumulativeYear(QDate date, RequestOptions options)
{
	QDate today = QDate::currentDate();
	int count;

	if (date.year() == today.year())
		count = today.month();
	else
		count = 12;

	// request updates for past months not in cache
	for (int i = 0; i < count; ++i)
	{
		QDate month(date.year(), i + 1, 1);

		if (!value_cache.contains(CacheKey(CumulativeMonthValue, month)) || i == count - 1)
			requestUpdate(CumulativeMonthValue, month, options);
	}
}

void EnergyData::requestCumulativeLastYear(RequestOptions options)
{
	QDate today = QDate::currentDate();
	QDate month(today.year(), today.month(), 1);

	// request updates for past months not in cache
	for (int i = 0; i < 12; ++i)
	{
		if (!value_cache.contains(CacheKey(CumulativeMonthValue, month)) || i == 0)
			requestUpdate(CumulativeMonthValue, month, options);
		month = month.addMonths(-1);
	}
}

void EnergyData::valueReceived(const DeviceValues &values_list)
{
	// TODO parse thresholds
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case EnergyDevice::DIM_ADVANCED_DEVICE:
			emit advancedChanged();
			break;
		case EnergyDevice::DIM_THRESHOLD_STATE:
		{
			QList<int> state = it.value().value<QList<int> >();
			QVariantList enabled;
			int exceeded_count = 0;

			for (int i = 0; i < 2; ++i)
			{
				if (state[i] == EnergyDevice::THRESHOLD_EXCEEDED)
					exceeded_count += 1;
				enabled.append(state[i] != EnergyDevice::THRESHOLD_DISABLED);
			}

			if (enabled != thresholds_enabled)
			{
				thresholds_enabled = enabled;
				emit thresholdEnabledChanged(thresholds_enabled);
			}
			if (exceeded_count != threshold_level)
			{
				threshold_level = exceeded_count;
				emit thresholdLevelChanged(threshold_level);
			}
		}
			break;
		case EnergyDevice::DIM_THRESHOLD_INDEX:
		{
			int index = it.value().toInt();
			double value = values_list[EnergyDevice::DIM_THRESHOLD_VALUE].toInt() / unit_conversion;

			if (thresholds[index] != value)
			{
				thresholds[index] = value;
				emit thresholdsChanged(thresholds);
			}
		}
			break;
		case EnergyDevice::DIM_CURRENT:
		case EnergyDevice::DIM_CUMULATIVE_DAY:
		case EnergyDevice::DIM_CUMULATIVE_MONTH:
		// DIM_CUMULATIVE_YEAR uses the same (wrong) time span used by DIM_CUMULATIVE_YEAR_GRAPH
		case EnergyDevice::DIM_MONTLY_AVERAGE:
		{
			EnergyValue value = it.value().value<EnergyValue>();
			ValueType type = mapDimensionToItemType(it.key());
			QDate date = normalizeDate(type, value.first);

			if (!dateContainsToday(type, date))
				requests.remove(CacheKey(type, date));
			else
				requests[CacheKey(type, date)].second = Complete;

			cacheValueData(type, date, value.second);
		}
			break;
		case EnergyDevice::DIM_CUMULATIVE_MONTH_GRAPH:
		case EnergyDevice::DIM_DAILY_AVERAGE_GRAPH:
		case EnergyDevice::DIM_DAY_GRAPH:
		// DIM_CUMULATIVE_YEAR_GRAPH is composed in the device by multiple
		// DIM_CUMULATIVE_MONTH values, and it has the wrong time span (last 12
		// months instead of starting from January), so we do not use it and use
		// DIM_CUMULATIVE_MONTH values
		{
			GraphData data = it.value().value<GraphData>();
			GraphType type = mapDimensionToGraphType(it.key());
			QDate date = normalizeDate(type, data.date);

			if (!dateContainsToday(type, date))
				requests.remove(CacheKey(type, date));
			else
				requests[CacheKey(type, date)].second = Complete;

			cacheGraphData(type, date, data.graph);
		}
			break;
		}
		++it;
	}
}

void EnergyData::trimCache()
{
	// reduce cache size to VALUE_CACHE_TRIM_COST to delete some objects
	value_cache.setMaxCost(VALUE_CACHE_TRIM_COST);
	value_cache.setMaxCost(VALUE_CACHE_MAX_COST);
}

void EnergyData::checkConsumptionGoals()
{
	if (!goals_enabled)
		return;
	QDate today = QDate::currentDate();
	if (goal_exceeded && goal_month_check == today.month())
		return;

	if (goal_exceeded)
	{
		goal_exceeded = false;
		emit goalExceededChanged();
	}

	requestUpdate(CumulativeMonthValue, today, Force);
}

void EnergyData::checkConsumptionGoal(QDate date, double month_value)
{
	if (!goals_enabled)
		return;
	// only check goal for current month
	QDate today = QDate::currentDate();
	if (date.month() != today.month() || date.year() != today.year())
		return;

	if (!goal_exceeded && month_value > goals[date.month() - 1].toDouble())
	{
		goal_exceeded = true;
		goal_month_check = date.month();
		emit goalExceededChanged();
	}
}

void EnergyData::graphDestroyed(QObject *obj)
{
	// can't use qobject_cast/dynamic_cast on a destroyed object
	removeValue(graph_cache, static_cast<EnergyGraph *>(obj));
}

void EnergyData::itemDestroyed(QObject *obj)
{
	// can't use qobject_cast/dynamic_cast on a destroyed object
	removeValue(item_cache, static_cast<EnergyItem *>(obj));
}

#if TEST_ENERGY_DATA

void EnergyData::testValueData(ValueType type, QDate date)
{
	// mirrors the logic in valueReceived()
	if (!dateContainsToday(type, date))
		requests.remove(CacheKey(type, date));
	else
		requests[CacheKey(type, date)].second = Complete;

	cacheValueData(type, date, rand() % valueRange(getEnergyType()));
}

void EnergyData::testGraphData(GraphType type, QDate date)
{
	QMap<int, unsigned int> graph_values;
	int count = 0;

	switch (type)
	{
	case DailyAverageGraph:
	case CumulativeDayGraph:
		count = 24;
		break;
	case CumulativeMonthGraph:
		count = date.daysInMonth();
		break;
	case CumulativeYearGraph:
	case CumulativeLastYearGraph:
		count = 12;
		break;
	}

	for (int i = 0; i < count; ++i)
		graph_values[i + 1] = rand() % valueRange(getEnergyType());

	// mirrors the logic in valueReceived()
	if (!dateContainsToday(type, date))
		requests.remove(CacheKey(type, date));
	else
		requests[CacheKey(type, date)].second = Complete;

	cacheGraphData(type, date, graph_values);
}

void EnergyData::testAutomaticUpdates()
{
	cacheValueData(EnergyData::CurrentValue, QDate(), rand() % valueRange(getEnergyType()));
}
#endif

EnergyRate *EnergyData::getRate() const
{
	return rate;
}

int EnergyData::getThresholdLevel() const
{
	return threshold_level;
}

void EnergyData::setThresholds(QVariantList _thresholds)
{
	if (_thresholds == thresholds)
		return;

	// set to device
	for (int i = 0; i < 2; ++i)
		if (thresholds_enabled[i].toBool())
			dev->setThresholdValue(i, _thresholds[i].toDouble() * 1000);

	thresholds = _thresholds;
	emit thresholdsChanged(thresholds);
}

QVariantList EnergyData::getThresholds() const
{
	return thresholds;
}


EnergyItem::EnergyItem(EnergyData *_data, EnergyData::ValueType _type, QDate _date, QVariant _value, EnergyRate *_rate)
{
	data = _data;
	type = _type;
	date = _date;
	value = _value;
	rate = _rate;

	if (rate)
		connect(rate, SIGNAL(rateChanged()), this, SIGNAL(valueChanged()));
}

QVariant EnergyItem::getValue() const
{
	if (!value.isValid() || !rate)
		return value;
	else
		return value.toDouble() * rate->getRate();
}

EnergyData::ValueType EnergyItem::getValueType() const
{
	return type;
}

QDate EnergyItem::getDate() const
{
	return date;
}

void EnergyItem::requestUpdate()
{
	data->requestUpdate(type, date, EnergyData::Force);
}

bool EnergyItem::isValid() const
{
	return value.isValid();
}

void EnergyItem::setValue(QVariant val)
{
	if (value == val)
		return;

	bool valid = isValid();

	value = val;

	if (!valid)
		emit validChanged();
	emit valueChanged();
}

QString EnergyItem::getMeasureUnit() const
{
	if (rate)
		return rate->getCurrencySymbol();
	else
		return data->getCumulativeUnit();
}

QVariant EnergyItem::getConsumptionGoal() const
{
	if (rate)
		return data->getGoals().value(date.month() - 1).toDouble() * rate->getRate();
	else
		return data->getGoals().value(date.month() - 1);
}

bool EnergyItem::getGoalEnabled() const
{
	return data->getGoalsEnabled();
}

int EnergyItem::getDecimals() const
{
	if (rate)
		return data->getRateDecimals();
	else
		return data->getDecimals();
}


EnergyItemCurrent::EnergyItemCurrent(EnergyData *data, EnergyData::ValueType type, QDate date, QVariant value, EnergyRate *rate) :
	EnergyItem(data, type, date, value, rate)
{
}

int EnergyItemCurrent::getThresholdLevel() const
{
	return data->getThresholdLevel();
}

void EnergyItemCurrent::setThresholds(QVariantList thresholds)
{
	data->setThresholds(thresholds);
}

QVariantList EnergyItemCurrent::getThresholds() const
{
	return data->getThresholds();
}

QString EnergyItemCurrent::getMeasureUnit() const
{
	if (rate)
		return rate->getCurrencySymbol() + "/h";
	else
		return data->getCurrentUnit();
}



EnergyGraphBar::EnergyGraphBar(QVariant _index, QString _label, QVariant _value, EnergyRate *_rate)
{
	index = _index;
	label = _label;
	value = _value;
	rate = _rate;

	if (rate)
		connect(rate, SIGNAL(rateChanged()), this, SIGNAL(valueChanged()));
}

QVariant EnergyGraphBar::getIndex() const
{
	return index;
}

QString EnergyGraphBar::getLabel() const
{
	return label;
}

QVariant EnergyGraphBar::getValue() const
{
	if (!value.isValid() || !rate)
		return value;
	else
		return value.toDouble() * rate->getRate();
}


EnergyGraph::EnergyGraph(EnergyData *_data, EnergyData::GraphType _type, QDate _date, QList<QObject*> _graph)
{
	data = _data;
	type = _type;
	date = _date;
	max_value = 0.0;
	setGraph(_graph);
}

QList<QObject*> EnergyGraph::getGraph() const
{
	return graph;
}

EnergyData::GraphType EnergyGraph::getGraphType() const
{
	return type;
}

QDate EnergyGraph::getDate() const
{
	return date;
}

void EnergyGraph::requestUpdate()
{
	data->requestUpdate(type, date, EnergyData::Force);
}

bool EnergyGraph::isValid() const
{
	return !graph.isEmpty();
}

bool EnergyGraph::graphEqual(QList<QObject*> first, QList<QObject*> second)
{
	if (first.count() != second.count())
		return false;

	for (int i = 0; i < first.count(); ++i)
	{
		EnergyGraphBar *fb = qobject_cast<EnergyGraphBar*>(first[i]);
		EnergyGraphBar *sb = qobject_cast<EnergyGraphBar*>(second[i]);

		if (fb->getValue() != sb->getValue())
			return false;
	}

	return true;
}

void EnergyGraph::setGraph(QList<QObject *> _graph)
{
	if (graphEqual(graph, _graph))
		return;

	bool valid = isValid();

	graph = _graph;

	double max = max_value;
	for (int i = 0; i < graph.count(); ++i)
	{
		EnergyGraphBar *bar = qobject_cast<EnergyGraphBar*>(graph[i]);
		bar->setParent(this);
		max = qMax(max, bar->getValue().toDouble());
	}

	if (!valid && isValid())
		emit validChanged();
	emit graphChanged();

	if (max != max_value)
	{
		max_value = max;
		emit maxValueChanged();
	}
}

QObject *EnergyGraph::getGraphBar(int index) const
{
	if (index < 0 || index >= graph.size())
	{
		qWarning() << "EnergyGraph::getGraphBar() requested an index" << index
			<< QString("that is not in the limits [0, %1)").arg(graph.size());
		return 0;
	}
	return graph.at(index);
}

QVariant EnergyGraph::getMaxValue() const
{
	return max_value;
}

