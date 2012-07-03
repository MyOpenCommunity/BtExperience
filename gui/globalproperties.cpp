#include "globalproperties.h"
#include "guisettings.h"
#include "inputcontextwrapper.h"

#include <QTimer>
#include <QDateTime>
#include <QScreen>
#include <QPixmap>
#include <QDeclarativeView>
#include <QtDeclarative>
#ifdef BT_MALIIT
#include <maliit/settingsmanager.h>
#include <maliit/pluginsettings.h>
#include <maliit/settingsentry.h>
#endif

namespace
{
	QStringList allowed_layouts = QStringList() << "en_gb" << "it" << "fr";
}

GlobalProperties::GlobalProperties()
{
	wrapper = new InputContextWrapper(this);
	main_widget = NULL;
	qmlRegisterUncreatableType<GuiSettings>("BtExperience", 1, 0, "GuiSettings", "");
	settings = new GuiSettings(this);

	updateTime();
	// We emit a signal every second to update the time.
	QTimer *secs_timer = new QTimer(this);
	connect(secs_timer, SIGNAL(timeout()), this, SIGNAL(lastTimePressChanged()));
	secs_timer->start(1000);

#ifdef BT_MALIIT
	maliit_settings = Maliit::SettingsManager::create();
	maliit_settings->setParent(this);

	connect(maliit_settings, SIGNAL(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)),
		this, SLOT(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)));

	maliit_settings->loadPluginSettings();
#endif
}

GlobalProperties::~GlobalProperties()
{
}

QString GlobalProperties::getBasePath() const
{
	QFileInfo path = qApp->applicationDirPath();

#ifdef Q_WS_MAC
	path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
#endif

	// use canonicalFilePath to resolve symlinks, otherwise some files
	// will be loaded with the symlinked path and some with the canonical
	// path, and this confuses the code that handles ".pragma library"
	return QFileInfo(QDir(path.absoluteFilePath()), "gui/skins/default/")
		   .canonicalFilePath() + "/";
}

int GlobalProperties::getMainWidth() const
{
#ifdef Q_WS_QWS
	return QScreen::instance()->width();
#else
	return MAIN_WIDTH;
#endif
}

int GlobalProperties::getMainHeight() const
{
#ifdef Q_WS_QWS
	return QScreen::instance()->height();
#else
	return MAIN_HEIGHT;
#endif
}

GuiSettings *GlobalProperties::getGuiSettings() const
{
	return settings;
}

QObject *GlobalProperties::getInputWrapper() const
{
	return wrapper;
}

int GlobalProperties::getLastTimePress() const
{
	return last_press.secsTo(QDateTime::currentDateTime());
}

void GlobalProperties::updateTime()
{
	last_press = QDateTime::currentDateTime();
	emit lastTimePressChanged();
}

void GlobalProperties::setMainWidget(QDeclarativeView *_viewport)
{
	main_widget = _viewport;
}

void GlobalProperties::takeScreenshot(QRect rect, QString filename)
{
	QWidget *viewport = main_widget->viewport();

	if (!viewport)
		viewport = main_widget;

	QImage image = QPixmap::grabWidget(viewport, rect).toImage();
	image.save(getBasePath() + "/" + filename);
}

QString GlobalProperties::getKeyboardLayout() const
{
#ifdef BT_MALIIT
	return keyboard_layout->value().toString().section(':', 1);
#else
	return QString();
#endif
}

void GlobalProperties::setKeyboardLayout(QString layout)
{
#ifdef BT_MALIIT
	keyboard_layout->set(language_map[layout]);
#endif
}

#ifdef BT_MALIIT
void GlobalProperties::pluginSettingsReceived(const QList<QSharedPointer<Maliit::PluginSettings> > &settings)
{
	foreach (const QSharedPointer<Maliit::PluginSettings> &setting, settings)
	{
		if (setting->pluginName() == "server")
			maliitFrameworkSettings(setting);
	}
}

void GlobalProperties::maliitFrameworkSettings(const QSharedPointer<Maliit::PluginSettings> &settings)
{
	foreach (const QSharedPointer<Maliit::SettingsEntry> &entry, settings->configurationEntries())
	{
		if (entry->key() == "/maliit/onscreen/enabled")
		{
			foreach (QString value, entry->attributes()[Maliit::SettingEntryAttributes::valueDomain].toStringList())
				if (allowed_layouts.indexOf(value.section(':', 1)) != -1)
					language_map[value.section(':', 1)] = value;

			entry->set(QStringList() << language_map.values());
		}
		else if (entry->key() == "/maliit/onscreen/active")
		{
			keyboard_layout = entry;

			connect(keyboard_layout.data(), SIGNAL(valueChanged()),
				this, SIGNAL(keyboardLayoutChanged()));
		}
	}
}
#endif
