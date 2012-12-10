#include "networkmanager.h"
#include "browserproperties.h"

#include <QAuthenticator>
#include <QCoreApplication>
#include <QTime>
#include <QDebug>
#include <QNetworkReply>
#include <QSslSocket>
#include <QSslConfiguration>
#include <QFile>

#define USER_INPUT_TIMEOUT_MS 30000  // 30 secs
#define DEFAULT_CA_CERT_ADDRESS "http://curl.haxx.se/ca/cacert.pem"
#if defined(BT_HARDWARE_X11)
#define EXTRA_12_PATH "extra/12/"
#else
#define EXTRA_12_PATH "/home/bticino/cfg/extra/12/"
#endif

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
	return n;
}


BtNetworkAccessManager::BtNetworkAccessManager(QObject *parent) :
	QNetworkAccessManager(parent)
{
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

void BtNetworkAccessManager::handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors)
{
	foreach (QSslError e, errors)
		qDebug() << "error:" << int(e.error()) << "string: " << e.errorString();

	emit invalidCertificate(this, reply);

	if (loop.exec() == IgnoreCertificateErrors)
	{
		reply->ignoreSslErrors();
	}
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
	QFile cacert(QString(EXTRA_12_PATH) + "cacert.pem");
	QByteArray cert = reply->readAll();
	if (!cacert.open(QIODevice::WriteOnly))
		qWarning() << "Cannot open" << cacert.fileName() << "for writing";
	else
		cacert.write(cert);
	QSslSocket::addDefaultCaCertificates(QString(EXTRA_12_PATH) + "cacert.pem");
}
