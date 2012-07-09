#ifndef CONTAINER_H
#define CONTAINER_H

#include "iteminterface.h"


/*!
	\ingroup Core
	\brief A generic container for ItemInterface%s

	The \ref uii property can be used as a filter criterium for MediaModel.
*/
class Container : public ItemInterface
{
	Q_OBJECT

	/*!
		\brief Container description
	*/
	Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)

	/*!
		\brief Descriptive image
	*/
	Q_PROPERTY(QString image READ getImage WRITE setImage NOTIFY imageChanged)

	/*!
		\brief Numeric identifier for the container type

		Matches the \c id attribute defined in \c layout.xml
	*/
	Q_PROPERTY(int id READ getId CONSTANT)

	/*!
		\brief Unique identifier for this container instance.

		Can be used as a filter criterium for MediaModel.
	*/
	Q_PROPERTY(int uii READ getUii CONSTANT)

	Q_ENUMS(ContainerId)

public:
	enum ContainerId
	{
		IdLights = 1,
		IdRooms,
		IdFloors,
		IdAutomation
	};

	Container(int id, int uii, QString image, QString description);

	int getId() const;

	int getUii() const;

	void setImage(QString image);
	QString getImage() const;

	void setDescription(QString description);
	QString getDescription() const;

signals:
	void descriptionChanged();
	void imageChanged();

private:
	QString description, image;
	int id, uii;
};

#endif // CONTAINER_H
