#include "test_energy_data.h"
#include "energyrate.h"
#include "energy_device.h"

#include "objecttester.h"

#include <QTest>
#include <QtDebug>


namespace
{
	QDate lastNthMonth(int delta)
	{
		QDate date = QDate::currentDate();

		return QDate(date.year(), date.month(), 1).addMonths(-delta);
	}
}

void TestEnergyData::init()
{
	EnergyDevice *d = new EnergyDevice("1", 1);
	EnergyRate *rate = new EnergyRate(0.25);
	QVariantList goals;

	for (int i = 0; i < 12; ++i)
		goals.append(i + 11);

	obj = new EnergyData(d, "", EnergyFamily::Electricity, "kW", goals, true, QVariantList() << false << false, rate, 0);
	dev = new EnergyDevice("1", 1, 1);

	rate->setParent(obj);
}

void TestEnergyData::cleanup()
{
	temporary_objects.clear();
	QCoreApplication::sendPostedEvents(0, QEvent::DeferredDelete);

	delete obj->dev;
	delete obj;
	delete dev;

	clearAllClients();
}

EnergyItem *TestEnergyData::getValue(EnergyData::ValueType type, QDate date, EnergyData::MeasureType measure)
{
	QSharedPointer<QObject> v = obj->getValue(type, date, measure);

	temporary_objects.append(v);

	return qobject_cast<EnergyItem *>(v.data());
}

EnergyGraph *TestEnergyData::getGraph(EnergyData::GraphType type, QDate date, EnergyData::MeasureType measure)
{
	QSharedPointer<QObject> v = obj->getGraph(type, date, measure);

	temporary_objects.append(v);

	return qobject_cast<EnergyGraph *>(v.data());
}

void TestEnergyData::deleteObject(QObject *v)
{
	for (int i = temporary_objects.count() - 1; i >= 0; --i)
	{
		if (temporary_objects[i].data() == v)
			temporary_objects.removeAt(i);
	}
	// force deleteLater() to happen now
	QCoreApplication::sendPostedEvents(0, QEvent::DeferredDelete);
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
	QCOMPARE(obj->item_cache.count(), 2);

	deleteObject(o1);
	QCOMPARE(obj->item_cache.count(), 1);

	EnergyItem *o3 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17));

	// can't check o3 != o1, because the runtime could reuse the freed memory
	QVERIFY(o2 != o3);
	QCOMPARE(obj->item_cache.count(), 2);
}

void TestEnergyData::testGraphGC()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17));
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 04, 17));

	// sanity check
	QVERIFY(o1 != o2);
	QCOMPARE(obj->graph_cache.count(), 2);

	deleteObject(o1);
	QCOMPARE(obj->graph_cache.count(), 1);

	EnergyGraph *o3 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17));

	// can't check o3 != o1, because the runtime could reuse the freed memory
	QVERIFY(o3 != o2);
	QCOMPARE(obj->graph_cache.count(), 2);
}

void TestEnergyData::testItemCache()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 14), EnergyData::Consumption);
	EnergyItem *o3 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 13), EnergyData::Currency);
	EnergyItem *o4 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 04, 13), EnergyData::Consumption);

	// check the cache takes into account date and in_currency
	QVERIFY(o1 == o2);
	QVERIFY(o2 != o3);
	QVERIFY(o2 != o4);
	QVERIFY(o3 != o4);
}

void TestEnergyData::testGraphCache()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 14), EnergyData::Consumption);
	EnergyGraph *o3 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 13), EnergyData::Currency);
	EnergyGraph *o4 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 04, 13), EnergyData::Consumption);

	// check the cache takes into account date and in_currency
	QVERIFY(o1 == o2);
	QVERIFY(o2 != o3);
	QVERIFY(o2 != o4);
	QVERIFY(o3 != o4);
}

void TestEnergyData::testUpdateItemValue()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), EnergyData::Currency);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

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
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), EnergyData::Currency);
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

	QVERIFY(!obj->value_cache.object(key));

	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2011, 5, 1), 10000);

	QVector<double> *values = obj->value_cache.object(key);

	QVERIFY(values);
	QCOMPARE(values->size(), 5);
	QCOMPARE((*values)[0], -1.0);
	QCOMPARE((*values)[4], 10.0);

	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2011, 7, 1), 11000);

	QCOMPARE(values->size(), 7);
	QCOMPARE((*values)[5], -1.0);
	QCOMPARE((*values)[6], 11.0);
}

void TestEnergyData::testUpdateLastYearGraphValue()
{
	CacheKey key(EnergyData::CumulativeLastYearGraph, QDate());

	QVERIFY(!obj->value_cache.object(key));

	obj->cacheValueData(EnergyData::CumulativeMonthValue, lastNthMonth(7), 10000);

	QVector<double> *values = obj->value_cache.object(key);

	QVERIFY(values);
	QCOMPARE(values->size(), 5);
	QCOMPARE((*values)[0], -1.0);
	QCOMPARE((*values)[4], 10.0);

	obj->cacheValueData(EnergyData::CumulativeMonthValue, lastNthMonth(5), 11000);

	QCOMPARE(values->size(), 7);
	QCOMPARE((*values)[5], -1.0);
	QCOMPARE((*values)[6], 11.0);
}

void TestEnergyData::testCachedValue()
{
	obj->cacheValueData(EnergyData::MonthlyAverageValue, QDate(2012, 05, 1), 1236000);
	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2012, 04, 1), 1235000);
	obj->cacheValueData(EnergyData::CumulativeMonthValue, QDate(2012, 05, 1), 1234000);

	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 05, 17), EnergyData::Currency);

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));
}

void TestEnergyData::testCachedGraph()
{
	obj->cacheGraphData(EnergyData::CumulativeDayGraph, QDate(2012, 05, 1), graphValues(3, 10000));
	obj->cacheGraphData(EnergyData::CumulativeMonthGraph, QDate(2012, 04, 1), graphValues(3, 9000));
	obj->cacheGraphData(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 1), graphValues(3, 8000));

	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2012, 05, 17), EnergyData::Currency);

	QCOMPARE(o1->getGraph().size(), 3);
	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(8.0));
	QCOMPARE(getBar(o1, 2)->getValue(), QVariant(8.2));

	QCOMPARE(o2->getGraph().size(), 3);
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(2));
	QCOMPARE(getBar(o2, 2)->getValue(), QVariant(2.05));
}

void TestEnergyData::testReceiveCurrentValue()
{
	EnergyItem *o1 = getValue(EnergyData::CurrentValue, QDate(), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CurrentValue, QDate(), EnergyData::Currency);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	QVERIFY(qobject_cast<EnergyItemCurrent *>(o1));
	QVERIFY(qobject_cast<EnergyItemCurrent *>(o2));

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CURRENT, QDate(), 1234000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(1234.0));
	QCOMPARE(o2->getValue(), QVariant(308.5));
}

void TestEnergyData::testReceiveCumulativeDayValue()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeDayValue, QDate(2012, 5, 18), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CumulativeDayValue, QDate(2012, 5, 18), EnergyData::Currency);
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
	EnergyItem *o1 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 5, 18), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CumulativeMonthValue, QDate(2012, 5, 18), EnergyData::Currency);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	QCOMPARE(o1->getConsumptionGoal(), QVariant(15));

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
	EnergyItem *o1 = getValue(EnergyData::CumulativeYearValue, QDate(2011, 5, 18), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CumulativeYearValue, QDate(2011, 5, 18), EnergyData::Currency);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	for (int i = 0; i < 12; ++i)
	{
		t1.checkNoSignals();
		t2.checkNoSignals();

		obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2011, i + 1, 17),
						    1234000 + i * 100));
	}

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(14814.6));
	QCOMPARE(o2->getValue(), QVariant(3703.65));

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

	QCOMPARE(o1->getValue(), QVariant(14819.6));
	QCOMPARE(o2->getValue(), QVariant(3704.9));
}

void TestEnergyData::testReceiveCumulativeLastYearValue()
{
	EnergyItem *o1 = getValue(EnergyData::CumulativeLastYearValue, QDate(), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::CumulativeLastYearValue, QDate(), EnergyData::Currency);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	for (int i = 0; i < 12; ++i)
	{
		t1.checkNoSignals();
		t2.checkNoSignals();

		obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, lastNthMonth(11 - i),
						    1234000 + i * 100));
	}

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(14814.6));
	QCOMPARE(o2->getValue(), QVariant(3703.65));

	// different year: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2011, 1, 17), 200000));

	t1.checkNoSignals();
	t2.checkNoSignals();

	// no value change: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, lastNthMonth(11), 1234000));

	t1.checkNoSignals();
	t2.checkNoSignals();

	// different value: update

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, lastNthMonth(11), 1239000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(o1->getValue(), QVariant(14819.6));
	QCOMPARE(o2->getValue(), QVariant(3704.9));
}

void TestEnergyData::testReceiveMonthlyAverage()
{
	EnergyItem *o1 = getValue(EnergyData::MonthlyAverageValue, QDate(2012, 5, 18), EnergyData::Consumption);
	EnergyItem *o2 = getValue(EnergyData::MonthlyAverageValue, QDate(2012, 5, 18), EnergyData::Currency);
	ObjectTester t1(o1, SIGNAL(valueChanged()));
	ObjectTester t2(o2, SIGNAL(valueChanged()));

	QCOMPARE(o1->getConsumptionGoal(), QVariant(15));

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
	EnergyGraph *o1 = getGraph(EnergyData::DailyAverageGraph, QDate(2011, 5, 18), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::DailyAverageGraph, QDate(2011, 5, 18), EnergyData::Currency);
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
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeDayGraph, QDate(2011, 5, 18), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeDayGraph, QDate(2011, 5, 18), EnergyData::Currency);
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
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2011, 5, 18), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeMonthGraph, QDate(2011, 5, 18), EnergyData::Currency);
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
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeYearGraph, QDate(2011, 5, 18), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeYearGraph, QDate(2011, 5, 18), EnergyData::Currency);
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

void TestEnergyData::testReceiveCumulativeLastYearGraph()
{
	EnergyGraph *o1 = getGraph(EnergyData::CumulativeLastYearGraph, QDate(), EnergyData::Consumption);
	EnergyGraph *o2 = getGraph(EnergyData::CumulativeLastYearGraph, QDate(), EnergyData::Currency);
	ObjectTester t1(o1, SIGNAL(graphChanged()));
	ObjectTester t2(o2, SIGNAL(graphChanged()));

	for (int i = 0; i < 12; ++i)
	{
		t1.checkNoSignals();
		t2.checkNoSignals();

		obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, lastNthMonth(11 - i),
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

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(2011, 1, 17), 200000));

	t1.checkNoSignals();
	t2.checkNoSignals();

	// no value change: no updates

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, lastNthMonth(11), 1234000));

	t1.checkNoSignals();
	t2.checkNoSignals();

	// different value: update

	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, lastNthMonth(11), 1239000));

	t1.checkSignals();
	t2.checkSignals();

	QCOMPARE(getBar(o1, 0)->getValue(), QVariant(1239.0));
	QCOMPARE(getBar(o2, 0)->getValue(), QVariant(309.75));
}

void TestEnergyData::testRequestCurrentUpdateStartStop()
{
	obj->requestCurrentUpdateStart();
	dev->requestCurrentUpdateStart();
	compareClientCommand();

	obj->requestCurrentUpdateStop();
	dev->requestCurrentUpdateStop();
	obj->dev->flushCurrentUpdateStop();
	dev->flushCurrentUpdateStop();
	compareClientCommand();
}

void TestEnergyData::testRequestCurrentValue()
{
	obj->requestUpdate(EnergyData::CurrentValue, QDate());
	dev->requestCurrent();
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeDayValue()
{
	obj->requestUpdate(EnergyData::CumulativeDayValue, QDate(2012, 5, 17));
	dev->requestCumulativeDay(QDate(2012, 5, 17));
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeMonthValue()
{
	obj->requestUpdate(EnergyData::CumulativeMonthValue, QDate(2012, 4, 17));
	dev->requestCumulativeMonth(QDate(2012, 4, 17));
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeYearValue()
{
	int year = QDate::currentDate().year() - 1;

	obj->requestUpdate(EnergyData::CumulativeYearValue, QDate(year, 5, 17));
	for (int i = 0; i < 12; ++i)
		dev->requestCumulativeMonth(QDate(year, i + 1, 1));
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeLastYearValue()
{
	obj->requestUpdate(EnergyData::CumulativeLastYearValue, QDate());
	for (int i = 0; i < 12; ++i)
		dev->requestCumulativeMonth(QDate::currentDate().addMonths(-i));
	compareClientCommand();
}

void TestEnergyData::testRequestMonthlyAverage()
{
	obj->requestUpdate(EnergyData::MonthlyAverageValue, QDate(2012, 4, 17));
	dev->requestMontlyAverage(QDate(2012, 4, 17));
	compareClientCommand();
}

void TestEnergyData::testRequestDailyAverageGraph()
{
	obj->requestUpdate(EnergyData::DailyAverageGraph, QDate(2012, 4, 17));
	dev->requestDailyAverageGraph(QDate(2012, 4, 17));
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeDayGraph()
{
	obj->requestUpdate(EnergyData::CumulativeDayGraph, QDate(2012, 4, 17));
	dev->requestCumulativeDayGraph(QDate(2012, 4, 17));
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeMonthGraph()
{
	obj->requestUpdate(EnergyData::CumulativeMonthGraph, QDate(2012, 4, 17));
	dev->requestCumulativeMonthGraph(QDate(2012, 4, 17));
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeYearGraph()
{
	int year = QDate::currentDate().year() - 1;

	obj->requestUpdate(EnergyData::CumulativeYearGraph, QDate(year, 5, 17));
	for (int i = 0; i < 12; ++i)
		dev->requestCumulativeMonth(QDate(year, i + 1, 1));
	compareClientCommand();
}

void TestEnergyData::testRequestCumulativeLastYearGraph()
{
	obj->requestUpdate(EnergyData::CumulativeLastYearValue, QDate());
	for (int i = 0; i < 12; ++i)
		dev->requestCumulativeMonth(QDate::currentDate().addMonths(-i));
	compareClientCommand();
}

void TestEnergyData::testDuplicateValueRequests()
{
	QDate date(2012, 5, 17);
	CacheKey key(EnergyData::CumulativeDayValue, date);

	EnergyItem *value = getValue(EnergyData::CumulativeDayValue, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDay(date);
	compareClientCommand();

	EnergyItem *currency = getValue(EnergyData::CumulativeDayValue, date, EnergyData::Currency);

	// request pending, does not send another request to the device
	compareClientCommand(500);

	// receives value, clears request from request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_DAY, date, 1239000));

	QVERIFY(!obj->requests.contains(key));

	QCOMPARE(value->getValue(), QVariant(1239.0));
	QCOMPARE(currency->getValue(), QVariant(309.75));
}

void TestEnergyData::testDuplicateValueRequests2()
{
	QDate date(2012, 5, 17);
	CacheKey key(EnergyData::CumulativeDayValue, date);

	EnergyItem *value = getValue(EnergyData::CumulativeDayValue, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDay(date);
	compareClientCommand();

	// receives value, clears request from request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_DAY, date, 1239000));

	QVERIFY(!obj->requests.contains(key));
	QCOMPARE(value->getValue(), QVariant(1239.0));

	// value cached, does not send another request to the device
	EnergyItem *currency = getValue(EnergyData::CumulativeDayValue, date, EnergyData::Currency);

	compareClientCommand(500);

	QCOMPARE(currency->getValue(), QVariant(309.75));
}

void TestEnergyData::testDuplicateValueRequests3()
{
	QDate date = QDate::currentDate();
	CacheKey key(EnergyData::CumulativeDayValue, date);

	EnergyItem *value = getValue(EnergyData::CumulativeDayValue, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDay(date);
	compareClientCommand();

	// receives value, keeps request in request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_DAY, date, 1239000));

	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Complete);
	QCOMPARE(value->getValue(), QVariant(1239.0));

	// old request including today, re-requests the value
	obj->requests[key].first -= 100000;

	EnergyItem *currency = getValue(EnergyData::CumulativeDayValue, date, EnergyData::Currency);

	dev->requestCumulativeDay(date);
	compareClientCommand();

	QCOMPARE(currency->getValue(), QVariant(309.75));
}

void TestEnergyData::testDuplicateValueRequests4()
{
	QDate date = QDate::currentDate();
	CacheKey key(EnergyData::CumulativeYearValue, QDate(date.year(), 1, 1));
	CacheKey month_key(EnergyData::CumulativeMonthValue, QDate(date.year(), date.month(), 1));

	EnergyItem *value = getValue(EnergyData::CumulativeYearValue, date);

	// values not in cache: update requested and added to request list
	QVERIFY(!obj->requests.contains(key));

	for (int i = 0; i < date.month(); ++i)
		dev->requestCumulativeMonth(QDate(date.year(), i + 1, 1));
	compareClientCommand();

	QVERIFY(!obj->requests.contains(key));
	for (int i = 0; i < date.month(); ++i)
		QVERIFY(obj->requests.contains(CacheKey(EnergyData::CumulativeMonthValue, QDate(date.year(), i + 1, 1))));

	// receives value, keeps only request for current month in request list
	for (int i = 0; i < date.month(); ++i)
		obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(date.year(), i + 1, 1), 1239000));

	QVERIFY(obj->requests.contains(month_key));
	QCOMPARE(obj->requests[month_key].second, EnergyData::Complete);

	QCOMPARE(value->getValue(), QVariant(1239.0 * date.month()));

	// old request including today, re-requests the value for current month only
	obj->requests[month_key].first -= 100000;

	EnergyItem *currency = getValue(EnergyData::CumulativeYearValue, date, EnergyData::Currency);

	dev->requestCumulativeMonth(date);
	compareClientCommand();

	QCOMPARE(currency->getValue(), QVariant(309.75 * date.month()));
}

void TestEnergyData::testDuplicateValueRequests5()
{
	QDate date = QDate::currentDate();
	CacheKey key(EnergyData::CumulativeDayValue, date);

	EnergyItem *value = getValue(EnergyData::CumulativeDayValue, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDay(date);
	compareClientCommand();

	// receives value, keeps request in request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_DAY, date, 1239000));

	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Complete);
	QCOMPARE(value->getValue(), QVariant(1239.0));

	// value removed from cache, re-request
	obj->value_cache.clear();

	EnergyItem *currency = getValue(EnergyData::CumulativeDayValue, date, EnergyData::Currency);

	dev->requestCumulativeDay(date);
	compareClientCommand();

	QCOMPARE(currency->getValue(), QVariant());
}

void TestEnergyData::testDuplicateGraphRequests()
{
	QDate date(2012, 5, 17);
	CacheKey key(EnergyData::CumulativeDayGraph, date);

	EnergyGraph *graph = getGraph(EnergyData::CumulativeDayGraph, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDayGraph(date);
	compareClientCommand();

	EnergyGraph *currency = getGraph(EnergyData::CumulativeDayGraph, date, EnergyData::Currency);

	// request pending, does not send another request to the device
	compareClientCommand(500);

	// receives value, clears request from request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAY_GRAPH, date, graphValues(24, 1000)));

	QVERIFY(!obj->requests.contains(key));

	QCOMPARE(getBar(graph, 2)->getValue(), QVariant(1.2));
	QCOMPARE(getBar(currency, 2)->getValue(), QVariant(0.3));
}

void TestEnergyData::testDuplicateGraphRequests2()
{
	QDate date(2012, 5, 17);
	CacheKey key(EnergyData::CumulativeDayGraph, date);

	EnergyGraph *graph = getGraph(EnergyData::CumulativeDayGraph, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDayGraph(date);
	compareClientCommand();

	// receives value, clears request from request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAY_GRAPH, date, graphValues(24, 1000)));

	QVERIFY(!obj->requests.contains(key));
	QCOMPARE(getBar(graph, 2)->getValue(), QVariant(1.2));

	// value cached, does not send another request to the device
	EnergyGraph *currency = getGraph(EnergyData::CumulativeDayGraph, date, EnergyData::Currency);

	compareClientCommand(500);

	QCOMPARE(getBar(currency, 2)->getValue(), QVariant(0.3));
}

void TestEnergyData::testDuplicateGraphRequests3()
{
	QDate date = QDate::currentDate();
	CacheKey key(EnergyData::CumulativeDayGraph, date);

	EnergyGraph *graph = getGraph(EnergyData::CumulativeDayGraph, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDayGraph(date);
	compareClientCommand();

	// receives value, keeps request in request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAY_GRAPH, date, graphValues(24, 1000)));

	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Complete);
	QCOMPARE(getBar(graph, 2)->getValue(), QVariant(1.2));

	// old request including today, re-requests the value
	obj->requests[key].first -= 100000;

	EnergyGraph *currency = getGraph(EnergyData::CumulativeDayGraph, date, EnergyData::Currency);

	dev->requestCumulativeDayGraph(date);
	compareClientCommand();

	QCOMPARE(getBar(currency, 2)->getValue(), QVariant(0.3));
}

void TestEnergyData::testDuplicateGraphRequests4()
{
	QDate date = QDate::currentDate();
	CacheKey key(EnergyData::CumulativeYearGraph, QDate(date.year(), 1, 1));
	CacheKey month_key(EnergyData::CumulativeMonthValue, QDate(date.year(), date.month(), 1));

	EnergyGraph *graph = getGraph(EnergyData::CumulativeYearGraph, date);

	// values not in cache: update requested and added to request list
	QVERIFY(!obj->requests.contains(key));

	for (int i = 0; i < date.month(); ++i)
		dev->requestCumulativeMonth(QDate(date.year(), i + 1, 1));
	compareClientCommand();

	QVERIFY(!obj->requests.contains(key));
	for (int i = 0; i < date.month(); ++i)
		QVERIFY(obj->requests.contains(CacheKey(EnergyData::CumulativeMonthValue, QDate(date.year(), i + 1, 1))));

	// receives value, keeps only request for current month in request list
	for (int i = 0; i < date.month(); ++i)
		obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, QDate(date.year(), i + 1, 1), 1239000));

	QVERIFY(obj->requests.contains(month_key));
	QCOMPARE(obj->requests[month_key].second, EnergyData::Complete);

	QCOMPARE(getBar(graph, 0)->getValue(), QVariant(1239.0));

	// old request including today, re-requests the value for current month only
	obj->requests[month_key].first -= 100000;

	EnergyGraph *currency = getGraph(EnergyData::CumulativeYearGraph, date, EnergyData::Currency);

	dev->requestCumulativeMonth(date);
	compareClientCommand();

	QCOMPARE(getBar(currency, 0)->getValue(), QVariant(309.75));
}

void TestEnergyData::testDuplicateGraphRequests5()
{
	QDate date = QDate::currentDate();
	CacheKey key(EnergyData::CumulativeDayGraph, date);

	EnergyGraph *graph = getGraph(EnergyData::CumulativeDayGraph, date);

	// values not in cache: update requested and added to request list
	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Pending);

	dev->requestCumulativeDayGraph(date);
	compareClientCommand();

	// receives value, keeps request in request list
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_DAY_GRAPH, date, graphValues(24, 1000)));

	QVERIFY(obj->requests.contains(key));
	QCOMPARE(obj->requests[key].second, EnergyData::Complete);
	QCOMPARE(getBar(graph, 2)->getValue(), QVariant(1.2));

	// value removed from cache, re-request
	obj->value_cache.clear();

	EnergyGraph *currency = getGraph(EnergyData::CumulativeDayGraph, date, EnergyData::Currency);

	dev->requestCumulativeDayGraph(date);
	compareClientCommand();

	QCOMPARE(currency->getGraph().count(), 0);
}

void TestEnergyData::testSetEnableThresholds()
{
	obj->setThresholds(QVariantList() << 0.0 << 0.125);
	// nothing sent (initial state is disabled)
	compareClientCommand();

	obj->setThresholdEnabled(QVariantList() << true << true);
	// only non-zero threshold is set as actually enabled
	dev->setThresholdValue(1, 125);
	compareClientCommand();

	obj->setThresholds(QVariantList() << 0.250 << 0.500);
	dev->setThresholdValue(1, 500);
	compareClientCommand();

	obj->setThresholdEnabled(QVariantList() << true << true);
	dev->setThresholdValue(0, 250);
	compareClientCommand();
}

void TestEnergyData::testReceiveThresholdValue()
{
	ObjectTester t(obj, SIGNAL(thresholdsChanged(QVariantList)));
	DeviceValues v;

	v[EnergyDevice::DIM_THRESHOLD_INDEX] = 0;
	v[EnergyDevice::DIM_THRESHOLD_VALUE] = 500;

	obj->valueReceived(v);
	t.checkSignals();

	QCOMPARE(obj->getThresholds(), QVariantList() << 0.500 << 0.0);

	// ignore 0 threshold value, and assume we will receive a
	// separate notification the threshold has been disabled
	v[EnergyDevice::DIM_THRESHOLD_INDEX] = 0;
	v[EnergyDevice::DIM_THRESHOLD_VALUE] = 0;

	obj->valueReceived(v);
	t.checkNoSignals();

	QCOMPARE(obj->getThresholds(), QVariantList() << 0.500 << 0.0);
}

void TestEnergyData::testReceiveThresholdLevel()
{
	ObjectTester te(obj, SIGNAL(thresholdEnabledChanged(QVariantList)));
	ObjectTester tl(obj, SIGNAL(thresholdLevelChanged(int)));
	DeviceValues v;
	QVariant s;

	s.setValue(QList<int>() << EnergyDevice::THRESHOLD_ENABLED << EnergyDevice::THRESHOLD_DISABLED);
	v[EnergyDevice::DIM_THRESHOLD_STATE] = s;

	obj->valueReceived(v);
	te.checkSignals();
	tl.checkNoSignals();

	QCOMPARE(obj->getThresholdEnabled(), QVariantList() << true << false);
	QCOMPARE(obj->getThresholdLevel(), 0);

	s.setValue(QList<int>() << EnergyDevice::THRESHOLD_EXCEEDED << EnergyDevice::THRESHOLD_DISABLED);
	v[EnergyDevice::DIM_THRESHOLD_STATE] = s;

	obj->valueReceived(v);
	te.checkNoSignals();
	tl.checkSignals();

	QCOMPARE(obj->getThresholdEnabled(), QVariantList() << true << false);
	QCOMPARE(obj->getThresholdLevel(), 1);
}

void TestEnergyData::testCheckGoal()
{
	QDate today = QDate::currentDate();

	obj->checkConsumptionGoals();
	dev->requestCumulativeMonth(today);
	compareClientCommand();
}

void TestEnergyData::testRecheckGoal()
{
	ObjectTester t(obj, SIGNAL(goalExceededChanged()));
	QDate today = QDate::currentDate();

	// check consumption goal
	obj->checkConsumptionGoals();
	dev->requestCumulativeMonth(today);
	compareClientCommand();
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);

	// goal not exceeded
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, today, ((today.month() - 1) + 11) * 1000));
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);

	// goal not exceeded, re-send frame
	obj->checkConsumptionGoals();
	dev->requestCumulativeMonth(today);
	compareClientCommand();
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);

	// goal exceeded
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, today, ((today.month() - 1) + 11 + 1) * 1000));
	t.checkSignals();
	QCOMPARE(obj->getGoalExceeded(), true);
	QCOMPARE(obj->goal_month_check, today.month());

	// goal exceeded, no frame sent
	obj->checkConsumptionGoals();
	compareClientCommand();
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), true);
	QCOMPARE(obj->goal_month_check, today.month());

	// goal excceded last month, reset exceeded and re-send frame
	obj->goal_month_check = today.addMonths(-1).month();

	obj->checkConsumptionGoals();
	dev->requestCumulativeMonth(today);
	compareClientCommand();
	t.checkSignals();
	QCOMPARE(obj->getGoalExceeded(), false);
}

void TestEnergyData::testGoalExceeded()
{
	ObjectTester t(obj, SIGNAL(goalExceededChanged()));
	QDate today = QDate::currentDate();

	// check consumption goal
	obj->checkConsumptionGoals();
	dev->requestCumulativeMonth(today);
	compareClientCommand();
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);
	QCOMPARE(obj->goal_month_check, -1);

	// only check goal for current month
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, today.addMonths(-1), 1000000000));
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);

	// goal not exceeded
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, today, ((today.month() - 1) + 11) * 1000));
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);

	// goal exceeded
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, today, ((today.month() - 1) + 11 + 1) * 1000));
	t.checkSignals();
	QCOMPARE(obj->getGoalExceeded(), true);
	QCOMPARE(obj->goal_month_check, today.month());

	// goal exceeded only once
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, today, ((today.month() - 1) + 11 + 2) * 1000));
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), true);
	QCOMPARE(obj->goal_month_check, today.month());
}

void TestEnergyData::testGoalDisabled()
{
	ObjectTester t(obj, SIGNAL(goalExceededChanged()));
	QDate today = QDate::currentDate();

	obj->goals_enabled = false;

	// check consumption goal
	obj->checkConsumptionGoals();
	compareClientCommand();
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);
	QCOMPARE(obj->goal_month_check, -1);

	// goal would be exceeded if enabled
	obj->valueReceived(makeDeviceValues(EnergyDevice::DIM_CUMULATIVE_MONTH, today, ((today.month() - 1) + 11 + 1) * 1000));
	t.checkNoSignals();
	QCOMPARE(obj->getGoalExceeded(), false);
	QCOMPARE(obj->goal_month_check, -1);
}

void TestEnergyItem::init()
{
	EnergyDevice *d = new EnergyDevice("1", 1);

	obj = new EnergyData(d, "", EnergyFamily::Electricity, "kW", QVariantList(), true, QVariantList(), 0, 0);
	dev = new EnergyDevice("1", 1, 1);
}

void TestEnergyItem::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
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

void TestEnergyItem::testRateChanged()
{
	EnergyRate rate(0.5);
	EnergyItem item(obj, EnergyData::CurrentValue, QDate(2012, 05, 16), QVariant(4), &rate);
	ObjectTester t(&item, SIGNAL(valueChanged()));

	QCOMPARE(item.getValue(), QVariant(2));

	rate.setRate(0.75);
	t.checkSignals();
	QCOMPARE(item.getValue(), QVariant(3));
}

void TestEnergyItem::testRequestUpdate()
{
	EnergyItem item(obj, EnergyData::MonthlyAverageValue, QDate(2012, 05, 16), QVariant());

	item.requestUpdate();
	dev->requestMontlyAverage(QDate(2012, 05, 16));
	compareClientCommand();
}

void TestEnergyGraph::init()
{
	EnergyDevice *d = new EnergyDevice("1", 1);

	obj = new EnergyData(d, "", EnergyFamily::Electricity, "kW", QVariantList(), true, QVariantList(), 0, 0);
	dev = new EnergyDevice("1", 1, 1);
}

void TestEnergyGraph::cleanup()
{
	delete obj->dev;
	delete obj;
	delete dev;
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

void TestEnergyGraph::testRateChanged()
{
	EnergyRate rate(0.5);
	EnergyGraphBar bar(QVariant(), "", QVariant(4), &rate);
	ObjectTester t(&bar, SIGNAL(valueChanged()));

	QCOMPARE(bar.getValue(), QVariant(2));

	rate.setRate(0.75);
	t.checkSignals();
	QCOMPARE(bar.getValue(), QVariant(3));
}

void TestEnergyGraph::testRequestUpdate()
{
	EnergyGraph graph(obj, EnergyData::DailyAverageGraph, QDate(2012, 05, 16), QList<QObject *>());

	graph.requestUpdate();
	dev->requestDailyAverageGraph(QDate(2012, 05, 16));
	compareClientCommand();
}
