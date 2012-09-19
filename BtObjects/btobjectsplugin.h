#ifndef BTOBJECTSPLUGIN_H
#define BTOBJECTSPLUGIN_H

#include "objectmodel.h"
#include "globalmodels.h"
#include "uiimapper.h"

#include <QDeclarativeExtensionPlugin>
#include <QDomDocument>
#include <QHash>

class QDomNode;


class BtObjectsPlugin : public QDeclarativeExtensionPlugin
{
	Q_OBJECT
public:
	BtObjectsPlugin(QObject *parent = 0);

	void initializeEngine(QDeclarativeEngine *engine, const char *uri);
	void registerTypes(const char *uri);

private slots:
	void updateObjectName();
	void updateNotes();

private:
	ObjectDataModel objmodel;
	MediaDataModel room_model, floor_model, object_link_model, systems_model, note_model, profile_model, media_link_model;
	GlobalModels global_models;
	UiiMapper uii_map;
	QHash<int, int> uii_to_id;
	QDomDocument archive, layout;

	// used to parse the made-up configuration we use for testing, remove after switching
	// to the new configuration
	void createObjectsFakeConfig(QDomDocument archive);
	void createObjects(QDomDocument archive);
	void parseConfig();
	void parseDevice();
	void parseRooms(const QDomNode &container);
	void parseFloors(const QDomNode &container);
	void parseProfiles(const QDomNode &container);
	void parseSystem(const QDomNode &container);
	void parseMediaLinks(const QDomNode &xml_obj);
};


#endif // BTOBJECTSPLUGIN_H

