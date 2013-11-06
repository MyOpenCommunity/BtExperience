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

#include "imagereader.h"

#include <QImageReader>
#include <QDebug>
#include <QUrl>


QString ImageReader::base_path;
QHash<QString, QSize> ImageReader::size_cache;

ImageReader::ImageReader(QObject *parent) : QObject(parent)
{
}

QString ImageReader::getFileName() const
{
	return filename;
}

void ImageReader::setFileName(const QString &f)
{
	QString filepath = QUrl(f).toLocalFile();

	if (filepath == filename)
		return;

	filename = filepath;
	emit fileNameChanged();

	QSize old_size = size;
	if (size_cache.contains(filename))
	{
		size = size_cache[filename];
	}
	else
	{
		size = QImageReader(filename).size();
		size_cache[filename] = size;
	}

	if (size.width() != old_size.width())
		emit widthChanged();

	if (size.height() != old_size.height())
		emit heightChanged();
}

int ImageReader::getWidth() const
{
	if (filename.isNull())
		return -1;

	return size.width();
}

int ImageReader::getHeight() const
{
	if (filename.isNull())
		return -1;

	return size.height();
}


void ImageReader::setBasePath(const QString &path)
{
	base_path = path;
}


