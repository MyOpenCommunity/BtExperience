#ifndef GLOBALMODELS_H
#define GLOBALMODELS_H

#include <QObject>

class MediaDataModel;
class ObjectDataModel;


class GlobalModels : public QObject
{
	Q_OBJECT
	Q_PROPERTY(MediaDataModel *floors READ getFloors CONSTANT)
	Q_PROPERTY(MediaDataModel *rooms READ getRooms CONSTANT)
	Q_PROPERTY(MediaDataModel *objectLinks READ getObjectLinks CONSTANT)
	Q_PROPERTY(ObjectDataModel *myHomeObjects READ getMyHomeObjects CONSTANT)

public:
	GlobalModels();

	void setFloors(MediaDataModel *floors);
	MediaDataModel *getFloors() const;

	void setRooms(MediaDataModel *rooms);
	MediaDataModel *getRooms() const;

	void setObjectLinks(MediaDataModel *object_links);
	MediaDataModel *getObjectLinks() const;

	void setMyHomeObjects(ObjectDataModel *my_home_objects);
	ObjectDataModel *getMyHomeObjects() const;

private:
	MediaDataModel *floors;
	MediaDataModel *rooms;
	MediaDataModel *object_links;
	ObjectDataModel *my_home_objects;
};

#endif // GLOBALMODELS_H
