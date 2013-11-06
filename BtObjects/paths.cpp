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

#include "paths.h"


#include <QDir>
#include <QFileInfo>


#define EXTRA_PATH "/home/bticino/cfg/extra"


namespace path_functions {

QVariantList getX11PrependPath()
{
	QVariantList result;
	// last 2 elements are removed by the getPath function, so adds 2 fake elements
	// to have right path
	result << ".." << ".." << ".." << "bin" << "x86" << "12" << "." << ".";
	return result;
}

QVariantList getDefaultPathAsVariantList(QString base_dir)
{
	QVariantList result;

#if defined(BT_HARDWARE_X11)
	Q_UNUSED(base_dir);
	QString base = getBasePath();
	QStringList base_list = base.split("/");
	foreach (const QString &comp, base_list)
		result.append(comp);
#else
	QString extra = getExtraPath();
	QStringList extra_list = extra.split("/");
	foreach (const QString &comp, extra_list)
		result.append(comp);
	result.append(base_dir);
#endif

	return result;
}

QString getPath(QString property_name)
{
	QVariantList path_list;

	if (property_name.compare("getBackgroundStockImagesFolder") == 0)
		path_list = getBackgroundStockImagesFolder();
	else if (property_name.compare("getX11PrependPath") == 0)
		path_list = getX11PrependPath();
	else if (property_name.compare("getBackgroundCustomImagesFolder") == 0)
		path_list = getBackgroundCustomImagesFolder();
	else
	{
		qWarning() << __PRETTY_FUNCTION__;
		qWarning() << "Property name not recognized (" << property_name << "). Defaulting to empty string.";
		return QString();
	}

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

QString getBasePath()
{
	QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
	path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

	// use canonicalFilePath to resolve symlinks, otherwise some files
	// will be loaded with the symlinked path and some with the canonical
	// path, and this confuses the code that handles ".pragma library"
	QFileInfo base(QDir(path.absoluteFilePath()), "gui/skins/default/");

	if (!base.exists())
		qFatal("Unable to find path for skin files");

	return base.canonicalFilePath() + "/";
}

QString getExtraPath()
{
	QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
	path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

#if defined(BT_HARDWARE_X11)
	QFileInfo extra(QDir(path.absoluteFilePath()), "extra");
#else
	QFileInfo extra(EXTRA_PATH);
#endif

	if (!extra.exists())
		qFatal("Unable to find path for extra files");

	return extra.canonicalFilePath() + "/";
}

QVariantList getCardStockImagesFolder()
{
	QVariantList result = path_functions::getDefaultPathAsVariantList("1");
	result << "images" << "card";
	return result;
}

QVariantList getBackgroundStockImagesFolder()
{
	QVariantList result = path_functions::getDefaultPathAsVariantList("1");
	result << "images" << "background";
	return result;
}

QVariantList getCardCustomImagesFolder()
{
	QVariantList result = path_functions::getDefaultPathAsVariantList("12");
#if defined(BT_HARDWARE_X11)
	result << ".." << ".." << ".." << "bin" << "x86" << "12" << "." << ".";
#endif
	result << "custom_images" << "card";
	return result;
}

QVariantList getBackgroundCustomImagesFolder()
{
	QVariantList result = path_functions::getDefaultPathAsVariantList("12");
#if defined(BT_HARDWARE_X11)
	result << ".." << ".." << ".." << "bin" << "x86" << "12" << "." << ".";
#endif
	result << "custom_images" << "background";
	return result;
}

}
