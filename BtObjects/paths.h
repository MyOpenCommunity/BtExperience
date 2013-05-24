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
