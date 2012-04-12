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
#include "test_splitscenarios_object.h"
#include "test_thermalprobes_object.h"
#include "test_thermal_objects.h"

#include "main.h"

logger *app_logger;


int main(int argc, char *argv[])
{
	// for filesystem model tests
	qRegisterMetaType<QModelIndex>("QModelIndex");

	QCoreApplication app(argc, argv);
	QList<TestBtObject *> test_list;

	TestAntintrusionSystem test_antintrusion_system;
	test_list << &test_antintrusion_system;

	TestAmplifier test_amplifier;
	test_list << &test_amplifier;

	TestPowerAmplifier test_power_amplifier;
	test_list << &test_power_amplifier;

	TestSourceAux test_source_aux;
	test_list << &test_source_aux;

	TestSourceRadio test_source_radio;
	test_list << &test_source_radio;

	TestSoundAmbient test_sound_ambient;
	test_list << &test_sound_ambient;

	TestThermalProbes test_thermal_probes;
	test_list << &test_thermal_probes;

	TestThermalControlUnit4Zones test_thermal_control_unit_4z;
	test_list << &test_thermal_control_unit_4z;

	TestThermalControlUnit99Zones test_thermal_control_unit_99z;
	test_list << &test_thermal_control_unit_99z;

	TestThermalControlUnitManual test_thermal_control_unit_manual;
	test_list << &test_thermal_control_unit_manual;

	TestThermalControlUnitTimedManual test_thermal_control_unit_timed_manual;
	test_list << &test_thermal_control_unit_timed_manual;

	TestThermalControlUnitScenario test_thermal_control_unit_scenario;
	test_list << &test_thermal_control_unit_scenario;

	TestThermalControlUnitProgram test_thermal_control_unit_program;
	test_list << &test_thermal_control_unit_program;

	TestThermalControlUnitVacation test_thermal_control_unit_timed_vacation;
	test_list << &test_thermal_control_unit_timed_vacation;

	TestThermalControlUnitHoliday test_thermal_control_unit_timed_holiday;
	test_list << &test_thermal_control_unit_timed_holiday;

	TestLight test_light;
	test_list << &test_light;

	TestDimmer test_dimmer;
	test_list << &test_dimmer;

	TestDimmer100 test_dimmer_100;
	test_list << &test_dimmer_100;

	TestFolderListModel test_folder_model;
	test_list << &test_folder_model;

	TestPagedFolderListModel test_paged_folder_model;
	test_list << &test_paged_folder_model;

	TestFileObject test_file_object;
	test_list << &test_file_object;

	TestSplitScenarios test_split_scenarios;
	test_list << &test_split_scenarios;

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
	foreach (TestBtObject *tester, test_list)
	{
		QString class_name = tester->metaObject()->className();
		if (testing_class.isEmpty() || class_name.contains(re))
		{
			tester->initTestSystem();
			QTest::qExec(tester, arglist);
		}
	}
}
