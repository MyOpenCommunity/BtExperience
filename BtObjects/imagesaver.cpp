#include "imagesaver.h"

#include <QtDebug>
#include <QImage>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QTemporaryFile>
#include <QPainter>
#include <QDir>
#include <QFileInfo>
#include <QStringList>


unsigned int ImageSaver::progressive_id = 0;

ImageSaver::ImageSaver(QObject *parent) :
	QObject(parent)
{
	manager = new QNetworkAccessManager;
	image_buffer = new QImage;
	file = 0;
}

ImageSaver::~ImageSaver()
{
	manager->deleteLater();
	delete image_buffer;
	if (file)
	{
		if (file->isOpen())
			file->close();
		file->deleteLater();
	}
}

void ImageSaver::startDownload(QObject *_object, QString _property, QString download_url, QString _save_file_path, QSize _size)
{
	object = _object;
	property = _property;
	size = _size;
	save_file_path = _save_file_path;

	image_buffer->load(download_url);

	if (image_buffer->isNull())
	{
		QNetworkRequest request;
		request.setUrl(QUrl(download_url));
		reply = manager->get(request);

		file = new QTemporaryFile;
		if (!file->open())
		{
			qWarning() << __PRETTY_FUNCTION__;
			qWarning() << "Error opening temporary file. Aborting";
			emit jobDone(this);
			return;
		}

		connect(reply, SIGNAL(downloadProgress(qint64,qint64)), this, SLOT(onDownloadProgress(qint64,qint64)));
		connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onFinished(QNetworkReply*)));
		connect(reply,SIGNAL(readyRead()),this,SLOT(onReadyRead()));
		connect(reply, SIGNAL(finished()), this, SLOT(onReplyFinished()));

		return;
	}

	computeMaxId();
	computeSaveFilePath();

	saveDestinationFile();
}

void ImageSaver::onDownloadProgress(qint64 bytes_read, qint64 bytes_total)
{
	Q_UNUSED(bytes_read);
	Q_UNUSED(bytes_total);
//	qDebug() << __PRETTY_FUNCTION__;
//	qDebug() << "bytes read so far:" << bytes_read;
//	qDebug() << "total bytes to read:" << bytes_total;
}

void ImageSaver::onFinished(QNetworkReply *reply)
{
	if (reply->error() != QNetworkReply::NoError)
	{
		qWarning() << __PRETTY_FUNCTION__;
		qWarning() << "Error on file download" << reply->errorString();
		emit jobDone(this);
		return;
	}

	image_buffer->load(file->fileName());

	computeMaxId();
	computeSaveFilePath();

	saveDestinationFile();
}

void ImageSaver::onReadyRead()
{
	file->write(reply->readAll());
}

void ImageSaver::onReplyFinished()
{
	//	qDebug() << __PRETTY_FUNCTION__;
}

void ImageSaver::computeMaxId()
{
	QString search_path = save_file_path.mid(save_file_path.lastIndexOf("/") + 1);
	search_path = search_path.left(search_path.lastIndexOf("."));
	search_path.append(QString("_*"));
	search_path.append(save_file_path.mid(save_file_path.lastIndexOf(".")));

	QFileInfo file_info(save_file_path);
	QDir save_dir = file_info.absolutePath();
	QStringList search_list;
	search_list << search_path;
	QStringList file_list = save_dir.entryList(search_list);
	unsigned int max_oid = 0;
	foreach (QString name, file_list) {
		QString oid = name.mid(name.lastIndexOf("_") + 1);
		oid = oid.left(oid.lastIndexOf("."));
		unsigned int uiid = oid.toUInt();
		if (uiid > max_oid)
			max_oid = uiid;
	}
	progressive_id = max_oid + 1;
}

void ImageSaver::cleanOldFiles()
{
	QString search_path = save_file_path.mid(save_file_path.lastIndexOf("/") + 1);
	search_path = search_path.left(search_path.lastIndexOf("_"));
	search_path.append(QString("_*"));
	search_path.append(save_file_path.mid(save_file_path.lastIndexOf(".")));

	QString last_to_one = save_file_path.mid(save_file_path.lastIndexOf("/") + 1);
	last_to_one = last_to_one.left(last_to_one.lastIndexOf("_"));
	last_to_one.append(QString("_%1").arg(progressive_id - 1));
	last_to_one.append(save_file_path.mid(save_file_path.lastIndexOf(".")));

	QFileInfo file_info(save_file_path);
	QDir save_dir = file_info.absolutePath();
	QStringList search_list;
	search_list << search_path;
	QStringList file_list = save_dir.entryList(search_list);
	foreach (QString name, file_list) {
		if (save_file_path.endsWith(name) || name == last_to_one)
			continue;
		save_dir.remove(name);
	}
}

void ImageSaver::computeSaveFilePath()
{
	QString file_path = save_file_path.left(save_file_path.lastIndexOf("."));
	file_path.append(QString("_%1").arg(progressive_id));
	file_path.append(save_file_path.mid(save_file_path.lastIndexOf(".")));
	save_file_path = file_path;
}

void ImageSaver::saveDestinationFile()
{
	if (size.isValid())
	{
		QImage *tmp = new QImage(image_buffer->scaled(size, Qt::KeepAspectRatio));
		delete image_buffer;
		image_buffer = tmp;
	}

	if (image_buffer->isNull())
	{
		qWarning() << __PRETTY_FUNCTION__;
		qWarning() << "Rescale operation failed. Aborting";
		return;
	}

	QImage destImage = QImage(size, image_buffer->format());
	destImage.fill(Qt::black);
	QPoint destPos = QPoint((destImage.width() - image_buffer->width()) / 2, (destImage.height() - image_buffer->height()) / 2);

	QPainter painter(&destImage);
	painter.drawImage(destPos, *image_buffer);
	painter.end();

	destImage.save(save_file_path);

	object->setProperty(property.toLocal8Bit().data(), save_file_path);

	cleanOldFiles();

	emit jobDone(this);
}
