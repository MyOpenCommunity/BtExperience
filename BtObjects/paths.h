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

#ifndef PATHS_H
#define PATHS_H


#include <QDebug>

#include <QApplication>
#include <QDeclarativeView>
#include <QDeclarativeContext>
#include <QDeclarativeProperty>


// the following functions are used both in the gui module and in BtObject plugin
// at the moment, we avoided to create a subproject for only those 7 functions
// and we manually put this file (and corresponding compilation unit) on the
// gui, browser and BtObject projects;
// if the need to have a common utility module arises this unit may be moved
// inside such a module (to be included by all)
namespace path_functions {
	QString getPath(QString property_name);
	QString getBasePath();
	QString getExtraPath();
	QVariantList getCardStockImagesFolder();
	QVariantList getBackgroundStockImagesFolder();
	QVariantList getCardCustomImagesFolder();
	QVariantList getBackgroundCustomImagesFolder();
}

#endif // PATHS_H
