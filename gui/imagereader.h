#ifndef IMAGEREADER_H
#define IMAGEREADER_H

#include <QObject>
#include <QString>
#include <QSize>


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
	QSize size;
	QString filename;
	static QString base_path;
};


#endif // IMAGEREADER_H
