#include "homeproperties.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "configfile.h"

#include <QDebug>


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
	home_bg_image = "images/background/home.jpg";

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			setSkin(getIntAttribute(container, "img_type", 0) == 0 ? Clear : Dark);
			setHomeBgImage(getAttribute(container, "img"));
			break;
		}
	}
}

QString HomeProperties::getHomeBgImage() const
{
	return home_bg_image;
}

void HomeProperties::setHomeBgImage(QString new_value)
{
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
