#include "configfile.h"
#include "main.h"

#include <QFileInfo>
#include <QCoreApplication>
#include <QDir>
#include <QTimer>

#include <QtDebug>

#include "xml_functions.h"

#define FILE_SAVE_INTERVAL 10000

#if defined(BT_HARDWARE_X11)
#define CONF_FILE "conf.xml"
#else
#define CONF_FILE "/var/tmp/conf.xml"
#endif


namespace
{
	QString getDeviceValue(QDomNode conf, QString path, QString def_value = QString())
	{
		QDomElement n = getElement(conf, path);

		if (n.isNull())
			return def_value;
		else
			return n.text();
	}

	void setDeviceValue(QDomNode conf, QString path, QString value)
	{
		QDomElement n = getElement(conf, path);
		QDomNode text = n.ownerDocument().createTextNode(value);
		QDomNodeList childs = n.childNodes();

		for (int i = 0; i < childs.count(); ++i)
			n.removeChild(childs.at(i));

		n.appendChild(text);
	}
}

QHash<QString, QDomDocument> ConfigFile::files, ConfigFile::modified;


void parseConfFile()
{
	if (bt_global::config)
		return;
	bt_global::config = new QHash<GlobalField, QString>();

	QDomDocument device = ConfigFile().getConfiguration(CONF_FILE);
	QDomElement root = getElement(device.documentElement(), "setup");
	QHash<GlobalField, QString> &config = *bt_global::config;

	Q_ASSERT_X(!root.isNull(), "parseConfFile", "Invalid device configuration file");

	config[TEMPERATURE_SCALE] = getDeviceValue(root, "generale/temperature/format", QString::number(CELSIUS));
	config[LANGUAGE] = getDeviceValue(root, "generale/language", DEFAULT_LANGUAGE);
	config[DATE_FORMAT] = getDeviceValue(root, "generale/clock/dateformat", QString::number(EUROPEAN_DATE));
	config[MODEL] = getDeviceValue(root, "generale/modello");
	config[NAME] = getDeviceValue(root, "generale/nome");

	config[SOURCE_ADDRESS] = getDeviceValue(root, "scs/coordinate_scs/my_mmaddress");
	config[AMPLIFIER_ADDRESS] = getDeviceValue(root, "scs/coordinate_scs/my_aaddress");
	config[TS_NUMBER] = getDeviceValue(root, "scs/coordinate_scs/diag_addr", "0");

	if (config[SOURCE_ADDRESS] == "-1")
		config[SOURCE_ADDRESS] = "";
	if (config[AMPLIFIER_ADDRESS] == "-1")
		config[AMPLIFIER_ADDRESS] = "";

	QString guard_addr = getDeviceValue(root, "vdes/guardunits/item");
	if (!guard_addr.isEmpty())
		config[GUARD_UNIT_ADDRESS] = "3" + guard_addr;

	QDomElement vde_node = getElement(root, "vdes");
	QDomNode vde_pi_node = getChildWithName(vde_node, "communication");
	if (!vde_pi_node.isNull())
	{
		QString address = getTextChild(vde_pi_node, "address");
		QString dev = getTextChild(vde_pi_node, "dev");
		if (!address.isNull() && address != "-1")
			config[PI_ADDRESS] = dev + address;

		config[PI_MODE] = getTextChild(vde_pi_node, "mode");

		QString def_address = getDeviceValue(vde_pi_node, "p_default/address");
		QString def_dev = getDeviceValue(vde_pi_node, "p_default/dev");

		if (!def_address.isNull() && def_address != "-1")
			config[DEFAULT_PE] = def_dev + def_address;
	}
	else
		config[PI_MODE] = QString();
}

void setConfValue(QDomDocument document, QString path, QString value)
{
	setDeviceValue(getElement(document.documentElement(), "setup"), path, value);
}

QString getConfValue(QDomDocument document, QString path)
{
	return getDeviceValue(getElement(document.documentElement(), "setup"), path);
}


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

