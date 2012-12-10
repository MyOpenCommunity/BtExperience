#include "networkmanager.h"
#include "browserproperties.h"

#include <QAuthenticator>
#include <QCoreApplication>
#include <QTime>
#include <QDebug>
#include <QNetworkReply>
#include <QSslSocket>
#include <QSslConfiguration>

#define USER_INPUT_TIMEOUT_MS 30000  // 30 secs

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
	return n;
}


BtNetworkAccessManager::BtNetworkAccessManager(QObject *parent) :
	QNetworkAccessManager(parent)
{
}

void BtNetworkAccessManager::setAuthentication(const QString &user, const QString &pass)
{
	username = user;
	password = pass;
	loop.quit();
}

void BtNetworkAccessManager::abortConnection()
{
	loop.quit();
}

void BtNetworkAccessManager::handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors)
{
	foreach (QSslError e, errors)
		qDebug() << "error:" << int(e.error()) << "string: " << e.errorString();
	qDebug() << "Certificate chain: " << reply->sslConfiguration().peerCertificateChain();
	QSslSocket::addDefaultCaCertificates(reply->sslConfiguration().peerCertificateChain());
	reply->ignoreSslErrors();
}

void BtNetworkAccessManager::requireAuthentication(QNetworkReply *reply, QAuthenticator *auth)
{
	emit credentialsRequired(this, reply);

	loop.exec();
	auth->setUser(username);
	auth->setPassword(password);
}
