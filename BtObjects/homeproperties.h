/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef HOMEPROPERTIES_H
#define HOMEPROPERTIES_H

#include <QObject>

class ConfigFile;


/*!
	\ingroup Core
	\brief Instantiated as a global \c homeProperties object by the QML plugin.
*/
class HomeProperties : public QObject
{
	Q_OBJECT

	/*!
		\brief Sets or gets the background image used in home and in some other pages.

		Sets or gets the background image used in home and in some other pages. It assumes
		the property value is a path relative to images parent folder or an absolute path.
		Setting this property to the empty string will automatically set the property to
		the default value.
		Beware of that.
	*/
	Q_PROPERTY(QString homeBgImage READ getHomeBgImage WRITE setHomeBgImage NOTIFY homeBgImageChanged)

	/*!
		\brief Sets or gets the skin for the interface.
	*/
	Q_PROPERTY(Skin skin READ getSkin WRITE setSkin NOTIFY skinChanged)

	Q_ENUMS(Skin)

public:
	HomeProperties(QObject *parent = 0);

	enum Skin
	{
		Clear,
		Dark
	};

	static HomeProperties *getHomeProperties();
	static void setHomeProperties(HomeProperties *h);

	QString getHomeBgImage() const;
	void setHomeBgImage(QString new_value);
	Skin getSkin() const;
	void setSkin(Skin s);

signals:
	void homeBgImageChanged();
	void skinChanged();

private:
	QString images_folder, custom_images_folder;
	QString home_bg_image;
	Skin skin;
	ConfigFile *configurations;
	static HomeProperties *the_instance;
};

#endif // HOMEPROPERTIES_H
