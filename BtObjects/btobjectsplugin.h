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
class AmplifierGroup;
class SourceUpnpMedia;


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
	AmplifierGroup *general_amplifier;
	HomeProperties home_properties;
	bool is_upnp_source_available;
	SourceUpnpMedia *upnp_sound_source;

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
	void setContainerForLocalSources(int container_uii);
	bool objectLinkWithPosition(ItemInterface *obj);

	QDomDocument findDocumentForId(int id) const;

	int findLinkedUiiForObject(ItemInterface *item) const;
	QPair<QDomNode, QString> findNodeForObject(ItemInterface *item) const;
	QPair<QDomNode, QString> findNodeForUii(int uii) const;
};


#endif // BTOBJECTSPLUGIN_H

