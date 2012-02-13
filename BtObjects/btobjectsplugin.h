#ifndef BTOBJECTSPLUGIN_H
#define BTOBJECTSPLUGIN_H

#include <QtDeclarative/QDeclarativeExtensionPlugin>

#include "objectlistmodel.h"

class QDomDocument;


class BtObjectsPlugin : public QDeclarativeExtensionPlugin
{
	Q_OBJECT
public:
	BtObjectsPlugin(QObject *parent = 0);

	void registerTypes(const char *uri);

private:
	ObjectListModel objmodel;

	void createObjects(QDomDocument document);
};


#endif // BTOBJECTSPLUGIN_H

