#include "configfile.h"

#include <QFileInfo>
#include <QCoreApplication>
#include <QDir>
#include <QTimer>

#include <QtDebug>

#include "xml_functions.h"

#define FILE_SAVE_INTERVAL 10000


QHash<QString, QDomDocument> ConfigFile::files, ConfigFile::modified;


ConfigFile::ConfigFile(QObject *parent) :
	QObject(parent)
{
	configuration_save = new QTimer(this);
	configuration_save->setInterval(FILE_SAVE_INTERVAL);
	configuration_save->setSingleShot(true);
	connect(configuration_save, SIGNAL(timeout()), this, SLOT(flushModifiedFiles()));
}

QDomDocument ConfigFile::getConfiguration(QString path)
{
	QFile fh(QFileInfo(QDir(qApp->applicationDirPath()), path).absoluteFilePath());
	if (files.contains(fh.fileName()))
		return files[fh.fileName()];

	QString errorMsg;
	int errorLine, errorColumn;
	if (!fh.exists() || !files[fh.fileName()].setContent(&fh, &errorMsg, &errorLine, &errorColumn)) {
		QString msg = QString("The config file %1 does not seem a valid xml configuration file: Error description: %2, line: %3, column: %4").arg(qPrintable(QFileInfo(fh).absoluteFilePath())).arg(errorMsg).arg(errorLine).arg(errorColumn);
		qFatal("%s", qPrintable(msg));
	}

	return files[fh.fileName()];
}

void ConfigFile::saveConfiguration(QString path)
{
	QString full_path = QFileInfo(QDir(qApp->applicationDirPath()), path).absoluteFilePath();

	modified[full_path] = files[full_path];
	configuration_save->start();
}

void ConfigFile::flushModifiedFiles()
{
	foreach (QString name, modified.keys())
		saveConfigFile(modified[name], name);

	modified.clear();
}

void ConfigFile::saveConfigFile(QDomDocument document, QString name)
{
	QString filename = QFileInfo(QDir(qApp->applicationDirPath()), name).absoluteFilePath();
	if (!saveXml(document, filename))
		qWarning() << "Error saving the config file" << filename;
	else
		qDebug() << "Config file" << filename << "saved";
}

