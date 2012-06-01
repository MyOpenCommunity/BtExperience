#ifndef GLOBALMODELS_H
#define GLOBALMODELS_H

#include <QObject>

class MediaDataModel;
class ObjectDataModel;
class Note;


class GlobalModels : public QObject
{
	Q_OBJECT
	Q_PROPERTY(MediaDataModel *floors READ getFloors CONSTANT)
	Q_PROPERTY(MediaDataModel *rooms READ getRooms CONSTANT)
	Q_PROPERTY(MediaDataModel *systems READ getSystems CONSTANT)
	Q_PROPERTY(MediaDataModel *objectLinks READ getObjectLinks CONSTANT)
	Q_PROPERTY(ObjectDataModel *myHomeObjects READ getMyHomeObjects CONSTANT)
	Q_PROPERTY(MediaDataModel *notes READ getNotes CONSTANT)
	Q_PROPERTY(MediaDataModel *profiles READ getProfiles CONSTANT)
	Q_PROPERTY(MediaDataModel *mediaLinks READ getMediaLinks CONSTANT)

public:
	GlobalModels();

	void setFloors(MediaDataModel *floors);
	MediaDataModel *getFloors() const;

	void setRooms(MediaDataModel *rooms);
	MediaDataModel *getRooms() const;

	void setSystems(MediaDataModel *systems);
	MediaDataModel *getSystems() const;

	void setObjectLinks(MediaDataModel *object_links);
	MediaDataModel *getObjectLinks() const;

	void setMyHomeObjects(ObjectDataModel *my_home_objects);
	ObjectDataModel *getMyHomeObjects() const;

	void setNotes(MediaDataModel *notes);
	MediaDataModel *getNotes() const;

	Q_INVOKABLE Note *createNote(int profile_id, QString text);

	void setProfiles(MediaDataModel *profiles);
	MediaDataModel *getProfiles() const;

	void setMediaLinks(MediaDataModel *media_links);
	MediaDataModel *getMediaLinks() const;

private:
	MediaDataModel *floors;
	MediaDataModel *rooms;
	MediaDataModel *object_links;
	MediaDataModel *systems;
	ObjectDataModel *my_home_objects;
	MediaDataModel *notes;
	MediaDataModel *profiles;
	MediaDataModel *media_links;
};

#endif // GLOBALMODELS_H
