#include "globalmodels.h"
#include "note.h"
#include "medialink.h"


GlobalModels::GlobalModels()
{
	floors = 0;
	rooms = 0;
}

void GlobalModels::setFloors(MediaDataModel *_floors)
{
	floors = _floors;
}

MediaDataModel *GlobalModels::getFloors() const
{
	return floors;
}

void GlobalModels::setRooms(MediaDataModel *_rooms)
{
	rooms = _rooms;
}

MediaDataModel *GlobalModels::getRooms() const
{
	return rooms;
}

void GlobalModels::setSystems(MediaDataModel *_systems)
{
	systems = _systems;
}

MediaDataModel *GlobalModels::getSystems() const
{
	return systems;
}

void GlobalModels::setObjectLinks(MediaDataModel *_object_links)
{
	object_links = _object_links;
}

MediaDataModel *GlobalModels::getObjectLinks() const
{
	return object_links;
}

void GlobalModels::setMyHomeObjects(ObjectDataModel *_my_home_objects)
{
	my_home_objects = _my_home_objects;
}

ObjectDataModel *GlobalModels::getMyHomeObjects() const
{
	return my_home_objects;
}

void GlobalModels::setNotes(MediaDataModel *_notes)
{
	notes = _notes;
}

MediaDataModel *GlobalModels::getNotes() const
{
	return notes;
}

Note *GlobalModels::createNote(int profile_uii, QString text)
{
	return new Note(profile_uii, text);
}

MediaLink *GlobalModels::createQuicklink(int profile_uii, QString mediaType, QString name, QString address)
{
	MediaLink::MediaType t = MediaLink::Web; // defaults to web link
	if (QString::compare("camera", mediaType, Qt::CaseInsensitive) == 0)
		t = MediaLink::Camera;
	if (QString::compare("web page", mediaType, Qt::CaseInsensitive) == 0)
		t = MediaLink::Web;
	if (QString::compare("web camera", mediaType, Qt::CaseInsensitive) == 0)
		t = MediaLink::Webcam;
	if (QString::compare("rss", mediaType, Qt::CaseInsensitive) == 0)
		t = MediaLink::Rss;
	if (QString::compare("weather", mediaType, Qt::CaseInsensitive) == 0)
		t = MediaLink::BtObject;
	if (QString::compare("scenario", mediaType, Qt::CaseInsensitive) == 0)
		t = MediaLink::BtObject;

	return new MediaLink(profile_uii, t, name, address, QPoint(200, 200));
}

void GlobalModels::setProfiles(MediaDataModel *_profiles)
{
	profiles = _profiles;
}

MediaDataModel *GlobalModels::getProfiles() const
{
	return profiles;
}

void GlobalModels::setMediaLinks(MediaDataModel *_media_links)
{
	media_links = _media_links;
}

MediaDataModel *GlobalModels::getMediaLinks() const
{
	return media_links;
}
