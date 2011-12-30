#ifndef BTOBJECTSPLUGIN_H
#define BTOBJECTSPLUGIN_H

#include <QtDeclarative/QDeclarativeExtensionPlugin>

#include "objectlistmodel.h"


class BtObjectsPlugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT
public:
    BtObjectsPlugin(QObject *parent = 0);

    void registerTypes(const char *uri);

private:
    ObjectListModel objmodel;

    void createObjects();
};


#endif // BTOBJECTSPLUGIN_H

