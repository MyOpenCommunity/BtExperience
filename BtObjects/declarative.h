#ifndef DECLARATIVE_H
#define DECLARATIVE_H


#include "homeproperties.h"


#include <QDebug>

#include <QApplication>
#include <QDeclarativeView>
#include <QDeclarativeContext>
#include <QDeclarativeProperty>


QString getPath(QString property_name);
HomeProperties *getHomeProperties();

#endif // DECLARATIVE_H
