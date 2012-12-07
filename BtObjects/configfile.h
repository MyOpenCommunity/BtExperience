#ifndef CONFIGFILE_H
#define CONFIGFILE_H

#include <QObject>
#include <QDomDocument>
#include <QHash>

#if defined(BT_HARDWARE_X11)
#define CONF_FILE "conf.xml"
#define ARCHIVE_FILE "archive.xml"
#define LAYOUT_FILE "layout.xml"
#define SETTINGS_FILE "settings.xml"
#define EXTRA_11_DIR "11/"
#else
#define CONF_FILE "/var/tmp/conf.xml"
#define ARCHIVE_FILE "/home/bticino/cfg/extra/0/archive.xml"
#define LAYOUT_FILE "/home/bticino/cfg/extra/0/layout.xml"
#define SETTINGS_FILE "/home/bticino/cfg/extra/0/settings.xml"
#define EXTRA_11_DIR "/home/bticino/cfg/extra/11/"
#endif

class QTimer;


/// Parse conf.xml and populate bt_global::config
void parseConfFile();

/// Set a configuration value in conf.xml
void setConfValue(QDomDocument document, QString path, QString value);

/// Get a configuration value from conf.xml
QString getConfValue(QDomDocument document, QString path);

/*!
	\brief Helper function to set value in settings.xml

	The setting value must have a format similar to:

	\verbatim
	<obj id_ringtone="1" cid="14101" id="14101">
		<ist id_ringtone="4" uii="30201"/>
	</obj>
	\endverbatim

	and there should be a single \c <ist>.
*/
void setIntSetting(QDomDocument document, int id, QString attribute, int value);

/*!
	\brief Helper function to read value in settings.xml

	The setting value must have a format similar to:

	\verbatim
	<obj id_ringtone="1" cid="14101" id="14101">
		<ist id_ringtone="4" uii="30201"/>
	</obj>
	\endverbatim

	and there should be a single \c <ist>.
*/
int parseIntSetting(QDomNode xml_node, QString attribute);

/// Boolean setting stored in the "enable" attribute of an \c <ist> tag
void setEnableFlag(QDomDocument document, int id, bool enable);

/// Boolean setting stored in the "enable" attribute of an \c <ist> tag
bool parseEnableFlag(QDomNode xml_node);


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
