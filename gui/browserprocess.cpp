#include "browserprocess.h"

#include <QProcess>
#include <QCoreApplication>


BrowserProcess::BrowserProcess(QObject *parent) : QObject(parent)
{
	browser = new QProcess(this);

	connect(browser, SIGNAL(finished(int)), this, SIGNAL(terminated()));
}

void BrowserProcess::start(QString url)
{
	browser->start(qApp->applicationDirPath() + "/browser", QStringList() << url);
}
