/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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

#ifndef TEST_ENERGY_LOAD_H
#define TEST_ENERGY_LOAD_H

#include "test_btobject.h"

#include <QObject>

class EnergyLoadManagement;
class EnergyLoadManagementWithControlUnit;
class LoadsDevice;


class TestEnergyLoadManagement : public TestBtObject
{
	Q_OBJECT

protected:
	void initObjects(LoadsDevice *dev, EnergyLoadManagement *obj);

private slots:
	void init();
	void cleanup();

	void testReceiveLoadStatus();
	void testReceiveConsumption();
	void testReceiveTotals();

	void testRequestLoadStatus();
	void testRequestTotals();
	void testRequestConsumptionUpdateStartStop();

	void testResetTotal();

private:
	EnergyLoadManagement *obj;
	LoadsDevice *dev;
};


class TestEnergyLoadManagementWithControlUnit : public TestEnergyLoadManagement
{
	Q_OBJECT

private slots:
	void init();

	void testReceiveLoadEnabled();
	void testReceiveLoadForced();

	void testForceOn();
	void testForceOnMinutes();
	void testStopForcing();

private:
	EnergyLoadManagementWithControlUnit *obj;
	LoadsDevice *dev;
};

#endif // TEST_ENERGY_LOAD_H
