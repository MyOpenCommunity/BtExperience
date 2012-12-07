#include "globalpropertiescommon.h"
#include "guisettings.h"
#include "inputcontextwrapper.h"
#include "configfile.h"
#include "xml_functions.h"
#include "xmlobject.h"

#include <logger.h>

#include <QFileInfo>
#include <QDir>
#include <QApplication>
#include <QtDeclarative>
#ifdef BT_MALIIT
#include <maliit/settingsmanager.h>
#include <maliit/pluginsettings.h>
#endif

#if defined(Q_WS_QWS)
#include <QScreen>
#endif

#define EXTRA_PATH "/home/bticino/cfg/extra"

namespace
{
	enum Parsing
	{
		DebugTouchscreen = 123456,
		DebugEventTiming
	};
}


GlobalPropertiesCommon::GlobalPropertiesCommon(logger *log)
{
	parseConfFile();

	qmlRegisterUncreatableType<GuiSettings>("BtExperience", 1, 0, "GuiSettings", "");
	qmlRegisterUncreatableType<DebugTiming>("BtExperience", 1, 0, "DebugTiming", "");

	wrapper = new InputContextWrapper(this);
	main_widget = 0;
	settings = new GuiSettings(this);
	debug_touchscreen = false;
	debug_timing = 0;

	QDomDocument conf = configurations->getConfiguration(CONF_FILE);

	keyboard_layout_name = getConfValue(conf, "generale/keyboard_lang");

	parseSettings(log);

#ifdef BT_MALIIT
	maliit_settings = Maliit::SettingsManager::create();
	maliit_settings->setParent(this);

	connect(maliit_settings, SIGNAL(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)),
		this, SLOT(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)));

	maliit_settings->loadPluginSettings();
#endif
}

void GlobalPropertiesCommon::parseSettings(logger *log)
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	bool debug_timing_enabled = false;
	foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
	{
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case DebugTouchscreen:
			debug_touchscreen = parseEnableFlag(xml_obj);
			break;
		case DebugEventTiming:
			debug_timing_enabled = parseEnableFlag(xml_obj);
			break;
		}
	}

	debug_timing = new DebugTiming(log, debug_timing_enabled, this);
}

QString GlobalPropertiesCommon::getBasePath() const
{
	QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
	path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

	// use canonicalFilePath to resolve symlinks, otherwise some files
	// will be loaded with the symlinked path and some with the canonical
	// path, and this confuses the code that handles ".pragma library"
	QFileInfo base(QDir(path.absoluteFilePath()), "gui/skins/default/");

	if (!base.exists())
		qFatal("Unable to find path for skin files");

	return base.canonicalFilePath() + "/";
}

QString GlobalPropertiesCommon::getExtraPath() const
{
	QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
	path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

#if defined(BT_HARDWARE_X11)
	QFileInfo extra(QDir(path.absoluteFilePath()), "extra");
#else
	QFileInfo extra(EXTRA_PATH);
#endif

	if (!extra.exists())
		qFatal("Unable to find path for extra files");

	return extra.canonicalFilePath() + "/";
}

bool GlobalPropertiesCommon::getDebugTs()
{
	return debug_touchscreen;
}

DebugTiming *GlobalPropertiesCommon::getDebugTiming()
{
	return debug_timing;
}

int GlobalPropertiesCommon::getMainWidth() const
{
#ifdef Q_WS_QWS
	return QScreen::instance()->width();
#else
	return MAIN_WIDTH;
#endif
}

int GlobalPropertiesCommon::getMainHeight() const
{
#ifdef Q_WS_QWS
	return QScreen::instance()->height();
#else
	return MAIN_HEIGHT;
#endif
}

GuiSettings *GlobalPropertiesCommon::getGuiSettings() const
{
	return settings;
}

QObject *GlobalPropertiesCommon::getInputWrapper() const
{
	return wrapper;
}

void GlobalPropertiesCommon::setMainWidget(QDeclarativeView *_viewport)
{
	main_widget = _viewport;
}

QString GlobalPropertiesCommon::getKeyboardLayout() const
{
	return keyboard_layout_name;
}

void GlobalPropertiesCommon::setKeyboardLayout(QString layout)
{
#ifdef BT_MALIIT
	QString maliit_layout = language_map.value(layout), layout_key = layout;

	if (maliit_layout.isEmpty())
	{
		foreach (QString key, language_map.keys())
		{
			qWarning() << "key" << key;
			if (key.startsWith(layout + "_"))
			{
				layout_key = key;
				maliit_layout = language_map[key];
				break;
			}
		}

		if (maliit_layout.isEmpty())
			return;
	}

	// setting the allowed layout list to the current layout is a roundabout way of disabling
	// the swipe left/right gesture used to change keyboard layout
	allowed_layouts->set(QStringList() << maliit_layout);
	keyboard_layout->set(maliit_layout);

	if (layout != keyboard_layout_name)
	{
		QDomDocument conf = configurations->getConfiguration(CONF_FILE);

		setConfValue(conf, "generale/keyboard_lang", layout);
		configurations->saveConfiguration(CONF_FILE);
	}

	if (keyboard_layout_name == layout_key)
		return;
	keyboard_layout_name = layout_key;
	emit keyboardLayoutChanged();
#else
	if (keyboard_layout_name == layout)
		return;
	keyboard_layout_name = layout;
	emit keyboardLayoutChanged();
#endif
}

QStringList GlobalPropertiesCommon::getKeyboardLayouts() const
{
#ifdef BT_MALIIT
	return language_map.keys();
#else
	return QStringList();
#endif
}

#ifdef BT_MALIIT
void GlobalPropertiesCommon::pluginSettingsReceived(const QList<QSharedPointer<Maliit::PluginSettings> > &settings)
{
	foreach (const QSharedPointer<Maliit::PluginSettings> &setting, settings)
	{
		if (setting->pluginName() == "server")
			maliitFrameworkSettings(setting);
		else if (setting->pluginName() == "libmaliit-keyboard-plugin.so")
			maliitKeyboardSettings(setting);
	}
}

void GlobalPropertiesCommon::maliitFrameworkSettings(const QSharedPointer<Maliit::PluginSettings> &settings)
{
	foreach (const QSharedPointer<Maliit::SettingsEntry> &entry, settings->configurationEntries())
	{
		if (entry->key() == "/maliit/onscreen/enabled")
		{
			allowed_layouts = entry;

			foreach (QString value, entry->attributes()[Maliit::SettingEntryAttributes::valueDomain].toStringList())
				if (value.section(':', 1).endsWith("_bticino"))
					language_map[value.section(':', 1)] = value;

			emit keyboardLayoutsChanged();
		}
		else if (entry->key() == "/maliit/onscreen/active")
			keyboard_layout = entry;
	}

	// see comment in setKeyboardLayout()
	setKeyboardLayout(getKeyboardLayout());
}

void GlobalPropertiesCommon::maliitKeyboardSettings(const QSharedPointer<Maliit::PluginSettings> &settings)
{
	foreach (const QSharedPointer<Maliit::SettingsEntry> &entry, settings->configurationEntries())
	{
		if (entry->key() == "/maliit/pluginsettings/libmaliit-keyboard-plugin.so/current_style")
		{
			QString style = QString("maliit-%1x%2").arg(getMainWidth()).arg(getMainHeight());

			entry->set(style);
		}
	}
}
#endif


DebugTiming::DebugTiming(logger *log, bool enabled, QObject *parent) :
	QObject(parent)
{
	app_logger = log;
	last_message.start();
	is_enabled = enabled;
}

void DebugTiming::logTiming(const QString &message)
{
	if (is_enabled)
		app_logger->debug(LOG_CRITICAL, (char *) qPrintable(message +
			", TIME since last log (ms): " + QString::number(last_message.restart())));
}
