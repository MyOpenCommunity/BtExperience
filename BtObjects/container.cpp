#include "container.h"


Container::Container(int _id, QString _image, QString _description)
{
	id = _id;
	image = _image;
	description = _description;
}

int Container::getId() const
{
	return id;
}

void Container::setImage(QString _image)
{
	if (image == _image)
		return;

	image = _image;
	emit imageChanged();
}

QString Container::getImage() const
{
	return image;
}

void Container::setDescription(QString _description)
{
	if (description == _description)
		return;

	description = _description;
	emit descriptionChanged();
}

QString Container::getDescription() const
{
	return description;
}
