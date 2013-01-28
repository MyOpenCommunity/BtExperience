#include "homeproperties.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "configfile.h"

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


HomeProperties::HomeProperties(QObject *parent) : QObject(parent)
{
	configurations = new ConfigFile(this);

	skin = Clear;
	setHomeBgImage(QString(""));

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			skin = getIntAttribute(container, "img_type", 0) == 0 ? Clear : Dark;
			setHomeBgImage(getAttribute(container, "img"));
			break;
		}
	}

	connect(this, SIGNAL(skinChanged()), this, SLOT(updateHomeBgImageOnSkinChanged()));
}

QString HomeProperties::getHomeBgImage() const
{
	return home_bg_image;
}

void HomeProperties::setHomeBgImage(QString new_value)
{
	if (new_value.isEmpty())
	{
		// empty string means default one which is dependent on skin
		if (getSkin() == Clear)
			new_value = QString(HOME_BG_CLEAR);
		else
			new_value = QString(HOME_BG_DARK);
	}

	if (home_bg_image == new_value)
		return;

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			setAttribute(container, "img", new_value);
			break;
		}
	}
	configurations->saveConfiguration(LAYOUT_FILE);

	home_bg_image = new_value;
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
			setAttribute(container, "img_type", QString::number(s == Clear ? 0 : 1));
			break;
		}
	}
	configurations->saveConfiguration(LAYOUT_FILE);

	skin = s;
	emit skinChanged();
}

void HomeProperties::updateHomeBgImageOnSkinChanged()
{
	QString homeBg = getHomeBgImage();

	// custom bg must not be reset
	if (homeBg != HOME_BG_CLEAR && homeBg != HOME_BG_DARK)
		return;

	// skin changed, default background must be reset
	setHomeBgImage(QString(""));
}
