#include "browserprocess.h"

#include <QProcess>
#include <QCoreApplication>


BrowserProcess::BrowserProcess(QObject *parent) : QObject(parent)
{
	browser = new QProcess(this);
}

void BrowserProcess::displayUrl(QString url)
{
	browser->start(qApp->applicationDirPath() + "/browser", QStringList() << url);
}
