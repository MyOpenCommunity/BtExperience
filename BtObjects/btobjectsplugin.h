#ifndef BTOBJECTSPLUGIN_H
#define BTOBJECTSPLUGIN_H

#include <QtDeclarative/QDeclarativeExtensionPlugin>

#include "objectlistmodel.h"

class QDomDocument;
class QDomNode;


class BtObjectsPlugin : public QDeclarativeExtensionPlugin
{
	Q_OBJECT
public:
	BtObjectsPlugin(QObject *parent = 0);

	void registerTypes(const char *uri);

private:
	ObjectListModel objmodel;
	ObjectListModel room_model;

	// used to parse the made-up configuration we use for testing, remove after switching
	// to the new configuration
	void createObjectsFakeConfig(QDomDocument document);
	void createObjects(QDomDocument document);
	void parseConfig();
	void parseRooms(const QDomNode &container);
};


#endif // BTOBJECTSPLUGIN_H

