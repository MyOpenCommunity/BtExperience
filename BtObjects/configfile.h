#ifndef CONFIGFILE_H
#define CONFIGFILE_H

#include <QObject>
#include <QDomDocument>
#include <QHash>

class QTimer;


/*!
 * \brief Global configuration handler class
 *
 * Acts as a global cache for configuration files, and handles the logic to save
 * them asynchronously.
 *
 * All instances of this class manage a global list of files.
 */
class ConfigFile : public QObject
{
	Q_OBJECT

public:
	ConfigFile(QObject *parent = 0);

	QDomDocument getConfiguration(QString path);
	void saveConfiguration(QString path);

private slots:
	void flushModifiedFiles();

private:
	void saveConfigFile(QDomDocument document, QString name);

	QTimer *configuration_save;
	static QHash<QString, QDomDocument> files, modified;
};

#endif // CONFIGFILE_H
