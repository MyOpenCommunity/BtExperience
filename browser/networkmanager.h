#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QDeclarativeNetworkAccessManagerFactory>
#include <QNetworkAccessManager>
#include <QEventLoop>

class BrowserProperties;

class NetworkAccessManagerFactory : public QDeclarativeNetworkAccessManagerFactory
{
public:
	NetworkAccessManagerFactory(BrowserProperties *props);
	virtual QNetworkAccessManager *create(QObject *parent);

private:
	BrowserProperties *global_properties;
};

class BtNetworkAccessManager : public QNetworkAccessManager
{
	Q_OBJECT

public:
	BtNetworkAccessManager(QObject *parent = 0);
	void setAuthentication(const QString &user, const QString &pass);
	void abortConnection();
	void addSecurityException();

signals:
	void credentialsRequired(BtNetworkAccessManager *, QNetworkReply *);
	void invalidCertificate(BtNetworkAccessManager *, QNetworkReply *);

private slots:
	void handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors);
	void requireAuthentication(QNetworkReply *reply, QAuthenticator *auth);
	void downloadCaFinished();
	void displayErrors(QNetworkReply *reply);

private:
	enum {
		AbortAuthentication = -1,   // Abort the authentication procedure
		IgnoreCertificateErrors = -2,
	};
	QString username, password;
	QEventLoop loop;
};

#endif // NETWORKMANAGER_H
