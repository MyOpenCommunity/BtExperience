/*
 * BTouch - Graphical User Interface to control MyHome System
 *
 * Copyright (C) 2010 BTicino S.p.A.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef TEST_ENERGY_DATA_H
#define TEST_ENERGY_DATA_H

#include "test_btobject.h"
#include "energydata.h"

#include <QObject>


class TestEnergyData : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testItemGC();
	void testGraphGC();

	void testItemCache();
	void testGraphCache();

	void testUpdateItemValue();
	void testUpdateGraphValue();
	void testUpdateYearGraphValue();
	void testUpdateLastYearGraphValue();

	void testCachedValue();
	void testCachedGraph();

	void testReceiveCurrentValue();
	void testReceiveCumulativeDayValue();
	void testReceiveCumulativeMonthValue();
	void testReceiveCumulativeYearValue();
	void testReceiveCumulativeLastYearValue();
	void testReceiveMonthlyAverage();

	void testReceiveDailyAverageGraph();
	void testReceiveCumulativeDayGraph();
	void testReceiveCumulativeMonthGraph();
	void testReceiveCumulativeYearGraph();
	void testReceiveCumulativeLastYearGraph();

	void testRequestCurrentUpdateStartStop();

	void testRequestCurrentValue();
	void testRequestCumulativeDayValue();
	void testRequestCumulativeMonthValue();
	void testRequestCumulativeYearValue();
	void testRequestCumulativeLastYearValue();
	void testRequestMonthlyAverage();

	void testRequestDailyAverageGraph();
	void testRequestCumulativeDayGraph();
	void testRequestCumulativeMonthGraph();
	void testRequestCumulativeYearGraph();
	void testRequestCumulativeLastYearGraph();

	// does not re-send a request when one is already pending
	void testDuplicateValueRequests();
	// does not re-send a request when the values are already cached
	void testDuplicateValueRequests2();
	// re-send the request if the time span includes today and the request is old
	void testDuplicateValueRequests3();
	// for year values, only re-sends the request for the month including today
	void testDuplicateValueRequests4();
	// re-send the request if the value is not in cache
	void testDuplicateValueRequests5();

	// same as above but for graphs
	void testDuplicateGraphRequests();
	void testDuplicateGraphRequests2();
	void testDuplicateGraphRequests3();
	void testDuplicateGraphRequests4();
	void testDuplicateGraphRequests5();

	// test thresholds
	void testSetEnableThresholds();
	void testReceiveThresholdValue();
	void testReceiveThresholdLevel();

	// test goals
	void testCheckGoal();
	void testRecheckGoal();
	void testGoalExceeded();
	void testGoalDisabled();

private:
	EnergyItem *getValue(EnergyData::ValueType type, QDate date, EnergyData::MeasureType measure = EnergyData::Consumption);
	EnergyGraph *getGraph(EnergyData::GraphType type, QDate date, EnergyData::MeasureType measure = EnergyData::Consumption);
	void deleteObject(QObject *v);
	EnergyGraphBar *getBar(EnergyGraph *graph, int index);
	QMap<int, unsigned int> graphValues(int size, int start);
	DeviceValues makeDeviceValues(int dimension, QDate date, qint64 value);
	DeviceValues makeDeviceValues(int dimension, QDate date, QMap<int, unsigned int> values);

	QList<QSharedPointer<QObject> > temporary_objects;

	EnergyData *obj;
	EnergyDevice *dev;
};


// tests below are just basic sanity checking

class TestEnergyItem : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testSetValue();
	void testRateChanged();
	void testRequestUpdate();

private:
	EnergyData *obj;
	EnergyDevice *dev;
};


class TestEnergyGraph : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testSetGraph();
	void testRateChanged();
	void testRequestUpdate();

private:
	EnergyData *obj;
	EnergyDevice *dev;
};

#endif
