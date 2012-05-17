#include "energydata.h"
#include "energy_device.h"
#include "devices_cache.h"

#include <stdlib.h> // rand

#include <QDebug> // qDebug
#include <QVector>

#if TEST_ENERGY_DATA
#include <QTimer>
#endif //TEST_ENERGY_DATA


namespace
{
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

	objects << new EnergyData(de, "Electricity", true);
	objects << new EnergyData(de2, "Lights", false);
	objects << new EnergyData(de3, "Appliances", false);
	objects << new EnergyData(de4, "Office", false);
	objects << new EnergyData(de5, "Garden", false);

	objects << new EnergyData(dw, "Water", true);

	return objects;
}


EnergyData::EnergyData(EnergyDevice *_dev, QString _name, bool _general)
{
	name = _name;
	dev = _dev;
	general = _general;
	valueCache.setMaxCost(2000);

#if TEST_ENERGY_DATA
	automatic_updates = new QTimer(this);
	automatic_updates->setInterval(5000);
	connect(automatic_updates, SIGNAL(timeout()), this, SLOT(testAutomaticUpdates()));
#endif
}

EnergyData::~EnergyData()
{
}

QObject *EnergyData::getGraph(GraphType type, QDate date, bool in_currency)
{
	QList<QObject*> values;
	QDate actual_date = normalizeDate(type, date);
	CacheKey key(type, actual_date, in_currency), value_key(type, actual_date);

	if (EnergyGraph *graph = graphCache.value(key))
		// TODO re-request if date includes today
		return graph;

	QVector<qint64> *cached = valueCache.object(value_key);
	if (cached)
		values = createGraph(type, *cached);

	// TODO add in_currency to EnergyGraph

	EnergyGraph *graph = new EnergyGraph(this, type, actual_date, values);

	// TODO re-request if data not in cache or old

	graphCache[key] = graph;
	connect(graph, SIGNAL(destroyed(QObject*)), this, SLOT(graphDestroyed(QObject*)));

#if TEST_ENERGY_DATA
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
		graph_values[i + 1] = rand() % 100;

	cacheGraphData(type, actual_date, graph_values);
#endif

	return graph;
}

QObject *EnergyData::getValue(ValueType type, QDate date, bool in_currency)
{
	QVariant val;
	QDate actual_date = normalizeDate(type, date);
	CacheKey key(type, actual_date, in_currency), value_key(type, actual_date);

	if (EnergyItem *item = itemCache.value(key))
		// TODO re-request if date includes today
		return item;

	QVector<qint64> *cached = valueCache.object(value_key);
	if (cached)
		val = (*cached)[0];

	// TODO add in_currency to EnergyItem

	EnergyItem *value = new EnergyItem(this, type, actual_date, val);

	// TODO re-request if data not in cache or old

	itemCache[key] = value;
	connect(value, SIGNAL(destroyed(QObject*)), this, SLOT(itemDestroyed(QObject*)));

#if TEST_ENERGY_DATA
	cacheValueData(type, actual_date, rand() % 100);
#endif

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
	// TODO
}

void EnergyData::requestCurrentUpdateStop()
{
#if TEST_ENERGY_DATA
	automatic_updates->stop();
#endif
	// TODO
}

QDate EnergyData::normalizeDate(GraphType type, QDate date)
{
	switch (type)
	{
	case DailyAverageGraph:
	case CumulativeDayGraph:
		return date;
	case CumulativeMonthGraph:
		return QDate(date.year(), date.month(), 1);
	case CumulativeYearGraph:
		return QDate();
	}

	Q_ASSERT_X(0, "EnergyData::normalizeDate", "Invalid value for GraphType");
	return QDate();
}

QDate EnergyData::normalizeDate(ValueType type, QDate date)
{
	switch (type)
	{
	case CurrentValue:
		return QDate::currentDate();
	case CumulativeDayValue:
		return date;
	case CumulativeMonthValue:
	case MonthlyAverageValue:
		return QDate(date.year(), date.month(), 1);
	case CumulativeYearValue:
		return QDate();
	}

	Q_ASSERT_X(0, "EnergyData::normalizeDate", "Invalid value for ValueType");
	return QDate();
}

void EnergyData::cacheValueData(ValueType type, QDate date, qint64 value)
{
	// TODO clean up unused cache entries after some time (maybe triggered by object deletion)
	valueCache.insert(CacheKey(type, date), new QVector<qint64>(1, value), 1);

	if (EnergyItem *item = itemCache.value(CacheKey(type, date, false)))
		item->setValue(value);
	if (EnergyItem *item = itemCache.value(CacheKey(type, date, true)))
		item->setValue(value);
}

void EnergyData::cacheGraphData(GraphType type, QDate date, QMap<int, unsigned int> graph)
{
	// TODO clean up unused cache entries after some time (maybe triggered by object deletion)
	QVector<qint64> *values = new QVector<qint64>(graph.size());

	valueCache.insert(CacheKey(type, date), values, graph.size());

	for (int i = 0; i < graph.size(); ++i)
		(*values)[i] = graph[i + 1];

	if (EnergyGraph *graph = graphCache.value(CacheKey(type, date, false)))
		graph->setGraph(createGraph(type, *values));
	if (EnergyGraph *graph = graphCache.value(CacheKey(type, date, true)))
		graph->setGraph(createGraph(type, *values));
}

QList<QObject *> EnergyData::createGraph(GraphType type, const QVector<qint64> &values)
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
		bars.append(new EnergyGraphBar(i, keys[i], values[i]));

	return bars;
}

void EnergyData::graphDestroyed(QObject *obj)
{
	// can't use qobject_cast/dynamic_cast on a destroyed object
	removeValue(graphCache, static_cast<EnergyGraph *>(obj));
}

void EnergyData::itemDestroyed(QObject *obj)
{
	// can't use qobject_cast/dynamic_cast on a destroyed object
	removeValue(itemCache, static_cast<EnergyItem *>(obj));
}

bool EnergyData::isGeneral() const
{
	return general;
}

#if TEST_ENERGY_DATA
void EnergyData::testAutomaticUpdates()
{
	cacheValueData(EnergyData::CurrentValue, QDate(), rand() % 100);
}
#endif

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
	// TODO
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
	// TODO
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
