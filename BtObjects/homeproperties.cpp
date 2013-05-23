#include "homeproperties.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "configfile.h"
#include "paths.h"

#include <QDebug>

#define HOME_BG_CLEAR "images/background/home.jpg"
#define HOME_BG_DARK "images/background/home_dark.jpg"


namespace
{
	enum Parsing
	{
		HomePageContainer = 17
	};
}


HomeProperties *HomeProperties::the_instance = 0;

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
				// set logic is a bit convoluted here due to the two default
				// backgrounds; to be sure to not lose right config data in
				// set calls let's store the values before setting anything:
				// in this way, member values may change freely during set calls
				QString bg = v.value("img");
				Skin type = v.intValue("img_type") == 0 ? Clear : Dark;
				setSkin(type);
				setHomeBgImage(bg);
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

HomeProperties *HomeProperties::getHomeProperties()
{
	return the_instance;
}

void HomeProperties::setHomeProperties(HomeProperties *h)
{
	the_instance = h;
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
	QString result;

	// if new_value is set and not a default one, uses it as is
	if (new_value != "" && new_value != HOME_BG_CLEAR && new_value != HOME_BG_DARK)
		result = new_value;
	// if new_value is not set, uses a default one depending on skin
	else if (getSkin() == Clear)
		result = QString(HOME_BG_CLEAR);
	else
		result = QString(HOME_BG_DARK);

	bool is_custom = (result.indexOf("custom_images/") >= 0);

	QString image_path;
	if (is_custom)
		image_path = result.mid(result.indexOf("/custom_images/") + 1);
	else
		image_path = result.mid(result.indexOf("/images/") + 1);

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

	// I need this on the following setHomeBgImage call
	skin = s;

	// when changing skin, if home is default it must change to the other default
	if (home_bg_image == HOME_BG_CLEAR || home_bg_image == HOME_BG_DARK)
		s == Clear ? setHomeBgImage(HOME_BG_CLEAR) : setHomeBgImage(HOME_BG_DARK);

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

	emit skinChanged();
}
