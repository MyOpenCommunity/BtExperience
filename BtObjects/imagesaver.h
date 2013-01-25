#ifndef IMAGESAVER_H
#define IMAGESAVER_H


#include <QObject>
#include <QSize>
#include <QNetworkAccessManager>
#include <QImage>
#include <QTemporaryFile>


class QNetworkReply;

class ImageSaver : public QObject
{
	Q_OBJECT

public:
	explicit ImageSaver(QObject *parent = 0);

	void startDownload(QObject *object, QString property, QString download_url, QString save_file_path, QSize size);

signals:
	void jobDone(ImageSaver *cleanee);

private slots:
	void onDownloadProgress(qint64,qint64);
	void onFinished(QNetworkReply *);
	void onReadyRead();
	void onReplyFinished();

private:
	void computeMaxId();
	void cleanOldFiles();
	void computeSaveFilePath();
	void saveDestinationFile();

private:
	QNetworkAccessManager manager;
	QNetworkReply *reply;
	QTemporaryFile file;
	QSize size;
	QString save_file_path;
	QObject *object;
	QString property;
	QImage image_buffer;
	static unsigned int progressive_id;
};

#endif // IMAGESAVER_H
