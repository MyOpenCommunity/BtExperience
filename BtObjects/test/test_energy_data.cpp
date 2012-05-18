#include "test_energy_data.h"
#include "energyrate.h"
#include "energy_device.h"

#include "objecttester.h"

#include <QTest>


void TestEnergyData::init()
{
	EnergyDevice *d = new EnergyDevice("1", 1);
	EnergyRate *rate = new EnergyRate(0.25);

	obj = new EnergyData(d, "", false, rate);
	dev = new EnergyDevice("1", 1, 1);

	rate->setParent(obj);
}

void TestEnergyData::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
}

EnergyItem *TestEnergyData::getValue(EnergyData::ValueType type, QDate date, bool in_currency)
{
	return qobject_cast<EnergyItem *>(obj->getValue(type, date, in_currency));
}

EnergyGraph *TestEnergyData::getGraph(EnergyData::GraphType type, QDate date, bool in_currency)
{
	return qobject_cast<EnergyGraph *>(obj->getGraph(type, date, in_currency));
}

EnergyGraphBar *TestEnergyData::getBar(EnergyGraph *graph, int index)
{
	return qobject_cast<EnergyGraphBar *>(graph->getGraph()[index]);
}

QMap<int, unsigned int> TestEnergyData::graphValues(int size, int start)
{
	QMap<int, unsigned int> res;

	for (int i = 0; i < size; ++i)
		res[i + 1] = start + i * 100;

	return res;
}

DeviceValues TestEnergyData::makeDeviceValues(int dimension, QDate date, qint64 value)
{
	DeviceValues val;
	QVariant v;

	v.setValue(qMakePair(date, value));
	val[dimension] = v;

	return val;
}

DeviceValues TestEnergyData::makeDeviceValues(int dimension, QDate date, QMap<int, unsigned int> values)
{
	DeviceValues val;
	QVariant v;
	GraphData graph;

	switch (dimension)
	{
	case EnergyDevice::DIM_DAILY_AVERAGE_GRAPH:
		graph.type = EnergyDevice::DAILY_AVERAGE;
		break;
	case EnergyDevice::DIM_DAY_GRAPH:
		graph.type = EnergyDevice::CUMULATIVE_DAY;
		break;
	case EnergyDevice::DIM_CUMULATIVE_MONTH_GRAPH:
		graph.type = EnergyDevice::CUMULATIVE_MONTH;
		break;
	case EnergyDevice::DIM_CUMULATIVE_YEAR_GRAPH:
		graph.type = EnergyDevice::CUMULATIVE_YEAR;
		break;
	default:
		graph.type = static_cast<EnergyDevice::GraphType>(-1);
		Q_ASSERT_X(0, "TestEnergyData::makeDeviceValues", "Invalid dimension value");
	}

	graph.date = date;
	graph.graph = values;

	v.setValue(graph);
	val[dimension] = v;

	return val;
}

void TestEnergyData::testItemGC()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17));
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 04, 17));

	// sanity check
	QVERIFY(o1 != o2);
	QCOMPARE(obj->itemCache.count(), 2);

	delete o1;
	QCOMPARE(obj->itemCache.count(), 1);

	EnergyItem *o3 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17));

	// can't check o3 != o1, because the runtime could reuse the freed memory
	QVERIFY(o2 != o3);
	QCOMPARE(obj->itemCache.count(), 2);
}

void TestEnergyData::testGraphGC()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17));
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 04, 17));

	// sanity check
	QVERIFY(o1 != o2);
	QCOMPARE(obj->graphCache.count(), 2);

	delete o1;
	QCOMPARE(obj->graphCache.count(), 1);

	EnergyGraph *o3 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17));

	// can't check o3 != o1, because the runtime could reuse the freed memory
	QVERIFY(o3 != o2);
	QCOMPARE(obj->graphCache.count(), 2);
}

void TestEnergyData::testItemCache()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), false);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 14), false);
	EnergyItem *o3 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 13), true);
	EnergyItem *o4 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 04, 13), false);

	// check the cache takes into account date and in_currency
	QVERIFY(o1 == o2);
	QVERIFY(o2 != o3);
	QVERIFY(o2 != o4);
	QVERIFY(o3 != o4);
}

void TestEnergyData::testGraphCache()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), false);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 14), false);
	EnergyGraph *o3 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 13), true);
	EnergyGraph *o4 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 04, 13), false);

	// check the cache takes into account date and in_currency
	QVERIFY(o1 == o2);
	QVERIFY(o2 != o3);
	QVERIFY(o2 != o4);
	QVERIFY(o3 != o4);
}

void TestEnergyData::testUpdateItemValue()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), false);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), true);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o1, SIGNAL(valueChanged()));

	obj->cacheValueData(EnergyData::MonthlyAverageValue, QDate(2012, 05, 1), 1236000);
	t1.checkNoSignals();
	t2.checkNoSignals();

	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2012, 04, 1), 1235000);
	t1.checkNoSignals();
	t2.checkNoSignals();

	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2012, 05, 1), 1234000);
	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(1234));
	QCOMPARE(o2->getValue(), QVariant(308.5));
}

void TestEnergyData::testUpdateGraphValue()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), false);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), true);
	ObjectTester t1(o1, SIGNAL(graphChanged()));
	ObjectTester t2(o2, SIGNAL(graphChanged()));

	obj->cacheGraphData(EnergyData::CumulativeDayGraph, QDate(2012, 05, 1), graphValues(3, 10000));
	t1.checkNoSignals();
	t2.checkNoSignals();

	obj->cacheGraphData(EnergyData::CumulativeMonthGraph, QDate(2012, 04, 1), graphValues(3, 9000));
	t1.checkNoSignals();
	t2.checkNoSignals();

	obj->cacheGraphData(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 1), graphValues(3, 8000));
	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getGraph().size(), 3);
	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(8.0));
	QCOMPARE(getBar(o1, 2)->getValue(), QVariant(8.2));

	QCOMPARE(o2->getGraph().size(), 3);
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(2));
	QCOMPARE(getBar(o2, 2)->getValue(), QVariant(2.05));
}

void TestEnergyData::testUpdateYearGraphValue()
{
	CacheKey key(EnergyData::CumulativeYearGraph, QDate(2011, 1, 1));

	QVERIFY(!obj->valueCache.object(key));

	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2011, 5, 1), 10000);

	QVector<double> *values = obj->valueCache.object(key);

	QVERIFY(values);
	QCOMPARE(values->size(), 5);
	QCOMPARE((*values)[0], -1.0);
	QCOMPARE((*values)[4], 10.0);

	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2011, 7, 1), 11000);

	QCOMPARE(values->size(), 7);
	QCOMPARE((*values)[5], -1.0);
	QCOMPARE((*values)[6], 11.0);
}

void TestEnergyData::testCachedValue()
{
	obj->cacheValueData(EnergyData::MonthlyAverageValue, QDate(2012, 05, 1), 1236000);
	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2012, 04, 1), 1235000);
	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2012, 05, 1), 1234000);

	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), false);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), true);

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));
}

void TestEnergyData::testCachedGraph()
{
	obj->cacheGraphData(EnergyData::CumulativeDayGraph, QDate(2012, 05, 1), graphValues(3, 10000));
	obj->cacheGraphData(EnergyData::CumulativeMonthGraph, QDate(2012, 04, 1), graphValues(3, 9000));
	obj->cacheGraphData(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 1), graphValues(3, 8000));

	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), false);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), true);

	QCOMPARE(o1->getGraph().size(), 3);
	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(8.0));
	QCOMPARE(getBar(o1, 2)->getValue(), QVariant(8.2));

	QCOMPARE(o2->getGraph().size(), 3);
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(2));
	QCOMPARE(getBar(o2, 2)->getValue(), QVariant(2.05));
}

void TestEnergyData::testReceiveCurrentValue()
{
	EnergyItem *o1 = getValue(EnergyData::CurrentValue, QDate(), false);
	EnergyItem *o2 = getValue(EnergyData::CurrentValue, QDate(), true);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CURRENT, QDate(), 1234000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));
}

void TestEnergyData::testReceiveCumulativeDayValue()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeDayValue, QDate(2012, 5, 18), false);
	EnergyItem *o2 = getValue(EnergyData::CumulativeDayValue, QDate(2012, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_DAY, QDate(2012, 5, 18), 1234000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));

	// different day: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_DAY, QDate(2012, 5, 17), 1236000));

	t1.checkNoSignals();
	t2.checkNoSignals();
}

void TestEnergyData::testReceiveCumulativeMonthValue()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 5, 18), false);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2012, 5, 17), 1234000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));

	// different month: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2012, 4, 18), 1236000));

	t1.checkNoSignals();
	t2.checkNoSignals();
}

void TestEnergyData::testReceiveCumulativeYearValue()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeYearValue, QDate(2012, 5, 18), false);
	EnergyItem *o2 = getValue(EnergyData::CumulativeYearValue, QDate(2012, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	// TODO current frames only handle last 12 months, not solar year, so date is irrelevant

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_YEAR, QDate::currentDate(), 1234000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));
}

void TestEnergyData::testReceiveMonthlyAverage()
{
	EnergyItem *o1 = getValue(EnergyData::MonthlyAverageValue, QDate(2012, 5, 18), false);
	EnergyItem *o2 = getValue(EnergyData::MonthlyAverageValue, QDate(2012, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_MONTLY_AVERAGE, QDate(2012, 5, 17), 1234000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));

	// different month: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_MONTLY_AVERAGE, QDate(2012, 4, 18), 1236000));

	t1.checkNoSignals();
	t2.checkNoSignals();
}

void TestEnergyData::testReceiveDailyAverageGraph()
{
	EnergyGraph *o1 = getGraph(EnergyData::DailyAverageGraph, QDate(2011, 5, 18), false);
	EnergyGraph *o2 = getGraph(EnergyData::DailyAverageGraph, QDate(2011, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(graphChanged()));
	ObjectTester t2(o2, SIGNAL(graphChanged()));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAILY_AVERAGE_GRAPH, QDate(2011, 5, 18),
					    graphValues(24, 1234000)));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getGraph().size(), 24);
	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(1234.0));
	QCOMPARE(getBar(o1, 23)->getValue(), QVariant(1236.3));

	QCOMPARE(o2->getGraph().size(), 24);
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(308.5));
	QCOMPARE(getBar(o2, 23)->getValue(), QVariant(309.075));

	// different day: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAILY_AVERAGE_GRAPH, QDate(2011, 5, 17),
					    graphValues(24, 1236000)));

	t1.checkNoSignals();
	t2.checkNoSignals();
}

void TestEnergyData::testReceiveCumulativeDayGraph()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeDayGraph, QDate(2011, 5, 18), false);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeDayGraph, QDate(2011, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(graphChanged()));
	ObjectTester t2(o2, SIGNAL(graphChanged()));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAY_GRAPH, QDate(2011, 5, 18),
					    graphValues(24, 1234000)));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getGraph().size(), 24);
	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(1234.0));
	QCOMPARE(getBar(o1, 23)->getValue(), QVariant(1236.3));

	QCOMPARE(o2->getGraph().size(), 24);
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(308.5));
	QCOMPARE(getBar(o2, 23)->getValue(), QVariant(309.075));

	// different day: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAY_GRAPH, QDate(2011, 5, 17),
					    graphValues(24, 1236000)));

	t1.checkNoSignals();
	t2.checkNoSignals();
}

void TestEnergyData::testReceiveCumulativeMonthGraph()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2011, 5, 18), false);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2011, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(graphChanged()));
	ObjectTester t2(o2, SIGNAL(graphChanged()));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH_GRAPH, QDate(2011, 5, 17),
					    graphValues(31, 1234000)));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getGraph().size(), 31);
	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(1234.0));
	QCOMPARE(getBar(o1, 30)->getValue(), QVariant(1237.0));

	QCOMPARE(o2->getGraph().size(), 31);
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(308.5));
	QCOMPARE(getBar(o2, 30)->getValue(), QVariant(309.25));

	// different month: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH_GRAPH, QDate(2011, 4, 18),
					    graphValues(31, 1236000)));

	t1.checkNoSignals();
	t2.checkNoSignals();
}

void TestEnergyData::testReceiveCumulativeYearGraph()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeYearGraph, QDate(2011, 5, 18), false);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeYearGraph, QDate(2011, 5, 18), true);
	ObjectTester t1(o1, SIGNAL(graphChanged()));
	ObjectTester t2(o2, SIGNAL(graphChanged()));

	for (int i = 0; i < 12; ++i)
	{
		t1.checkNoSignals();
		t2.checkNoSignals();

		obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2011, i + 1, 17),
						    1234000 + i * 100));
	}

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getGraph().size(), 12);
	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(1234.0));
	QCOMPARE(getBar(o1, 11)->getValue(), QVariant(1235.1));

	QCOMPARE(o2->getGraph().size(), 12);
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(308.5));
	QCOMPARE(getBar(o2, 11)->getValue(), QVariant(308.775));

	// different year: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2012, 1, 17), 200000));

	t1.checkNoSignals();
	t2.checkNoSignals();

	// no value change: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2011, 1, 17), 1234000));

	t1.checkNoSignals();
	t2.checkNoSignals();

	// different value: update

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2011, 1, 17), 1239000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(1239.0));
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(309.75));
}

void TestEnergyItem::init()
{
	EnergyDevice *d = new EnergyDevice("1", 1);

	obj = new EnergyData(d, "", false, 0);
}

void TestEnergyItem::cleanup()
{
	delete obj->dev;
	delete obj;
}

void TestEnergyItem::testSetValue()
{
	EnergyItem item(obj, EnergyData::CurrentValue, QDate(2012, 05, 16), QVariant());
	ObjectTester tvalid(&item, SIGNAL(validChanged()));
	ObjectTester tvalue(&item, SIGNAL(valueChanged()));

	QCOMPARE(item.isValid(), false);

	item.setValue(1234);
	tvalid.checkSignals();
	tvalue.checkSignals();
	QCOMPARE(item.isValid(), true);

	item.setValue(1235);
	tvalid.checkNoSignals();
	tvalue.checkSignals();
	QCOMPARE(item.isValid(), true);

	item.setValue(1235);
	tvalid.checkNoSignals();
	tvalue.checkNoSignals();
	QCOMPARE(item.isValid(), true);
}

void TestEnergyGraph::init()
{
	EnergyDevice *d = new EnergyDevice("1", 1);

	obj = new EnergyData(d, "", false, 0);
}

void TestEnergyGraph::cleanup()
{
	delete obj->dev;
	delete obj;
}

void TestEnergyGraph::testSetGraph()
{
	EnergyGraph graph(obj, EnergyData::DailyAverageGraph, QDate(2012, 05, 16), QList<QObject *>());
	ObjectTester tvalid(&graph, SIGNAL(validChanged()));
	ObjectTester tvalue(&graph, SIGNAL(graphChanged()));
	QList<QObject *> values, new_values;

	values << new EnergyGraphBar(QVariant("1"), "0-1", QVariant());
	new_values << new EnergyGraphBar(QVariant("1"), "0-1", QVariant(1));

	QCOMPARE(graph.isValid(), false);

	graph.setGraph(values);
	tvalid.checkSignals();
	tvalue.checkSignals();
	QCOMPARE(graph.isValid(), true);

	graph.setGraph(new_values);
	tvalid.checkNoSignals();
	tvalue.checkSignals();
	QCOMPARE(graph.isValid(), true);

	graph.setGraph(new_values);
	tvalid.checkNoSignals();
	tvalue.checkNoSignals();
	QCOMPARE(graph.isValid(), true);
}
