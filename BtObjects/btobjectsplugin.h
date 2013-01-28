#ifndef BTOBJECTSPLUGIN_H
#define BTOBJECTSPLUGIN_H

#include "objectmodel.h"
#include "globalmodels.h"
#include "uiimapper.h"
#include "homeproperties.h"

#include <QDeclarativeExtensionPlugin>
#include <QDomDocument>
#include <QHash>

class ConfigFile;
class QDomNode;
class QDomDocument;


class BtObjectsPlugin : public QDeclarativeExtensionPlugin
{
	Q_OBJECT
public:
	BtObjectsPlugin(QObject *parent = 0);

	void initializeEngine(QDeclarativeEngine *engine, const char *uri);
	void registerTypes(const char *uri);

private slots:
	void updateNotes();
	void updateObject(ItemInterface *obj);
	void insertObject(ItemInterface *obj);
	void removeObject(ItemInterface *obj);
	void insertObjects(QModelIndex parent, int start, int end);
	void removeObjects(QModelIndex parent, int start, int end);

private:
	ObjectDataModel objmodel;
	MediaDataModel room_model, floor_model, object_link_model, systems_model, note_model, profile_model, media_link_model, media_model;
	GlobalModels global_models;
	UiiMapper uii_map;
	QHash<int, int> uii_to_id;
	ConfigFile *configurations;
	int general_ambient_uii;
	HomeProperties home_properties;

	void createObjects();
	void parseConfig();
	void parseRooms(const QDomNode &container);
	void parseFloors(const QDomNode &container);
	void parseProfiles(const QDomNode &container);
	void parseSystem(const QDomNode &container);
	void parseHomepage(const QDomNode &container);
	void parseMediaLinks(const QDomNode &xml_obj);
	void parseMediaContainers(const QDomNode &container);
	void parseSoundAmbientMulti(const QDomNode &ambient);
	void parseSoundAmbientMono(const QDomNode &ambient);
	void createGeneralAmbient();
	void setContainerForIpRadio(int container_uii);

	QDomDocument findDocumentForId(int id) const;

	int findLinkedUiiForObject(ItemInterface *item) const;
	QPair<QDomNode, QString> findNodeForObject(ItemInterface *item) const;
	QPair<QDomNode, QString> findNodeForUii(int uii) const;
};


#endif // BTOBJECTSPLUGIN_H

