#include "networkmanager.h"
#include "browserproperties.h"
#include "networkreply.h"
#include "configfile.h"
#include "xml_functions.h"

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
#define BROWSER_DATA_PATH "./"
#define BROWSER_FILE "browser.xml"
#else
#define BROWSER_DATA_PATH "/home/bticino/cfg/extra/12/"
#define BROWSER_FILE "/home/bticino/cfg/extra/12/browser.xml"
#endif
#define LOG_FAILED_REQUESTS 1
#define CA_UPDATE_INTERVAL_DAYS 15


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
	configuration = new ConfigFile(this);

	// load certificates file if present
	if (QFile(QString(BROWSER_DATA_PATH) + "cacert.pem").exists())
		QSslSocket::addDefaultCaCertificates(QString(BROWSER_DATA_PATH) + "cacert.pem");

	// update certificates file from time to time
	QDomDocument doc = configuration->getConfiguration(BROWSER_FILE);
	QDomElement address_node = getElement(doc.documentElement(), "conf/ca_database_address");
	QString address = getAttribute(address_node, "url", DEFAULT_CA_CERT_ADDRESS);

	QDomElement last_update_node = getElement(doc.documentElement(), "conf/last_update");
	QDateTime last_update = QDateTime::fromString(getAttribute(last_update_node, "time", ""), Qt::ISODate);

	if (!last_update.isValid() ||
	    last_update.daysTo(QDateTime::currentDateTime()) > CA_UPDATE_INTERVAL_DAYS ||
	    !QFile(QString(BROWSER_DATA_PATH) + "cacert.pem").exists())
	{
		QNetworkReply *r = get(QNetworkRequest(QUrl(address)));
		connect(r, SIGNAL(readChannelFinished()), this, SLOT(downloadCaFinished()));
	}

	foreach (QDomNode exception, getChildren(getElement(doc.documentElement(), "ssl_exceptions"), "exception"))
		ssl_exceptions.insert(getAttribute(exception, "host"));

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
	QString host = reply->request().url().host();

	if (ssl_exceptions.contains(host))
	{
		qDebug() << "Applying SSL exception for" << host;
		reply->ignoreSslErrors();
		return;
	}

	qDebug() << "SSL error for URL" << reply->request().url().toString();
	foreach (QSslError e, errors)
		qDebug() << "error:" << int(e.error()) << "string: " << e.errorString();

	emit invalidCertificate(this, reply);

	if (loop.exec() == IgnoreCertificateErrors)
	{
		ssl_exceptions.insert(host);
		reply->ignoreSslErrors();

		QDomDocument doc = configuration->getConfiguration(BROWSER_FILE);
		QDomElement ssl_exceptions = getElement(doc.documentElement(), "ssl_exceptions");
		QDomElement exception = doc.createElement("exception");

		exception.setAttribute("host", host);
		ssl_exceptions.appendChild(exception);

		configuration->saveConfiguration(BROWSER_FILE);
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

	// for requests in the SSL exceptions list we do not have an API to check whether the
	// certificate was validated or not (for example because the SSL error was transient and
	// has not been fixed) so we assume that the certificate has not been validated
	if (wrapped_reply->error() == QNetworkReply::SslHandshakeFailedError ||
	    wrapped_reply->sslConfiguration().peerCertificateChain().size() == 0 ||
	    ssl_exceptions.contains(url.host()))
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

	QFile cacert(QString(BROWSER_DATA_PATH) + "cacert.pem");
	QByteArray cert = reply->readAll();
	if (!QDir().mkpath(BROWSER_DATA_PATH) || !cacert.open(QIODevice::WriteOnly))
	{
		qWarning() << "Cannot open" << cacert.fileName() << "for writing";
	}
	else
	{
		qDebug() << "Got CA database, saving...";
		cacert.write(cert);

		// now save the configuration
		QDomDocument doc = configuration->getConfiguration(BROWSER_FILE);
		QDomElement last_update_node = getElement(doc.documentElement(), "conf/last_update");

		setAttribute(last_update_node, "time", QDateTime::currentDateTimeUtc().toString(Qt::ISODate));
		configuration->saveConfiguration(BROWSER_FILE);
	}
	QSslSocket::addDefaultCaCertificates(QString(BROWSER_DATA_PATH) + "cacert.pem");
}
