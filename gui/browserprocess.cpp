#include "browserprocess.h"

#include <QProcess>
#include <QCoreApplication>
#include <QtDebug>


BrowserProcess::BrowserProcess(QObject *parent) : QObject(parent)
{
	browser = new QProcess(this);

	connect(browser, SIGNAL(readyReadStandardOutput()), this, SLOT(readStatusUpdate()));
}

void BrowserProcess::displayUrl(QString url)
{
	startProcess();
	sendCommand("load_url " + url);
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

		if (key == "last_click")
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
