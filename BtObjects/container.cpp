#include "container.h"
#include "xml_functions.h"


void updateContainerNameImage(QDomNode node, Container *item)
{
	setAttribute(node, "descr", item->getDescription());
	setAttribute(node, "img", item->getImage());
}

void updateProfileCardImage(QDomNode node, ContainerWithCard *item)
{
	setAttribute(node, "img_card", item->getCardImage());
}


Container::Container(int _id, int _uii, QString _image, QString _description)
{
	id = _id;
	uii = _uii;
	image = _image;
	description = _description;

	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(imageChanged()), this, SIGNAL(persistItem()));
}

int Container::getContainerId() const
{
	return id;
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


ContainerWithCard::ContainerWithCard(int id, int uii, QString image, QString _card_image, QString description) :
	Container(id, uii, image, description)
{
	card_image = _card_image;

	connect(this, SIGNAL(cardImageChanged()), this, SIGNAL(persistItem()));
}

void ContainerWithCard::setCardImage(QString image)
{
	if (image == card_image)
		return;
	card_image = image;
	emit cardImageChanged();
}

QString ContainerWithCard::getCardImage() const
{
	return card_image;
}
