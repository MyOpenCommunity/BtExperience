#include "browserprocess.h"

#include <QProcess>
#include <QCoreApplication>
#include <QtDebug>


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
*/


BrowserProcess::BrowserProcess(QObject *parent) : QObject(parent)
{
	browser = new QProcess(this);
	visible = false;

	connect(browser, SIGNAL(finished(int)), this, SLOT(terminated()));
	connect(browser, SIGNAL(readyReadStandardOutput()), this, SLOT(readStatusUpdate()));
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
