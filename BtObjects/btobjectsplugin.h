#ifndef BTOBJECTSPLUGIN_H
#define BTOBJECTSPLUGIN_H

#include <QtDeclarative/QDeclarativeExtensionPlugin>

#include "objectmodel.h"
#include "globalmodels.h"
#include "uiimapper.h"

class QDomDocument;
class QDomNode;


class BtObjectsPlugin : public QDeclarativeExtensionPlugin
{
	Q_OBJECT
public:
	BtObjectsPlugin(QObject *parent = 0);

	void initializeEngine(QDeclarativeEngine *engine, const char *uri);
	void registerTypes(const char *uri);

private:
	ObjectDataModel objmodel;
	MediaDataModel room_model, floor_model, object_link_model;
	GlobalModels global_models;
	UiiMapper uii_map;

	// used to parse the made-up configuration we use for testing, remove after switching
	// to the new configuration
	void createObjectsFakeConfig(QDomDocument document);
	void createObjects(QDomDocument document);
	void parseConfig();
	void parseRooms(const QDomNode &container);
	void parseFloors(const QDomNode &container);
	void parseLightSystem(const QDomNode &container);
};


#endif // BTOBJECTSPLUGIN_H

