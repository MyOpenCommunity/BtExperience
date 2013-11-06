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

#include "browserproperties.h"
#include "networkmanager.h"

#include <QSocketNotifier>
#include <QCoreApplication>
#include <QDeclarativeView>
#include <QWebPage>
#include <QWebHistory>
#include <QDebug>
#include <QNetworkReply>

#include <stdio.h>
#include <fcntl.h>
#include <time.h>


BrowserProperties::BrowserProperties(logger *log) : GlobalPropertiesCommon(log)
{
	QSocketNotifier *stdin = new QSocketNotifier(0, QSocketNotifier::Read, this);

	connect(stdin, SIGNAL(activated(int)), this, SLOT(readInput()));
	fcntl(0, F_SETFL, (long)O_NONBLOCK);

	persistent_history = true;
	persistent_history_size = 0;
	clicks_blocked = false;

	// To receive all the events, even if there is some qml elements which manage
	// their, we have to install the event filter in the QApplication
	qApp->installEventFilter(this);

	connect(this, SIGNAL(urlChanged()), this, SIGNAL(urlStringChanged()));
}

void BrowserProperties::setUrl(QUrl _url)
{
	if (url == _url)
		return;

	url = _url;
	emit urlChanged();
}

QUrl BrowserProperties::getUrl() const
{
	return url;
}

QString BrowserProperties::quoteUrl(QString url) const
{
	return QUrl::fromUserInput(url).toEncoded();
}

void BrowserProperties::setUrlString(QString url)
{
	setUrl(QUrl::fromUserInput(url));
}

QString BrowserProperties::getUrlString() const
{
	return url.toString();
}

void BrowserProperties::setSslAuthentication(const QString &user, const QString &pass)
{
	access_manager->setAuthentication(user, pass);
}

void BrowserProperties::abortConnection()
{
	access_manager->abortConnection();
}

void BrowserProperties::addSecurityException()
{
	access_manager->addSecurityException();
}

void BrowserProperties::setVisible(bool visible)
{
	if (visible)
#if defined(Q_WS_X11) || defined(Q_WS_MAC)
		main_widget->show();
#else
		main_widget->showFullScreen();
#endif
	else
		main_widget->hide();

	printf("visible: %d\n", int(visible));
}

void BrowserProperties::quit()
{
	setUrlString("_btexperience:blank");
	printf("about_to_hide\n");
	setVisible(false);
	if (!persistent_history)
		clearHistory();
	emit aboutToHide();
}

void BrowserProperties::updateClick()
{
	printf("last_click: %ld\n", time(NULL));
}

void BrowserProperties::credentialsRequired(BtNetworkAccessManager *am, QNetworkReply *r)
{
	Q_UNUSED(r);
	access_manager = am;
	qDebug() << "Requesting credentials";

	emit authenticationRequired();
}

void BrowserProperties::certificatesError(BtNetworkAccessManager *am, QNetworkReply *r)
{
	Q_UNUSED(r);
	access_manager = am;

	emit untrustedSslConnection();
}

void BrowserProperties::readInput()
{
	char buf[30];

	for (;;)
	{
		int rd = read(0, buf, sizeof(buf) - 1);

		if (rd <= 0)
			break;
		buf[rd] = 0;

		input.append(buf);
	}

	QStringList lines = input.split("\n");

	// put back incomplete last line
	input = lines.back();
	lines.pop_back();

	foreach (QString line, lines)
		parseLine(line);
}

void BrowserProperties::parseLine(QString line)
{
	if (line.startsWith("set_visible "))
	{
		bool visible = line.split(" ")[1].toInt();

		setVisible(visible);
	}
	else if (line.startsWith("set_clicks_blocked "))
	{
		clicks_blocked = line.split(" ")[1].toInt();
	}
	else if (line.startsWith("load_url "))
	{
		// urls may contain blanks (they are in "user" or unencoded form),
		// so takes everything after the first space as is
		QString url = line.right(line.length() - 1 - line.indexOf(" "));

		setUrlString(url);
	}
	else if (line.startsWith("set_history_size "))
	{
		QString size = line.split(" ")[1];

		setHistorySize(size.toInt());
	}
	else if (line.startsWith("set_persistent_history "))
	{
		QString persistent = line.split(" ")[1];

		persistent_history = persistent.toInt();
	}
	else if (line == "clear_history")
		clearHistory();
	else if (line == "ping")
		printf("pong\n");
}

bool BrowserProperties::eventFilter(QObject *obj, QEvent *ev)
{
	Q_UNUSED(obj)

	if (ev->type() == QEvent::MouseButtonPress ||
	    ev->type() == QEvent::MouseButtonRelease ||
	    ev->type() == QEvent::MouseMove)
	{
		updateClick();

		return clicks_blocked;
	}

	return false;
}

void BrowserProperties::registerPage(QWebPage *page)
{
	if (pages.contains(page))
		return;

	if (persistent_history_size != 0)
		page->history()->setMaximumItemCount(persistent_history_size);
	pages.insert(page);

	connect(page, SIGNAL(destroyed(QObject*)), this, SLOT(pageDeleted(QObject*)));
	connect(page, SIGNAL(unsupportedContent(QNetworkReply*)), this, SLOT(unsupportedContent(QNetworkReply*)));

	page->setForwardUnsupportedContent(true);
}

void BrowserProperties::pageDeleted(QObject *page)
{
	pages.remove(static_cast<QWebPage *>(page));
}

void BrowserProperties::unsupportedContent(QNetworkReply *reply)
{
	QString content_type = reply->header(QNetworkRequest::ContentTypeHeader).toString();
	QString url = reply->request().url().toString();

	if (content_type == "video/x-ms-asf" || content_type == "audio/x-scpls")
	{
		// video/x-ms-asf (.asx) and audio/x-scpls (.pls) URLs are handled directly by MPlayer
		emit addWebRadio(url);
	}
	else if (content_type == "audio/x-mpegurl")
	{
		// audio/x-mpegurl (.m3u) needs -playlist parameter, but it's already handled in MediaPlayer
		// class if extension is .m3u, otherwise we use the first url contained in the playlist
		if (url.endsWith(".m3u", Qt::CaseInsensitive))
		{
			emit addWebRadio(url);
		}
		else
		{
			while (reply->bytesAvailable())
			{
				QString line = reply->readLine().trimmed();

				if (line.startsWith("http://") ||
				    line.startsWith("https://") ||
				    line.startsWith("mms://") ||
				    line.startsWith("rtsp://"))
				{
					emit addWebRadio(line);
					break;
				}
			}
		}
	}
	else
		qWarning() << "Unsupported content" << content_type << "for URL" << url;
}

void BrowserProperties::clearHistory()
{
	setUrlString("about:blank");
	foreach (QWebPage *page, pages)
		page->history()->clear();
}

void BrowserProperties::setHistorySize(int history)
{
	persistent_history_size = history;
	foreach (QWebPage *page, pages)
		page->history()->setMaximumItemCount(history);
}

void BrowserProperties::createQuicklink(int type, QString name, QString address)
{
	QString command = QString("create_quicklink: %1 %2 %3").arg(type).arg(address).arg(name);
	printf("%s\n", command.toLatin1().data());
}
