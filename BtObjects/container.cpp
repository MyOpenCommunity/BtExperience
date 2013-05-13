#include "container.h"
#include "xml_functions.h"
#include "homeproperties.h"

#include <QDebug>

#include <QApplication>
#include <QDeclarativeView>
#include <QDeclarativeContext>
#include <QDeclarativeProperty>

#define HOME_BG_CLEAR "images/background/home.jpg"
#define HOME_BG_DARK "images/background/home_dark.jpg"


namespace
{
	// I need to find the top QDeclarativeView to obtain the root context;
	// from the root context I will have access to the global property which
	// contains paths for extra dirs
	QDeclarativeView *getDeclarativeView()
	{
		foreach (QWidget *w, qApp->topLevelWidgets())
			if (qobject_cast<QDeclarativeView *>(w))
				return static_cast<QDeclarativeView *>(w);

		return 0;
	}

	QString getPath(QString property_name)
	{
		QDeclarativeView *view = getDeclarativeView();

		if (!view)
			return QString();

		// defines a property on global object to retrieve the path variant list
		QDeclarativeProperty property(qvariant_cast<QObject *>(view->rootContext()->contextProperty("global")), property_name);
		QVariantList path_list = property.read().value<QVariantList>();
		// last 2 elements are meaningless to us
		path_list.removeLast();
		path_list.removeLast();

		// reconstructs the path string skipping empty values
		QString result;
		foreach (QVariant v, path_list) {
			QString s = v.value<QString>();

			if (s.isEmpty())
				continue;

			result.append("/");
			result.append(s);
		}

		result.append("/");

		return result;
	}
}

void updateContainerNameImage(QDomNode node, Container *item)
{
	setAttribute(node, "descr", item->getDescription());
	setAttribute(node, "img", item->getImageConfName());
}

void updateProfileCardImage(QDomNode node, ContainerWithCard *item)
{
	setAttribute(node, "img_card", item->getCardImageConfName());
}


Container::Container(int _id, int _uii, QString _image, QString _description, HomeProperties *_home_properties)
{
	id = _id;
	uii = _uii;
	image = _image;
	description = _description;
	cache_id = 0;
	home_properties = _home_properties;

	connect(this, SIGNAL(descriptionChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(imageChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(cardImageChanged()), this, SIGNAL(cardImageCachedChanged()));

	if (home_properties)
		connect(home_properties, SIGNAL(skinChanged()), this, SIGNAL(imageChanged()));

	images_folder = getPath("stockBackgroundImagesFolder");

#if defined(BT_HARDWARE_X11)
	custom_images_folder = getPath("x11PrependPath").mid(1);
#else
	custom_images_folder = getPath("customBackgroundImagesFolder");
#endif
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
	bool is_custom = (_image.indexOf("/custom_images/") >= 0);

	QString image_path;
	if (is_custom)
		image_path = _image.mid(_image.indexOf("/custom_images/") + 1);
	else
		image_path = _image.mid(_image.indexOf("/images/") + 1);

	if (image == image_path)
		return;

	image = image_path;
	emit imageChanged();
}

QString Container::getImageConfName() const
{
	return image;
}

void Container::setItemOrder(const QList<int> &item_list)
{
	item_order = item_list;
}

QList<int> Container::getItemOrder() const
{
	return item_order;
}

QString Container::getImage() const
{
	QString result;

	// if image is set and not a default one, uses it as is
	if (image != "" && image != HOME_BG_CLEAR && image != HOME_BG_DARK)
	{
		result = image;
	}
	// if image is not set, uses a default one depending on skin
	else if (home_properties)
	{
		if (home_properties->getSkin() == HomeProperties::Clear)
			result = QString(HOME_BG_CLEAR);
		else
			result = QString(HOME_BG_DARK);
	}
	// image is not set, but we don't have a pointer to home page, so uses what it has
	else
	{
		result = image;
	}

	bool is_custom = (result.indexOf("custom_images/") == 0);

	if (is_custom)
		return custom_images_folder + result;

	return images_folder + result;
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


ContainerWithCard::ContainerWithCard(int id, int uii, QString image, QString _card_image, QString description, HomeProperties *_home_properties) :
	Container(id, uii, image, description, _home_properties)
{
	card_image = _card_image;

	connect(this, SIGNAL(cardImageChanged()), this, SIGNAL(persistItem()));
}

void ContainerWithCard::setCardImage(QString image)
{
	bool is_custom = (image.indexOf("/custom_images/") >= 0);

	QString image_path;
	if (is_custom)
		image_path = image.mid(image.indexOf("/custom_images/") + 1);
	else
		image_path = image.mid(image.indexOf("/images/") + 1);

	if (card_image == image_path)
		return;

	card_image = image_path;
	emit cardImageChanged();
}

QString ContainerWithCard::getCardImage() const
{
	bool is_custom = (card_image.indexOf("custom_images/") == 0);

	if (is_custom)
		return custom_images_folder + card_image;

	return images_folder + card_image;
}

QString ContainerWithCard::getCardImageCached() const
{
	return getCardImage() + "?cache_id=" + getCacheId();
}

QString ContainerWithCard::getCardImageConfName() const
{
	return card_image;
}
