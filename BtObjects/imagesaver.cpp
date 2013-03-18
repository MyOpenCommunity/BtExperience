#include "imagesaver.h"

#include "generic_functions.h"

#include <QtDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QPainter>
#include <QDir>
#include <QFileInfo>
#include <QStringList>


int computeMaxId(QString no_id_name)
{
	QString search_path = no_id_name.mid(no_id_name.lastIndexOf("/") + 1);
	search_path = search_path.left(search_path.lastIndexOf("."));
	search_path.append(QString("_*"));

	QFileInfo file_info(no_id_name);
	QDir save_dir = file_info.absolutePath();
	QStringList search_list;
	foreach (QString extension, getFileExtensions(EntryInfo::IMAGE))
		search_list << search_path + extension;
	QStringList file_list = save_dir.entryList(search_list);
	unsigned int max_oid = 0;
	foreach (QString name, file_list) {
		QString oid = name.mid(name.lastIndexOf("_") + 1);
		oid = oid.left(oid.lastIndexOf("."));
		unsigned int uiid = oid.toUInt();
		if (uiid > max_oid)
			max_oid = uiid;
	}
	return max_oid;
}

QString computeSaveFilePath(QString no_id_name, int id)
{
	QString file_path = no_id_name.left(no_id_name.lastIndexOf("."));
	file_path.append(QString("_%1").arg(id));
	file_path.append(no_id_name.mid(no_id_name.lastIndexOf(".")));
	return file_path;
}

void cleanOldFiles(QString id_name, int id)
{
	QString search_path = id_name.mid(id_name.lastIndexOf("/") + 1);
	search_path = search_path.left(search_path.lastIndexOf("_"));
	search_path.append(QString("_*.*"));

	QStringList survivors;
	QString survivor_base;
	for (int i = 0; i < MAX_CUSTOMIZED_IMAGES_PROFILE; ++i)
	{
		survivor_base = id_name.mid(id_name.lastIndexOf("/") + 1);
		survivor_base = survivor_base.left(survivor_base.lastIndexOf("_"));
		survivor_base.append(QString("_%1.").arg(id - i));

		foreach (QString extension, getFileExtensions(EntryInfo::IMAGE))
			survivors << survivor_base + extension;
	}

	QFileInfo file_info(id_name);
	QDir save_dir = file_info.absolutePath();
	QStringList search_list;
	search_list << search_path;
	QStringList file_list = save_dir.entryList(search_list);
	foreach (QString name, file_list) {
		if (survivors.contains(name))
			continue;
		save_dir.remove(name);
	}
}


unsigned int ImageSaver::progressive_id = 0;

ImageSaver::ImageSaver(QObject *parent) :
	QObject(parent)
{
}

void ImageSaver::startDownload(QObject *_object, QString _property, QString download_url, QString _save_file_path, QSize _size)
{
	object = _object;
	property = _property;
	size = _size;
	save_file_path = _save_file_path;

	image_buffer.load(download_url);

	if (image_buffer.isNull())
	{
		QNetworkRequest request;
		request.setUrl(QUrl(download_url));
		reply = manager.get(request);

		if (!file.open())
		{
			qWarning() << __PRETTY_FUNCTION__;
			qWarning() << "Error opening temporary file. Aborting";
			emit jobDone(this);
			return;
		}

		connect(&manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(onFinished(QNetworkReply*)));
		connect(reply,SIGNAL(readyRead()),this,SLOT(onReadyRead()));

		return;
	}

	progressive_id = computeMaxId(save_file_path) + 1;
	save_file_path = computeSaveFilePath(save_file_path, progressive_id);

	saveDestinationFile();
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

	image_buffer.load(file.fileName());

	progressive_id = computeMaxId(save_file_path) + 1;
	save_file_path = computeSaveFilePath(save_file_path, progressive_id);

	saveDestinationFile();
}

void ImageSaver::onReadyRead()
{
	file.write(reply->readAll());
}

void ImageSaver::saveDestinationFile()
{
	// size argument is optional, if specified rescales image to desired size
	if (size.isValid())
		image_buffer = image_buffer.scaled(size, Qt::KeepAspectRatio);

	if (image_buffer.isNull())
	{
		qWarning() << __PRETTY_FUNCTION__;
		qWarning() << "Rescale operation failed. Aborting";
		return;
	}

	QImage destImage = QImage(size, image_buffer.format());
	destImage.fill(Qt::black);
	QPoint destPos = QPoint((destImage.width() - image_buffer.width()) / 2, (destImage.height() - image_buffer.height()) / 2);

	QPainter painter(&destImage);
	painter.drawImage(destPos, image_buffer);
	painter.end();

	destImage.save(save_file_path);

	object->setProperty(property.toLocal8Bit().data(), save_file_path);

	cleanOldFiles(save_file_path, progressive_id);

	emit jobDone(this);
}
