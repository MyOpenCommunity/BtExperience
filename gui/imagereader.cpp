#include "imagereader.h"

#include <QImageReader>
#include <QSize>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QDir>


QString ImageReader::images_path;

ImageReader::ImageReader(QObject *parent) : QObject(parent)
{
}

QString ImageReader::getFileName() const
{
	return filename;
}

void ImageReader::setFileName(const QString &f)
{
	if (f == filename)
		return;

	filename = f;
	emit fileNameChanged();

	QSize new_size = QImageReader(images_path + QDir::separator() + filename).size();
	size = new_size;

	if (size.width() != new_size.width())
		emit widthChanged();

	if (size.height() != new_size.height())
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


void ImageReader::setImagesPath(const QString &path)
{
	images_path = path;
}


