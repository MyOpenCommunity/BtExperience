#ifndef GLOBALMODELS_H
#define GLOBALMODELS_H

#include <QObject>

class MediaDataModel;
class ObjectDataModel;
class Note;


/*!
	\ingroup Core
	\brief Instantiated as a global \c myHomeModels object by the QML plugin.
*/
class GlobalModels : public QObject
{
	Q_OBJECT

	/*!
		\brief Floors defined by \c layout.xml

		List of Container objects, \ref ItemInterface::containerId is -1.

		The \ref Container::uii field can be used to filter the \ref rooms model.

		\sa rooms
	*/
	Q_PROPERTY(MediaDataModel *floors READ getFloors CONSTANT)

	/*!
		\brief Rooms defined by \c layout.xml

		List of Container objects, \ref ItemInterface::containerId is the containing floor

		The \ref Container::uii field can be used to filter the \ref objectLinks model.

		\sa floors
	*/
	Q_PROPERTY(MediaDataModel *rooms READ getRooms CONSTANT)

	/*!
		\brief Subsystem containers defined by \c layout.xml

		List of Container objects, \ref ItemInterface::containerId is -1.

		The \ref Container::uii field can be used to filter the \ref myHomeObjects model.

		\sa myHomeObjects
	*/
	Q_PROPERTY(MediaDataModel *systems READ getSystems CONSTANT)

	/*!
		\brief MyHome objects contained in a room

		List of ObjectLink objects, \ref ItemInterface::containerId is the containing room.

		\sa rooms
		\sa myHomeObjects
	*/
	Q_PROPERTY(MediaDataModel *objectLinks READ getObjectLinks CONSTANT)

	/*!
		\brief All the MyHome objects defined by \c archive.xml

		List of ObjectInterface objects, \ref ItemInterface::containerId is the containing system.

		Can be filtered by the Container%s defined in \ref systems.

		\sa systems
		\sa objectLinks
	*/
	Q_PROPERTY(ObjectDataModel *myHomeObjects READ getMyHomeObjects CONSTANT)

	/*!
		\brief User-defined notes

		List of Note objects, \ref ItemInterface::containerId is the containing profile.

		Can be filtered by the Container%s defined in \ref profiles.

		\sa profiles
	*/
	Q_PROPERTY(MediaDataModel *notes READ getNotes CONSTANT)

	/*!
		\brief List of user profiles

		List of Container objects, \ref ItemInterface::containerId is -1.

		\sa notes
		\sa mediaLinks
	*/
	Q_PROPERTY(MediaDataModel *profiles READ getProfiles CONSTANT)

	/*!
		\brief List of user profiles

		List of MediaLink objects, \ref ItemInterface::containerId is the containing profile.

		\sa profiles
		\sa notes
	*/
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

	/*!
		\brief Create a new note instance

		Example (QML):

		\verbatim
		userNotes.append(myHomeModels.createNote(profile.uii, textEdit.text))
		\endverbatim
	*/
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
