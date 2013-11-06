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

#ifndef BROWSERPROPERTIES_H
#define BROWSERPROPERTIES_H

#include "globalpropertiescommon.h"

#include <QObject>
#include <QSet>
#include <QUrl>

class BtNetworkAccessManager;
class QNetworkReply;
class QWebPage;


class BrowserProperties : public GlobalPropertiesCommon
{
	Q_OBJECT

	Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged)

	Q_PROPERTY(QString urlString READ getUrlString WRITE setUrlString NOTIFY urlStringChanged)

public:
	BrowserProperties(logger *log);

	void setUrl(QUrl url);
	QUrl getUrl() const;
	void setUrlString(QString url);
	QString getUrlString() const;
	Q_INVOKABLE void setSslAuthentication(const QString &user, const QString &pass);
	Q_INVOKABLE void abortConnection();
	Q_INVOKABLE void addSecurityException();

	// only use for browser popup objects!
	Q_INVOKABLE void destroyQmlItem(QObject *object)
	{
		object->deleteLater();
	}

	Q_INVOKABLE QString quoteUrl(QString url) const;

	void registerPage(QWebPage *page);

public slots:
	void quit();
	void updateClick();
	void credentialsRequired(BtNetworkAccessManager *, QNetworkReply *);
	void certificatesError(BtNetworkAccessManager *, QNetworkReply *);
	void createQuicklink(int type, QString name, QString address);

signals:
	void urlChanged();
	void urlStringChanged();
	void authenticationRequired();
	void untrustedSslConnection();
	void requestComplete(bool ssl, QString host, bool originating_request, QString organization);
	void aboutToHide();
	void addWebRadio(QString url);

protected:
	bool eventFilter(QObject *obj, QEvent *ev);

private slots:
	void readInput();
	void pageDeleted(QObject *page);
	void unsupportedContent(QNetworkReply *reply);

private:
	void clearHistory();
	void setHistorySize(int size);
	void setVisible(bool visible);
	void parseLine(QString line);

	bool clicks_blocked, persistent_history;
	int persistent_history_size;
	QUrl url;
	QString input;
	BtNetworkAccessManager *access_manager;
	QSet<QWebPage *> pages;
};

#endif // BROWSERPROPERTIES_H
