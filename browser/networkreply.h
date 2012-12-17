#ifndef NETWORKREPLY_H
#define NETWORKREPLY_H

#include <QNetworkReply>


class BtNetworkReply : public QNetworkReply
{
	Q_OBJECT

public:
	BtNetworkReply(QObject *parent, QNetworkReply *reply);
	~BtNetworkReply();

	// QNetworkReply methods
	virtual void abort();
	virtual void close();
	virtual bool isSequential() const;

	virtual void setReadBufferSize(qint64 size);

	// QIODevice methods
	virtual qint64 bytesAvailable() const;

	virtual qint64 bytesToWrite() const;
	virtual bool canReadLine() const;

	virtual bool waitForReadyRead(int msecs);
	virtual bool waitForBytesWritten(int msecs);

	virtual qint64 readData(char *data, qint64 maxlen);

public slots:
	virtual void ignoreSslErrors();

	void updateMetaData();
	void handleError(QNetworkReply::NetworkError error_code);
	void handleRead();

private:
	void copyHeader(QNetworkRequest::KnownHeaders header);
	void copyAttribute(QNetworkRequest::Attribute attribute);

	QNetworkReply *reply;
	QByteArray buffer;
};

#endif
