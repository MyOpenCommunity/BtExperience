#include "homeproperties.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "configfile.h"

#include <QDebug>

#include <QApplication>
#include <QDeclarativeView>
#include <QDeclarativeContext>
#include <QDeclarativeProperty>

#define HOME_BG_CLEAR "images/background/home.jpg"
#define HOME_BG_DARK "images/background/home_dark.jpg"


namespace
{
	enum Parsing
	{
		HomePageContainer = 17
	};

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


HomeProperties::HomeProperties(QObject *parent) : QObject(parent)
{
	configurations = new ConfigFile(this);

	skin = Clear;
	home_bg_image = "images/background/home.jpg";

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			XmlObject v(container);
			foreach (const QDomNode &ist, getChildren(container, "ist"))
			{
				v.setIst(ist);
				setSkin(v.intValue("img_type") == 0 ? Clear : Dark);
				setHomeBgImage(v.value("img"));
			}
			break;
		}
	}

	images_folder = getPath("stockBackgroundImagesFolder");

#if defined(BT_HARDWARE_X11)
	custom_images_folder = getPath("x11PrependPath").mid(1);
#else
	custom_images_folder = getPath("customBackgroundImagesFolder");
#endif
}

QString HomeProperties::getHomeBgImage() const
{
	QString result;

	// if image is set and not a default one, uses it as is
	if (home_bg_image != "" && home_bg_image != HOME_BG_CLEAR && home_bg_image != HOME_BG_DARK)
		result = home_bg_image;
	// if image is not set, uses a default one depending on skin
	else if (getSkin() == Clear)
		result = QString(HOME_BG_CLEAR);
	else
		result = QString(HOME_BG_DARK);

	bool is_custom = (result.indexOf("custom_images/") == 0);

	if (is_custom)
		return custom_images_folder + result;

	return images_folder + result;
}

void HomeProperties::setHomeBgImage(QString new_value)
{
	bool is_custom = (new_value.indexOf("/custom_images/") >= 0);

	QString image_path;
	if (is_custom)
		image_path = new_value.mid(new_value.indexOf("/custom_images/") + 1);
	else
		image_path = new_value.mid(new_value.indexOf("/images/") + 1);

	if (home_bg_image == image_path)
		return;

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			foreach (QDomNode ist, getChildren(container, "ist"))
				setAttribute(ist, "img", image_path);
			break;
		}
	}
	configurations->saveConfiguration(LAYOUT_FILE);

	home_bg_image = image_path;
	emit homeBgImageChanged();
}

HomeProperties::Skin HomeProperties::getSkin() const
{
	return skin;
}

void HomeProperties::setSkin(HomeProperties::Skin s)
{
	if (skin == s)
		return;

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			foreach (QDomNode ist, getChildren(container, "ist"))
				setAttribute(ist, "img_type", QString::number(s == Clear ? 0 : 1));
			break;
		}
	}
	configurations->saveConfiguration(LAYOUT_FILE);

	skin = s;
	emit skinChanged();
}
