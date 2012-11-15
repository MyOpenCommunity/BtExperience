#include "container.h"
#include "xml_functions.h"

#include <QDebug>


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
	cache_id = 0;

	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(imageChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(cardImageChanged()), this, SIGNAL(cardImageCachedChanged()));
}

void Container::setCacheDirty()
{
	++cache_id;
	emit cardImageCachedChanged();
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

QString Container::getCardImage() const
{
	return getImage();
}

QString Container::getCardImageCached() const
{
	return getImage() + "?cache_id=" + getCacheId();
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

QString Container::getCacheId() const
{
	return QString("%1").arg(cache_id);
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

QString ContainerWithCard::getCardImageCached() const
{
	return getCardImage() + "?cache_id=" + getCacheId();
}
