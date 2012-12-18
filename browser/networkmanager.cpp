#include "networkmanager.h"
#include "browserproperties.h"
#include "networkreply.h"

#include <QAuthenticator>
#include <QCoreApplication>
#include <QTime>
#include <QDebug>
#include <QNetworkReply>
#include <QSslSocket>
#include <QSslConfiguration>
#include <QFile>
#include <QDir>
#include <QMetaEnum>

#define USER_INPUT_TIMEOUT_MS 30000  // 30 secs
#define DEFAULT_CA_CERT_ADDRESS "http://curl.haxx.se/ca/cacert.pem"
#if defined(BT_HARDWARE_X11)
#define EXTRA_12_PATH "extra/12/"
#else
#define EXTRA_12_PATH "/home/bticino/cfg/extra/12/"
#endif
#define LOG_FAILED_REQUESTS 1


NetworkAccessManagerFactory::NetworkAccessManagerFactory(BrowserProperties *props)
{
	global_properties = props;
}

QNetworkAccessManager *NetworkAccessManagerFactory::create(QObject *parent)
{
	BtNetworkAccessManager *n = new BtNetworkAccessManager(parent);
	QObject::connect(n, SIGNAL(authenticationRequired(QNetworkReply*,QAuthenticator*)),
		n, SLOT(requireAuthentication(QNetworkReply*,QAuthenticator*)));
	QObject::connect(n, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)),
		n, SLOT(handleSslErrors(QNetworkReply*,QList<QSslError>)));
	QObject::connect(n, SIGNAL(credentialsRequired(BtNetworkAccessManager*,QNetworkReply*)),
		global_properties, SLOT(credentialsRequired(BtNetworkAccessManager*,QNetworkReply*)));
	QObject::connect(n, SIGNAL(invalidCertificate(BtNetworkAccessManager*,QNetworkReply*)),
		global_properties, SLOT(certificatesError(BtNetworkAccessManager*,QNetworkReply*)));
	QObject::connect(n, SIGNAL(requestComplete(bool,QString,QString)),
		global_properties, SIGNAL(requestComplete(bool,QString,QString)));
	return n;
}


BtNetworkAccessManager::BtNetworkAccessManager(QObject *parent) :
	QNetworkAccessManager(parent)
{
	// load certificates file if present
	if (QFile(QString(EXTRA_12_PATH) + "cacert.pem").exists())
		QSslSocket::addDefaultCaCertificates(QString(EXTRA_12_PATH) + "cacert.pem");

	// TODO: only update CA certificates every X days
	// TODO: only download the updated certificates once
	QFile ca_conf_file(QString(EXTRA_12_PATH) + "ca_cert_address");
	QByteArray address = DEFAULT_CA_CERT_ADDRESS;
	if (ca_conf_file.open(QIODevice::ReadOnly))
	{
		address = ca_conf_file.readAll();
	}
	QNetworkReply *r = get(QNetworkRequest(QUrl(address)));
	connect(r, SIGNAL(readChannelFinished()), this, SLOT(downloadCaFinished()));

#if LOG_FAILED_REQUESTS
	connect(this, SIGNAL(finished(QNetworkReply*)), this, SLOT(displayErrors(QNetworkReply*)));
#endif
	connect(this, SIGNAL(finished(QNetworkReply*)), this, SLOT(checkSslStatus(QNetworkReply*)));
}

void BtNetworkAccessManager::setAuthentication(const QString &user, const QString &pass)
{
	username = user;
	password = pass;
	loop.quit();
}

void BtNetworkAccessManager::abortConnection()
{
	loop.exit(AbortAuthentication);
}

void BtNetworkAccessManager::addSecurityException()
{
	// TODO: save certificates
	loop.exit(IgnoreCertificateErrors);
}

QNetworkReply *BtNetworkAccessManager::createRequest(QNetworkAccessManager::Operation op, const QNetworkRequest &req, QIODevice *outgoingData)
{
	QNetworkRequest new_req(req);
	QNetworkReply *reply = QNetworkAccessManager::createRequest(op, new_req, outgoingData);

	// BtNetworkReply is used to provide an error page for network errors; this could be done using QWebPage, but it is
	// not accessible from QML and the header for the QML item is private
	return new BtNetworkReply(this, reply);
}

void BtNetworkAccessManager::handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors)
{
	qDebug() << "SSL error for URL" << reply->request().url().toString();
	foreach (QSslError e, errors)
		qDebug() << "error:" << int(e.error()) << "string: " << e.errorString();

	emit invalidCertificate(this, reply);

	if (loop.exec() == IgnoreCertificateErrors)
	{
		reply->ignoreSslErrors();
	}
}

void BtNetworkAccessManager::displayErrors(QNetworkReply *reply)
{
	if (reply->error() != QNetworkReply::NoError)
	{
		int idx = reply->metaObject()->indexOfEnumerator("NetworkError");
		QMetaEnum e = reply->metaObject()->enumerator(idx);

		qWarning() << "Error" << e.key(reply->error()) << "while loading" << reply->request().url().toString();
	}
}

void BtNetworkAccessManager::checkSslStatus(QNetworkReply *reply)
{
	QNetworkReply *wrapped_reply = reply;
	BtNetworkReply *bt_reply = qobject_cast<BtNetworkReply *>(reply);

	if (bt_reply)
		wrapped_reply = bt_reply->originalReply();

	QUrl url = wrapped_reply->request().url();
	QString host = url.port() == -1 ? url.host() : QString("%1:%2port").arg(url.host()).arg(url.port());

	if (wrapped_reply->error() == QNetworkReply::SslHandshakeFailedError ||
	    wrapped_reply->sslConfiguration().peerCertificateChain().size() == 0)
	{
		emit requestComplete(wrapped_reply->request().url().scheme() == "https", host, QString());
		return;
	}

	QSslCertificate cert = wrapped_reply->sslConfiguration().peerCertificate();

	emit requestComplete(true, host, cert.subjectInfo(QSslCertificate::Organization));
}

void BtNetworkAccessManager::requireAuthentication(QNetworkReply *reply, QAuthenticator *auth)
{
	emit credentialsRequired(this, reply);

	if (loop.exec() != AbortAuthentication)
	{
		auth->setUser(username);
		auth->setPassword(password);
	}
}

void BtNetworkAccessManager::downloadCaFinished()
{
	QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());

	if (reply->error() != QNetworkReply::NoError)
	{
		qWarning() << "Error while updating CA sertificates file";
		return;
	}

	QFile cacert(QString(EXTRA_12_PATH) + "cacert.pem");
	QByteArray cert = reply->readAll();
	if (!QDir().mkpath(EXTRA_12_PATH) || !cacert.open(QIODevice::WriteOnly))
		qWarning() << "Cannot open" << cacert.fileName() << "for writing";
	else
		cacert.write(cert);
	QSslSocket::addDefaultCaCertificates(QString(EXTRA_12_PATH) + "cacert.pem");
}
