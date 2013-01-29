#ifndef IMAGESAVER_H
#define IMAGESAVER_H


#include <QObject>
#include <QSize>
#include <QNetworkAccessManager>
#include <QImage>
#include <QTemporaryFile>


// max number of customized images per type per profile retained in extra/12 folder
// it is suggested to set a value equal to at least 2 to avoid "losing" setup
// if application is stopped before configuration files are saved
#define MAX_CUSTOMIZED_IMAGES_PROFILE 3


class QNetworkReply;


int computeMaxId(QString no_id_name);
QString computeSaveFilePath(QString no_id_name, int id);
void cleanOldFiles(QString id_name, int id);


class ImageSaver : public QObject
{
	Q_OBJECT

public:
	explicit ImageSaver(QObject *parent = 0);

	void startDownload(QObject *object, QString property, QString download_url, QString save_file_path, QSize size);

signals:
	void jobDone(ImageSaver *cleanee);

private slots:
	void onFinished(QNetworkReply *);
	void onReadyRead();

private:
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
