#include "imagereader.h"

#include <QImageReader>
#include <QDebug>
#include <QUrl>


QString ImageReader::base_path;

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
	size = QImageReader(filename).size();

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


