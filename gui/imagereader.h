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

#ifndef IMAGEREADER_H
#define IMAGEREADER_H

#include <QObject>
#include <QString>
#include <QSize>
#include <QHash>


// A simply wrapper around a QImageReader, used to retrieve the original size of
// an image from qml.
class ImageReader : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString fileName READ getFileName WRITE setFileName NOTIFY fileNameChanged)
	Q_PROPERTY(int width READ getWidth NOTIFY widthChanged)
	Q_PROPERTY(int height READ getHeight NOTIFY heightChanged)

public:
	ImageReader(QObject *parent = 0);

	QString getFileName() const;
	void setFileName(const QString &f);
	int getWidth() const;
	int getHeight() const;

	static void setBasePath(const QString &path);

signals:
	void fileNameChanged();
	void widthChanged();
	void heightChanged();

private:
	static QHash<QString, QSize> size_cache;
	QSize size;
	QString filename;
	static QString base_path;
};


#endif // IMAGEREADER_H
