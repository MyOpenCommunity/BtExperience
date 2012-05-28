#include "globalmodels.h"


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

void GlobalModels::setObjectLinks(MediaDataModel *_object_links)
{
	object_links = _object_links;
}

MediaDataModel *GlobalModels::getObjectLinks() const
{
	return object_links;
}
