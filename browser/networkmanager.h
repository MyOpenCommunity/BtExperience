/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QDeclarativeNetworkAccessManagerFactory>
#include <QNetworkAccessManager>
#include <QEventLoop>
#include <QSet>
#include <QRegExp>

class BrowserProperties;
class ConfigFile;


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
	BtNetworkAccessManager(BrowserProperties *global_properties, QObject *parent = 0);
	void setAuthentication(const QString &user, const QString &pass);
	void abortConnection();
	void addSecurityException();

signals:
	void credentialsRequired(BtNetworkAccessManager *, QNetworkReply *);
	void invalidCertificate(BtNetworkAccessManager *, QNetworkReply *);

	/*!
		\brief requestComplete
		\param ssl whether the connection used SSL
		\param host host (or host:port) string
		\param originating_request true for main-page domain, false for page sub-elements
		\param organization for verified certificated, the organization name written in the certificate
	*/
	void requestComplete(bool ssl, QString host, bool originating_request, QString organization);

protected:
	QNetworkReply *createRequest( Operation op, const QNetworkRequest &req, QIODevice * outgoingData=0 );

private slots:
	void handleSslErrors(QNetworkReply *reply, const QList<QSslError> &errors);
	void requireAuthentication(QNetworkReply *reply, QAuthenticator *auth);
	void downloadCaFinished();
	void displayErrors(QNetworkReply *reply);
	void checkSslStatus(QNetworkReply *reply);

private:
	QString userAgent(const QNetworkRequest &req);

	enum
	{
		AbortAuthentication = -1,   // Abort the authentication procedure
		IgnoreCertificateErrors = -2,
	};

	typedef QPair<QRegExp, QString> UserAgentEntry;

	QString username, password;
	QEventLoop loop;
	ConfigFile *configuration;
	QSet<QString> ssl_exceptions;
	QList<UserAgentEntry> user_agent_map;
	BrowserProperties *global_properties;
};

#endif // NETWORKMANAGER_H
