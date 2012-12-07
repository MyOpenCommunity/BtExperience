#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QDeclarativeNetworkAccessManagerFactory>
#include <QNetworkAccessManager>

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
	void setUsername(const QString &user);
	void setPassword(const QString &pass);

signals:
	void credentialsRequired(BtNetworkAccessManager *, QNetworkReply *);

private slots:
	void handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors);
	void requireAuthentication(QNetworkReply *reply, QAuthenticator *auth);

private:
	QString username, password;
};

#endif // NETWORKMANAGER_H
