#include "globalmodels.h"
#include "note.h"


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

Note *GlobalModels::createNote(int profile_id, QString text)
{
	return new Note(profile_id, text);
}
