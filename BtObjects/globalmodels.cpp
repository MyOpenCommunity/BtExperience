#include "globalmodels.h"
#include "note.h"
#include "medialink.h"
#include "objectlink.h"
#include "alarmclock.h"


GlobalModels::GlobalModels()
{
	floors = 0;
	rooms = 0;
	object_links = 0;
	systems = 0;
	my_home_objects = 0;
	notes = 0;
	profiles = 0;
	media_links = 0;
	media_containers = 0;
	homepage_links = 0;
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

ItemInterface *GlobalModels::createQuicklink(int profile_uii, QString mediaType, QString name, QString address, ObjectInterface *btObject, int x, int y)
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

	if (t == MediaLink::Camera)
		return new ObjectLink(btObject, t, x, y, profile_uii);

	return new MediaLink(profile_uii, t, name, address, QPoint(x, y));
}

ItemInterface *GlobalModels::createAlarmClock()
{
	return new AlarmClock("new alarm clock", false, AlarmClock::AlarmClockBeep, 0, 0, 0);
}

void GlobalModels::setProfiles(MediaDataModel *_profiles)
{
	profiles = _profiles;
}

MediaDataModel *GlobalModels::getProfiles() const
{
	return profiles;
}

void GlobalModels::setMediaContainers(MediaDataModel *_media_containers)
{
	media_containers = _media_containers;
}

MediaDataModel *GlobalModels::getMediaContainers() const
{
	return media_containers;
}

void GlobalModels::setHomepageLinks(Container *_homepage_links)
{
	homepage_links = _homepage_links;
}

Container *GlobalModels::getHomepageLinks() const
{
	return homepage_links;
}

void GlobalModels::setMediaLinks(MediaDataModel *_media_links)
{
	media_links = _media_links;
}

MediaDataModel *GlobalModels::getMediaLinks() const
{
	return media_links;
}
