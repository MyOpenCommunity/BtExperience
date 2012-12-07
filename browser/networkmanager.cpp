#include "networkmanager.h"
#include "browserproperties.h"

#include <QAuthenticator>
#include <QCoreApplication>
#include <QTime>
#include <QDebug>
#include <QNetworkReply>
#include <QSslError>

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

void BtNetworkAccessManager::setUsername(const QString &user)
{
	qDebug() << "Username" << user;
	username = user;
}

void BtNetworkAccessManager::setPassword(const QString &pass)
{
	qDebug() << "password:" << password;
	password = pass;
}

void BtNetworkAccessManager::handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors)
{
	foreach (QSslError e, errors)
		qDebug() << "error:" << e.error() << "string: " << e.errorString();
	reply->ignoreSslErrors();
}

void BtNetworkAccessManager::requireAuthentication(QNetworkReply *reply, QAuthenticator *auth)
{
	emit credentialsRequired(this, reply);
	QTime timeout;
	timeout.start();
	while (username.isEmpty() && password.isEmpty() && timeout.elapsed() < USER_INPUT_TIMEOUT_MS)
		QCoreApplication::processEvents();
	if (timeout.elapsed() > USER_INPUT_TIMEOUT_MS)
		qWarning() << "Timeout while waiting for username and password";
	auth->setUser(username);
	auth->setPassword(password);
}
