#include "container.h"
#include "xml_functions.h"


void updateContainerNameImage(QDomNode node, Container *item)
{
	if (!setAttribute(node, "descr", item->getDescription()))
		qWarning("Attribute descr not found in XML node");
	if (!setAttribute(node, "img", item->getImage()))
		qWarning("Attribute img not found in XML node");
}


Container::Container(int _id, int _uii, QString _image, QString _description)
{
	setContainerId(_id);
	uii = _uii;
	image = _image;
	description = _description;

	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(imageChanged()), this, SIGNAL(persistItem()));
}

int Container::getUii() const
{
	return uii;
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
