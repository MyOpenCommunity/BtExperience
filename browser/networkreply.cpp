#include "networkreply.h"

#include <QDebug>


namespace
{
	// the explicit newlines are to make the string readable in Qt Linguist
	QString error_page = QT_TRANSLATE_NOOP("BtNetworkAccessManager",
		"<html>\n"
		"<head>\n"
		"<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>\n"
		"<title>Problem loading page</title>\n"
		"</head>\n"
		"<body>\n"
		"<h1>Server not found</h1>\n"
		"<p>Can't find the server at $SERVER. Please try again</p>\n"
		"<hr>\n"
		"<ul>\n"
		"<li>Check the address for typing errors such as <b>ww.example.com</b> instead of <b>www.example.com</b></li>\n"
		"<li>If you are unable to load any pages, check the network connection.</li>\n"
		"</ul>\n"
		"</body>\n"
		"</html>");
}


BtNetworkReply::BtNetworkReply(QObject *parent, QNetworkReply *_reply) :
	QNetworkReply(parent)
{
	reply = _reply;

	setOperation(reply->operation());
	setRequest(reply->request());
	setUrl(reply->url());

	connect(reply, SIGNAL(metaDataChanged()), this, SLOT(updateMetaData()));
	connect(reply, SIGNAL(sslErrors(QList<QSslError>)), this, SIGNAL(sslErrors(QList<QSslError>)));
	connect(reply, SIGNAL(readyRead()), this, SLOT(handleRead()));
	connect(reply, SIGNAL(error(QNetworkReply::NetworkError)),
		this, SLOT(handleError(QNetworkReply::NetworkError)));
	connect(reply, SIGNAL(finished()), this, SIGNAL(finished()));
	connect(reply, SIGNAL(uploadProgress(qint64,qint64)), this, SIGNAL(uploadProgress(qint64,qint64)));
	connect(reply, SIGNAL(downloadProgress(qint64,qint64)), this, SIGNAL(downloadProgress(qint64,qint64)));
	connect(reply, SIGNAL(readChannelFinished()), this, SIGNAL(readChannelFinished()));
	connect(reply, SIGNAL(aboutToClose()), this, SIGNAL(aboutToClose()));

	setOpenMode(ReadOnly);
}

BtNetworkReply::~BtNetworkReply()
{
	delete reply;
}

void BtNetworkReply::abort()
{
	reply->abort();
}

void BtNetworkReply::close()
{
	reply->close();
}

bool BtNetworkReply::isSequential() const
{
	return reply->isSequential();
}

void BtNetworkReply::setReadBufferSize(qint64 size)
{
	QNetworkReply::setReadBufferSize(size);
	reply->setReadBufferSize(size);
}

qint64 BtNetworkReply::bytesAvailable() const
{
	return buffer.size() + QIODevice::bytesAvailable();
}

qint64 BtNetworkReply::bytesToWrite() const
{
	return -1;
}

bool BtNetworkReply::canReadLine() const
{
	qFatal("Not implemented"); // Not used by WebView
	return false;
}

bool BtNetworkReply::waitForReadyRead(int)
{
	qFatal("Not implemented"); // Not used by WebView
	return false;
}

bool BtNetworkReply::waitForBytesWritten(int)
{
	qFatal("Not applicable");
	return false;
}

qint64 BtNetworkReply::readData(char *data, qint64 maxlen)
{
	qint64 size = qMin(maxlen, qint64(buffer.size()));

	memcpy(data, buffer.constData(), size);
	buffer.remove(0, size);

	return size;
}

void BtNetworkReply::ignoreSslErrors()
{
	reply->ignoreSslErrors();
}

void BtNetworkReply::copyHeader(QNetworkRequest::KnownHeaders header)
{
	setHeader(header, reply->header(header));
}

void BtNetworkReply::copyAttribute(QNetworkRequest::Attribute attribute)
{
	setAttribute(attribute, reply->attribute(attribute));
}

void BtNetworkReply::updateMetaData()
{
	foreach(QByteArray header, reply->rawHeaderList())
		setRawHeader(header, reply->rawHeader(header));

	copyHeader(QNetworkRequest::ContentTypeHeader);
	copyHeader(QNetworkRequest::ContentLengthHeader);
	copyHeader(QNetworkRequest::LocationHeader);
	copyHeader(QNetworkRequest::LastModifiedHeader);
	copyHeader(QNetworkRequest::SetCookieHeader);

	copyAttribute(QNetworkRequest::HttpStatusCodeAttribute);
	copyAttribute(QNetworkRequest::HttpReasonPhraseAttribute);
	copyAttribute(QNetworkRequest::RedirectionTargetAttribute);
	copyAttribute(QNetworkRequest::ConnectionEncryptedAttribute);
	copyAttribute(QNetworkRequest::CacheLoadControlAttribute);
	copyAttribute(QNetworkRequest::CacheSaveControlAttribute);
	copyAttribute(QNetworkRequest::SourceIsFromCacheAttribute);
	copyAttribute(QNetworkRequest::DoNotBufferUploadDataAttribute);

	emit metaDataChanged();
}

void BtNetworkReply::handleError(QNetworkReply::NetworkError error_code)
{
	setError(error_code, errorString());

	// if the error response does not ahve any content, use a pre-defined error page
	if (buffer.isEmpty())
	{
		QString temp = error_page;

		temp.replace("$SERVER", reply->request().url().host());

		buffer = temp.toUtf8();
	}

	emit error(error_code);
}

void BtNetworkReply::handleRead()
{
	QByteArray data = reply->readAll();

	buffer += data;
	emit readyRead();
}
