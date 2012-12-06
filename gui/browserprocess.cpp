#include "browserprocess.h"

#include <QProcess>
#include <QCoreApplication>
#include <QTimer>
#include <QtDebug>

#define KEEP_ALIVE_INTERVAL 5000
#define KEEP_ALIVE_MAX      4

/*
  Browser output lines are key-value pairs, for example:

    last_click: 1234567890
    visible: 1
    ...

  - last_click

  Last click time (in seconds)

  - visible

  Whether the browser window is visible or not

  Commands are terminaed by a newline:

  - set_visible <0|1>

  Show/hide browser window.

  - load_url url

  Load specified URL

  - ping

  Browser process prints "pong" in response.
*/


BrowserProcess::BrowserProcess(QObject *parent) : QObject(parent)
{
	browser = new QProcess(this);
	keep_alive = new QTimer(this);
	visible = false;
	keep_alive_ticks = 0;

	keep_alive->setInterval(KEEP_ALIVE_INTERVAL);
	connect(keep_alive, SIGNAL(timeout()), this, SLOT(sendKeepAlive()));

	connect(browser, SIGNAL(finished(int)), this, SLOT(terminated()));
	connect(browser, SIGNAL(readyReadStandardOutput()), this, SLOT(readStatusUpdate()));
	connect(browser, SIGNAL(stateChanged(QProcess::ProcessState)), this, SLOT(processStateChanged()));
}

void BrowserProcess::displayUrl(QString url)
{
	startProcess();
	sendCommand("load_url " + url);
	setVisible(true);
}

void BrowserProcess::setVisible(bool visible)
{
	sendCommand("set_visible " + QString::number(visible));
}

void BrowserProcess::updateVisible(bool _visible)
{
	if (visible == _visible)
		return;
	visible = _visible;
	emit visibleChanged();
}

bool BrowserProcess::getVisible() const
{
	return visible;
}

void BrowserProcess::terminated()
{
	updateVisible(false);
}

void BrowserProcess::readStatusUpdate()
{
	QString data = browser->readAll();

	foreach (QString line, data.split('\n'))
	{
		if (line == "pong")
		{
			keep_alive_ticks = 0;
			continue;
		}

		int colon = line.indexOf(':');
		if (colon == -1)
			continue;

		QString key = line.mid(0, colon);
		QString value = line.mid(colon + 2);

		if (key == "visible")
			updateVisible(value.toInt());
		else if (key == "last_click")
			emit clicked();
	}
}

void BrowserProcess::startProcess()
{
	if (browser->state() == QProcess::NotRunning)
	{
		browser->start(qApp->applicationDirPath() + "/browser");
		browser->waitForStarted(300);
	}
}

void BrowserProcess::sendCommand(QString command)
{
	if (browser->state() == QProcess::NotRunning)
		return;
	if (browser->write(command.toAscii() + "\n") < -1)
		qDebug() << "Error BrowserProcess::sendCommand():" << browser->errorString();
}

void BrowserProcess::processStateChanged()
{
	if (browser->state() == QProcess::Running)
	{
		keep_alive_ticks = 0;
		keep_alive->start();
	}
	else
		keep_alive->stop();
}

void BrowserProcess::sendKeepAlive()
{
	if (keep_alive_ticks == KEEP_ALIVE_MAX)
	{
		qWarning("Terminating unresponsive browser with SIGTERM");
		browser->terminate();
	}
	else if (keep_alive_ticks > KEEP_ALIVE_MAX)
	{
		qWarning("Terminating unresponsive browser with SIGKILL");
		browser->kill();
	}
	else
		sendCommand("ping");
	keep_alive_ticks++;
}
