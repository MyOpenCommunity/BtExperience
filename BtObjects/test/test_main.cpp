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


#include <QtTest/QtTest>
#include <QList>
#include <QRegExp>

#include <iostream>
#include <logger.h>

#include "test_antintrusion_object.h"
#include "test_filebrowser.h"
#include "test_light_objects.h"
#include "test_media_objects.h"
#include "test_alarm_clock.h"
#include "test_messages_system.h"
#include "test_multimedia_player.h"
#include "test_splitscenarios_object.h"
#include "test_thermalprobes_object.h"
#include "test_thermal_objects.h"
#include "test_filebrowser.h"
#include "test_scenario_objects.h"
#include "test_videodoorentry_objects.h"
#include "test_energy_load.h"
#include "test_stopandgo_objects.h"
#include "test_energy_data.h"
#include "test_media_models.h"
#include "test_myhome_models.h"
#include "test_screenstate.h"
#include "main.h"

logger *app_logger;

#define ADD_TEST(klass) \
	klass test##klass##instance; \
	test_list << &test##klass##instance


int main(int argc, char *argv[])
{
	// for filesystem model tests
	qRegisterMetaType<QModelIndex>("QModelIndex");

	QCoreApplication app(argc, argv);
	QList<TestBtObject *> test_list;

	ADD_TEST(TestAntintrusionSystem);
	ADD_TEST(TestAmplifier);
	ADD_TEST(TestPowerAmplifier);
	ADD_TEST(TestSourceAux);
	ADD_TEST(TestSourceRadio);
	ADD_TEST(TestSoundAmbient);
	ADD_TEST(TestAlarmClockBeep);
	ADD_TEST(TestAlarmClockSoundDiffusion);
	ADD_TEST(TestThermalControlUnit4Zones);
	ADD_TEST(TestThermalControlUnit99Zones);
	ADD_TEST(TestThermalControlUnitManual);
	ADD_TEST(TestThermalControlUnitTimedManual);
	ADD_TEST(TestThermalControlUnitScenario);
	ADD_TEST(TestThermalControlUnitProgram);
	ADD_TEST(TestThermalControlUnitVacation);
	ADD_TEST(TestThermalControlUnitHoliday);
	ADD_TEST(TestLight);
	ADD_TEST(TestDimmer);
	ADD_TEST(TestDimmer100);
	ADD_TEST(TestFolderListModel);
	ADD_TEST(TestPagedFolderListModel);
	ADD_TEST(TestFileObject);
	ADD_TEST(TestSplitScenarios);
	ADD_TEST(TestScenarioModule);
	ADD_TEST(TestScenarioAdvanced);
	ADD_TEST(TestScenarioAdvancedTime);
	ADD_TEST(TestScenarioAdvancedDeviceEdit);
	ADD_TEST(TestVideoDoorEntry);
	ADD_TEST(TestEnergyLoadManagement);
	ADD_TEST(TestEnergyLoadManagementWithControlUnit);
	ADD_TEST(TestStopAndGo);
	ADD_TEST(TestStopAndGoPlus);
	ADD_TEST(TestStopAndGoBTest);
	ADD_TEST(TestEnergyItem);
	ADD_TEST(TestEnergyGraph);
	ADD_TEST(TestEnergyData);
	ADD_TEST(TestThermalNonControlledProbes);
	ADD_TEST(TestThermalControlledProbes);
	ADD_TEST(TestThermalControlledProbesFancoil);
	ADD_TEST(TestMediaModel);
	ADD_TEST(TestObjectModel);
	ADD_TEST(TestMultiMediaPlayer);
	ADD_TEST(TestPlaylistPlayer);
	ADD_TEST(TestMessagesSystem);
	ADD_TEST(TestScreenState);

	QStringList arglist = app.arguments();
	if (arglist.contains("--help"))
	{
		std::cout << "Options:" << std::endl;
		std::cout << " --test-class [REGEXP]\trun only tests that matches REGEXP" << std::endl;
		std::cout << " --help\t\t\tprint this help" << std::endl;
		std::cout << std::endl;
		std::cout << "Class List:" << std::endl;
		foreach (TestBtObject *sys, test_list)
			std::cout << " " << sys->metaObject()->className() << std::endl;
		return 0;
	}

	QString testing_class;
	int custom_param_pos = arglist.indexOf("--test-class");
	if (custom_param_pos != -1 && custom_param_pos < arglist.size() - 1)
	{
		testing_class = arglist.at(custom_param_pos + 1);
		arglist.removeAt(custom_param_pos + 1);
		arglist.removeAt(custom_param_pos);
	}

	// use regular expressions to avoid writing the full class name each time
	QRegExp re(testing_class, Qt::CaseInsensitive);
	int r = 0; // test result
	foreach (TestBtObject *tester, test_list)
	{
		QString class_name = tester->metaObject()->className();
		if (testing_class.isEmpty() || class_name.contains(re))
		{
			tester->initTestSystem();
			r += QTest::qExec(tester, arglist);
		}
	}

	// a summary output message to outline if tests passed or not (to avoid to
	// scroll all the tests output to look for eventually failed ones)
	if (r > 0)
		std::cout << "\nSome tests FAILED!!! qExec return value: " << r << "\n\n";
	else
		std::cout << "\nAll tests are OK. Well done!\n\n";
}
