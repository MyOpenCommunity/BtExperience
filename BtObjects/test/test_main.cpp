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
#include "test_thermalprobes_object.h"
#include "main.h"

logger *app_logger;


int main(int argc, char *argv[])
{
	QCoreApplication app(argc, argv);
	QList<TestBtObject *> test_list;

	TestAntintrusionSystem test_antintrusion_system;
	test_list << &test_antintrusion_system;

	TestThermalProbes test_thermal_probes;
	test_list << &test_thermal_probes;

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
