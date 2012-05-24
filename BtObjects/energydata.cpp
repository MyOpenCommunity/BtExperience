#include "energydata.h"
#include "energyrate.h"
#include "energy_device.h"
#include "devices_cache.h"

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
#define VALUE_CACHE_MAX_COST 2000


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
		}

		Q_ASSERT_X(0, "EnergyData::normalizeDate", "Invalid value for ValueType");
		return QDate();
	}

	// retuns true is the time interval for the value includes today
	bool dateContainsToday(int type, QDate date)
	{
		return date == normalizeDate(type, QDate::currentDate());
	}
}


QList<ObjectInterface *> createEnergyData(const QDomNode &xml_node, int id)
{
	Q_UNUSED(xml_node);
	Q_UNUSED(id);

	QList<ObjectInterface *> objects;

	EnergyDevice *de = bt_global::add_device_to_cache(new EnergyDevice("77", 1));
	EnergyDevice *de2 = bt_global::add_device_to_cache(new EnergyDevice("79", 1));
	EnergyDevice *de3 = bt_global::add_device_to_cache(new EnergyDevice("80", 1));
	EnergyDevice *de4 = bt_global::add_device_to_cache(new EnergyDevice("81", 1));
	EnergyDevice *de5 = bt_global::add_device_to_cache(new EnergyDevice("82", 1));

	EnergyDevice *dw = bt_global::add_device_to_cache(new EnergyDevice("78", 2));

	EnergyRate *r1 = new EnergyRate(0.2);

	objects << new EnergyData(de, "Electricity", true, r1);
	objects << new EnergyData(de2, "Lights", false, r1);
	objects << new EnergyData(de3, "Appliances", false, r1);
	objects << new EnergyData(de4, "Office", false, r1);
	objects << new EnergyData(de5, "Garden", false, r1);

	objects << new EnergyData(dw, "Water", true, r1);

	return objects;
}


EnergyData::EnergyData(EnergyDevice *_dev, QString _name, bool _general, EnergyRate *_rate)
{
	name = _name;
	dev = _dev;
	general = _general;
	rate = _rate;
	value_cache.setMaxCost(VALUE_CACHE_MAX_COST);

#if TEST_ENERGY_DATA
	automatic_updates = new QTimer(this);
	automatic_updates->setInterval(5000);
	connect(automatic_updates, SIGNAL(timeout()), this, SLOT(testAutomaticUpdates()));
#endif

	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));

	if (rate)
		connect(rate, SIGNAL(rateChanged()), this, SLOT(rateChanged()));
}

EnergyData::~EnergyData()
{
	foreach (EnergyItem *value, item_cache.values())
		delete value;
	foreach (EnergyGraph *graph, graph_cache.values())
		delete graph;
}

QObject *EnergyData::getGraph(GraphType type, QDate date, bool in_currency)
{
	if (in_currency && !rate)
		return 0;

	QList<QObject*> values;
	QDate actual_date = normalizeDate(type, date);
	CacheKey key(type, actual_date, in_currency), value_key(type, actual_date);

	if (EnergyGraph *graph = graph_cache.value(key))
	{
		// re-request for cached timespans that include today's value
		if (dateContainsToday(type, actual_date))
			requestUpdate(type, actual_date);

		return graph;
	}

	QVector<double> *cached = value_cache.object(value_key);
	// for cumulative year graph we might have some valid values received as part of navigating month graphs
	if (cached && (type != CumulativeYearGraph || checkYearGraphDataIsValid(date, *cached)))
		values = createGraph(type, *cached, in_currency ? rate->getRate() : 1.0);

	// TODO add in_currency to EnergyGraph

	EnergyGraph *graph = new EnergyGraph(this, type, actual_date, values);

	graph_cache[key] = graph;
	connect(graph, SIGNAL(destroyed(QObject*)), this, SLOT(graphDestroyed(QObject*)));

	// re-request for cached timespans that include today's value
	if (!cached || dateContainsToday(type, actual_date))
		requestUpdate(type, actual_date);

	return graph;
}

QObject *EnergyData::getValue(ValueType type, QDate date, bool in_currency)
{
	if (in_currency && !rate)
		return 0;

	QVariant val;
	QDate actual_date = normalizeDate(type, date);
	CacheKey key(type, actual_date, in_currency), value_key(type, actual_date);

	if (EnergyItem *item = item_cache.value(key))
	{
		// re-request for cached timespans that include today's value
		if (dateContainsToday(type, actual_date))
			requestUpdate(type, actual_date);

		return item;
	}

	QVector<double> *cached = value_cache.object(value_key);
	if (cached)
		val = in_currency ? (*cached)[0] * rate->getRate() : (*cached)[0];

	// TODO add in_currency to EnergyItem

	EnergyItem *value = new EnergyItem(this, type, actual_date, val);

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
	QStringList result;

	switch (dev->getEnergyType())
	{
	case 1:
		result << "Electricity";
		break;
	case 2:
		result << "Water";
		break;
	case 3:
		result << "Gas";
		break;
	case 4:
		result << "HotWater";
		break;
	case 5:
		result << "Heat";
		break;
	}

	if(isGeneral())
		result << "general";
	else
		result << "line";

	return result.join(",");
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

void EnergyData::requestCurrentUpdateStart()
{
#if TEST_ENERGY_DATA
	automatic_updates->start();
#endif
	dev->requestCurrentUpdateStart();
}

void EnergyData::requestCurrentUpdateStop()
{
#if TEST_ENERGY_DATA
	automatic_updates->stop();
#endif
	dev->requestCurrentUpdateStop();
}

void EnergyData::cacheValueData(ValueType type, QDate date, qint64 value)
{
	// TODO clean up unused cache entries after some time (maybe triggered by object deletion)
	// for electricity, the device returns values in watts, but the GUI always displays kilowatts,
	// so it's easier to do the conversion here
	double conversion = getEnergyType() == Electricity ? 1000.0 : 1.0;
	value_cache.insert(CacheKey(type, date), new QVector<double>(1, value / conversion), 1);

	// update values in returned EnergyItem objects
	if (EnergyItem *item = item_cache.value(CacheKey(type, date, false)))
		item->setValue(value / conversion);
	if (EnergyItem *item = item_cache.value(CacheKey(type, date, true)))
		item->setValue(value / conversion * rate->getRate());

	// see comment in valueReceived()
	if (type == CumulativeMonthValue)
		cacheYearGraphData(date, value / conversion);
}

void EnergyData::cacheGraphData(GraphType type, QDate date, QMap<int, unsigned int> graph)
{
	// TODO clean up unused cache entries after some time (maybe triggered by object deletion)
	// for electricity, the device returns values in watts, but the GUI always displays kilowatts,
	// so it's easier to do the conversion here
	double conversion = getEnergyType() == Electricity ? 1000.0 : 1.0;
	QVector<double> *values = new QVector<double>(graph.size());

	value_cache.insert(CacheKey(type, date), values, graph.size());

	for (int i = 0; i < graph.size(); ++i)
		(*values)[i] = graph[i + 1] / conversion;

	// update values in returned EnergyGraph objects
	if (EnergyGraph *graph = graph_cache.value(CacheKey(type, date, false)))
		graph->setGraph(createGraph(type, *values));
	if (EnergyGraph *graph = graph_cache.value(CacheKey(type, date, true)))
		graph->setGraph(createGraph(type, *values, rate->getRate()));
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
		graph->setGraph(createGraph(CumulativeYearGraph, *values, rate->getRate()));
	// update cumulative year value objects
	if (EnergyItem *value = item_cache.value(CacheKey(CumulativeYearValue, actual_date, false)))
		value->setValue(cumulative_value);
	if (EnergyItem *value = item_cache.value(CacheKey(CumulativeYearValue, actual_date, true)))
		value->setValue(cumulative_value * rate->getRate());
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

QList<QObject *> EnergyData::createGraph(GraphType type, const QVector<double> &values, double conversion)
{
	QList<QObject *> bars;
	QList<QString> keys;

	switch (type)
	{
	case DailyAverageGraph:
	case CumulativeDayGraph:
		for(int i = 0; i < values.count(); ++i)
			keys << QString("%1-%2").arg(i).arg(i + 1);
		break;
	case CumulativeMonthGraph:
		for(int i = 0; i < values.count(); ++i)
			keys << QString::number(i + 1);
		break;
	case CumulativeYearGraph:
		keys << tr("January") << tr("February") << tr("March")
			 << tr("April") << tr("May") << tr("June")
			 << tr("July") << tr("August") << tr("September")
			 << tr("October") << tr("November") << tr("December");
		break;
	}

	for (int i = 0; i < values.count(); ++i)
		bars.append(new EnergyGraphBar(i, keys[i], values[i] * conversion));

	return bars;
}

void EnergyData::requestUpdate(int type, QDate date, bool force)
{
	CacheKey key(type, normalizeDate(type, date));
	quint64 msec_now = QDateTime::currentMSecsSinceEpoch();

	if (type != CumulativeYearGraph && type != CumulativeYearValue && !force)
	{
		// there is a cached response and the timespan does not include today
		if (!dateContainsToday(type, key.date) && value_cache.contains(key))
			return;

		if (requests.contains(key))
		{
			// there is a pending request for this value
			if (!requests[key].second)
				return;

			// the timespan includes today but there was a request less than 60 seconds ago
			if (msec_now - requests[key].first < CURRENT_VALUE_EXPIRATION_MSECS && value_cache.contains(key))
				return;
		}
	}

	if (type != CumulativeYearGraph && type != CumulativeYearValue)
		requests[key] = qMakePair(msec_now, false);

#if TEST_ENERGY_DATA
	switch (type)
	{
	case CurrentValue:
	case CumulativeDayValue:
	case CumulativeMonthValue:
	case MonthlyAverageValue:
	{
		DelayedSlotCaller * caller = new DelayedSlotCaller;
		caller->setSlot(this, SLOT(testValueData(EnergyData::ValueType,QDate)), 500);
		caller->addArgument(type);
		caller->addArgument(key.date);
	}
		break;
	case DailyAverageGraph:
	case CumulativeDayGraph:
	case CumulativeMonthGraph:
	{
		DelayedSlotCaller * caller = new DelayedSlotCaller;
		caller->setSlot(this, SLOT(testGraphData(EnergyData::GraphType,QDate)), 500);
		caller->addArgument(type);
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
		requestCumulativeYear(key.date, force);
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
		requestCumulativeYear(key.date, force);
		break;
	case MonthlyAverageValue:
		dev->requestMontlyAverage(key.date);
		break;
	}
}

void EnergyData::requestCumulativeYear(QDate date, bool force)
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
			requestUpdate(CumulativeMonthValue, month, force);
	}
}

void EnergyData::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
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
				requests[CacheKey(type, date)].second = true;

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
				requests[CacheKey(type, date)].second = true;

			cacheGraphData(type, date, data.graph);
		}
			break;
		}
		++it;
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

void EnergyData::rateChanged()
{
	// TODO update rates in cached objects
}

bool EnergyData::isGeneral() const
{
	return general;
}

#if TEST_ENERGY_DATA
namespace
{
	int valueRange(EnergyData::EnergyType type)
	{
		return type == EnergyData::Electricity ? 3000 : 100;
	}
}

void EnergyData::testValueData(ValueType type, QDate date)
{
	// mirrors the logic in valueReceived()
	if (!dateContainsToday(type, date))
		requests.remove(CacheKey(type, date));
	else
		requests[CacheKey(type, date)].second = true;

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
		count = 12;
		break;
	}

	for (int i = 0; i < count; ++i)
		graph_values[i + 1] = rand() % valueRange(getEnergyType());

	// mirrors the logic in valueReceived()
	if (!dateContainsToday(type, date))
		requests.remove(CacheKey(type, date));
	else
		requests[CacheKey(type, date)].second = true;

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

EnergyItem::EnergyItem(EnergyData *_data, EnergyData::ValueType _type, QDate _date, QVariant _value)
{
	data = _data;
	type = _type;
	date = _date;
	value = _value;
}

QVariant EnergyItem::getValue() const
{
	return value;
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
	data->requestUpdate(type, date, true);
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

EnergyGraph::EnergyGraph(EnergyData *_data, EnergyData::GraphType _type, QDate _date, QList<QObject*> _graph)
{
	data = _data;
	type = _type;
	date = _date;
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
	data->requestUpdate(type, date, true);
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
	foreach (QObject *bar, graph)
		bar->setParent(this);

	if (!valid && isValid())
		emit validChanged();
	emit graphChanged();
}
