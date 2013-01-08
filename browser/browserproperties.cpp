#include "browserproperties.h"
#include "networkmanager.h"

#include <QSocketNotifier>
#include <QCoreApplication>
#include <QDeclarativeView>
#include <QDebug>

#include <stdio.h>
#include <fcntl.h>
#include <time.h>

BrowserProperties::BrowserProperties(logger *log) : GlobalPropertiesCommon(log)
{
	QSocketNotifier *stdin = new QSocketNotifier(0, QSocketNotifier::Read, this);

	connect(stdin, SIGNAL(activated(int)), this, SLOT(readInput()));
	fcntl(0, F_SETFL, (long)O_NONBLOCK);

	clicks_blocked = false;

	// To receive all the events, even if there is some qml elements which manage
	// their, we have to install the event filter in the QApplication
	qApp->installEventFilter(this);
}

void BrowserProperties::setUrl(QString _url)
{
	if (url == _url)
		return;
	url = _url;
	emit urlChanged();
}

QString BrowserProperties::getUrl() const
{
	return url;
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
	setUrl("");
	printf("about_to_hide\n");
	setVisible(false);
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
		QString url = line.split(" ")[1];

		setUrl(url);
	}
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
