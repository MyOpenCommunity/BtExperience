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

	void testCachedValue();
	void testCachedGraph();

private:
	EnergyItem *getValue(EnergyData::ValueType type, QDate date, bool in_currency = false);
	EnergyGraph *getGraph(EnergyData::GraphType type, QDate date, bool in_currency = false);
	EnergyGraphBar *getBar(EnergyGraph *graph, int index);
	QMap<int, unsigned int> graphValues(int size, int start);

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

private:
	EnergyData *obj;
};


class TestEnergyGraph : public TestBtObject
{
	Q_OBJECT

private slots:
	void init();
	void cleanup();

	void testSetGraph();

private:
	EnergyData *obj;
};

#endif
