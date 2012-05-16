#include "energydata.h"
#include "energy_device.h"
#include "devices_cache.h"

#include <stdlib.h> // rand

#include <QDebug> // qDebug

#if TEST_ENERGY_DATA
#include <QTimer>
#endif //TEST_ENERGY_DATA


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


EnergyData::EnergyData(EnergyDevice *_dev, QString _name, bool general)
{
	name = _name;
	dev = _dev;
	this->general = general;
}

QObject *EnergyData::getGraph(GraphType type, QDate date, bool inCurrency)
{
	Q_UNUSED(inCurrency);

	QList<QObject*> values;
	QStringList keys;
	QDate actual_date = normalizeDate(type, date);

#if TEST_ENERGY_DATA
	int count = 0;

	switch (type)
	{
	case DailyAverageGraph:
	case CumulativeDayGraph:
		count = 24;
		for(int i = 0; i < count; ++i)
			keys << QString("%1-%2").arg(i).arg(i + 1);
		break;
	case CumulativeMonthGraph:
		count = date.daysInMonth();
		for(int i = 0; i < count; ++i)
			keys << QString::number(i + 1);
		break;
	case CumulativeYearGraph:
		count = 12;
		keys << tr("January") << tr("February") << tr("March")
			 << tr("April") << tr("May") << tr("June")
			 << tr("July") << tr("August") << tr("September")
			 << tr("October") << tr("November") << tr("December");
		break;
	}

	for (int i = 0; i < count; ++i)
		values.append(new EnergyGraphBar(i, keys[i], QVariant(rand() % 100)));
#endif

	EnergyGraph *graph = new EnergyGraph(this, type, actual_date, values);

	return graph;
}

QObject *EnergyData::getValue(ValueType type, QDate date, bool inCurrency)
{
	Q_UNUSED(inCurrency);

	QVariant val = QVariant(0);
	QDate actual_date = normalizeDate(type, date);

#if TEST_ENERGY_DATA
	val = QVariant(rand() % 100);
#endif

	EnergyItem *value = new EnergyItem(this, type, actual_date, val);

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
	// TODO
}

void EnergyData::requestCurrentUpdateStop()
{
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
	case MonthlyAverage:
		return QDate(date.year(), date.month(), 1);
	case CumulativeYearValue:
		return QDate();
	}

	Q_ASSERT_X(0, "EnergyData::normalizeDate", "Invalid value for ValueType");
	return QDate();
}

void EnergyData::graphDestroyed(QObject *obj)
{
	Q_UNUSED(obj);
	// TODO
}

void EnergyData::itemDestroyed(QObject *obj)
{
	Q_UNUSED(obj);
	// TODO
}

bool EnergyData::isGeneral() const
{
	return general;
}

EnergyItem::EnergyItem(EnergyData *_data, EnergyData::ValueType _type, QDate _date, QVariant _value)
{
	data = _data;
	type = _type;
	date = _date;
	value = _value;

#if TEST_ENERGY_DATA
	if (type == EnergyData::CurrentValue)
	{
		timer = new QTimer(this);
		timer->setInterval(1000);
		connect(timer, SIGNAL(timeout()), SLOT(timerEvent()));
		timer->start();
	}
#endif //TEST_ENERGY_DATA
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

void EnergyItem::setValue(QVariant value)
{
	if(this->value == value)
		return;
	this->value = value;
	emit valueChanged();
}

EnergyGraph::EnergyGraph(EnergyData *_data, EnergyData::GraphType _type, QDate _date, QList<QObject*> _graph)
{
	data = _data;
	type = _type;
	date = _date;
	graph = _graph;
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

void EnergyItem::timerEvent()
{
	value = QVariant(rand() % 100);
	emit valueChanged();
}
