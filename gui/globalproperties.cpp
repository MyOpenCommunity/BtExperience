#include "globalproperties.h"
#include "guisettings.h"
#include "inputcontextwrapper.h"
#include "player.h"
#include "audiostate.h"
#include "mediaplayer.h" // SoundPlayer
#include "ringtonemanager.h"
#include "xml_functions.h"
#include "ts/main.h"
#include "configfile.h"
#include "devices_cache.h"
#include "xmlobject.h"

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

#define EXTRA_PATH "/home/bticino/cfg/extra"
#define LAZY_UPDATE_INTERVAL 2000
#define LAZY_UPDATE_COUNT 2

#if defined(BT_HARDWARE_X11)
#define SETTINGS_FILE "settings.xml"
#else
#define SETTINGS_FILE "/home/bticino/cfg/extra/0/settings.xml"
#endif


namespace
{
	QStringList allowed_layouts = QStringList() << "en_gb_bticino" << "it_bticino" << "fr_bticino";

	enum Parsing
	{
		Beep = 14001,
	};

	void setEnableFlag(QDomDocument document, int id, bool enable)
	{
		foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == id)
			{
				foreach (QDomNode ist, getChildren(xml_obj, "ist"))
					setAttribute(ist, "enable", QString::number(int(enable)));
				break;
			}
		}
	}

	bool parseEnableFlag(QDomNode xml_node)
	{
		bool result = false;
		XmlObject v(xml_node);

		foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
		{
			v.setIst(ist);
			result = v.intValue("enable");
		}
		return result;
	}
}


GlobalProperties::GlobalProperties()
{
	wrapper = new InputContextWrapper(this);
	main_widget = NULL;
	monitor_off = false;

	delayed_frame_timer = new QTimer(this);
	delayed_frame_timer->setInterval(LAZY_UPDATE_INTERVAL);

	connect(delayed_frame_timer, SIGNAL(timeout()),
		this, SLOT(sendDelayedFrames()));

	qmlRegisterUncreatableType<GuiSettings>("BtExperience", 1, 0, "GuiSettings", "");
	qmlRegisterUncreatableType<AudioVideoPlayer>("BtExperience", 1, 0, "AudioVideoPlayer", "");
	qmlRegisterUncreatableType<PhotoPlayer>("BtExperience", 1, 0, "PhotoPlayer", "");
	qmlRegisterUncreatableType<AudioState>("BtExperience", 1, 0, "AudioState", "");
	qmlRegisterUncreatableType<RingtoneManager>("BtExperience", 1, 0, "RingtoneManager", "");

	configurations = new ConfigFile(this);
	settings = new GuiSettings(this);
	photoPlayer = new PhotoPlayer(this);
	videoPlayer = 0;
	audioPlayer = 0;
	audio_state = 0;
	sound_player = 0;
	ringtone_manager = 0;

	updateTime();
	// We emit a signal every second to update the time.
	QTimer *secs_timer = new QTimer(this);
	connect(secs_timer, SIGNAL(timeout()), this, SIGNAL(lastTimePressChanged()));
	secs_timer->start(1000);

	parseSettings();

#ifdef BT_MALIIT
	maliit_settings = Maliit::SettingsManager::create();
	maliit_settings->setParent(this);

	connect(maliit_settings, SIGNAL(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)),
		this, SLOT(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)));

	maliit_settings->loadPluginSettings();
#endif
	setMonitorOff(false);
}

GlobalProperties::~GlobalProperties()
{
}

void GlobalProperties::initAudio()
{
	if (audio_state)
		return;

	Q_ASSERT_X(bt_global::config, "GlobalProperties::initAudio", "BtObjects plugin not initialized yet");

	videoPlayer = new AudioVideoPlayer(this);

	sound_player = new SoundPlayer(this);

	audio_state = new AudioState(this);
	emit audioStateChanged();
	audio_state->registerMediaPlayer(qobject_cast<MultiMediaPlayer *>(videoPlayer->getMediaPlayer()));
	audio_state->registerBeep(sound_player);
	audio_state->enableState(AudioState::Idle);

	connect(audio_state, SIGNAL(stateChanged(AudioState::State,AudioState::State)),
		this, SLOT(audioStateChangedManagement()));

	MultiMediaPlayer *player = new MultiMediaPlayer(this);

	ringtone_manager = new RingtoneManager(getExtraPath() + "5/ringtones.xml", player, audio_state, this);
	audio_state->registerSoundPlayer(player);

	connect(settings, SIGNAL(beepChanged()),
		this, SLOT(beepChanged()));

	bool sound_diffusion_enabled = !(*bt_global::config)[SOURCE_ADDRESS].isEmpty();

	if (sound_diffusion_enabled)
	{
		audioPlayer = new AudioVideoPlayer(this);
		emit audioPlayerChanged();

		MultiMediaPlayer *player = static_cast<MultiMediaPlayer *>(audioPlayer->getMediaPlayer());

		player->setCommandLineArguments(QStringList(), QStringList());
		audio_state->registerSoundDiffusionPlayer(player);
	}
	else
	{
		audioPlayer = videoPlayer;
		emit audioPlayerChanged();
	}

	// TODO remove after configuration parsing is complete
	ringtone_manager->setRingtone(RingtoneManager::Alarm, 1);
	ringtone_manager->setRingtone(RingtoneManager::Message, 1);
	ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace1, 4);
	ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace2, 4);
	ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace3, 4);
	ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace4, 4);
	ringtone_manager->setRingtone(RingtoneManager::InternalIntercom, 5);
	ringtone_manager->setRingtone(RingtoneManager::ExternalIntercom, 5);
	ringtone_manager->setRingtone(RingtoneManager::IntercomFloorcall, 5);
}

void GlobalProperties::parseSettings()
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
	{
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case Beep:
			settings->setBeep(parseEnableFlag(xml_obj));
			break;
		}
	}
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
	QFileInfo base(QDir(path.absoluteFilePath()), "gui/skins/default/");

	if (!base.exists())
		qFatal("Unable to find path for skin files");

	return base.canonicalFilePath() + "/";
}

QString GlobalProperties::getExtraPath() const
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

bool GlobalProperties::isMonitorOff() const
{
	return monitor_off;
}

void GlobalProperties::setMonitorOff(bool newValue)
{
	if (monitor_off == newValue)
		return;

	monitor_off = newValue;

	int transmitted_value = 0; // 0 - turn off, 1 - turn on
	if (!newValue)
		transmitted_value = 1;

#if defined(BT_HARDWARE_X11)
	qDebug() << QString("ARM COMMAND: echo %1 > /sys/devices/platform/omapdss/display0/enabled").arg(transmitted_value);
#else
	QProcess::startDetached(QString("echo %1 > /sys/devices/platform/omapdss/display0/enabled").arg(transmitted_value));
#endif

	emit monitorOffChanged();
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

AudioVideoPlayer *GlobalProperties::getVideoPlayer() const
{
	return videoPlayer;
}

AudioVideoPlayer *GlobalProperties::getAudioPlayer() const
{
	return audioPlayer;
}

PhotoPlayer *GlobalProperties::getPhotoPlayer() const
{
	return photoPlayer;
}

QObject *GlobalProperties::getAudioState() const
{
	return audio_state;
}

QObject *GlobalProperties::getRingtoneManager() const
{
	return ringtone_manager;
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

void GlobalProperties::beep()
{
	QString path = getExtraPath() + "10/beep.wav";

	if (QFile::exists(path) && audio_state->getState() == AudioState::Beep)
		sound_player->play(path);
}

void GlobalProperties::beepChanged()
{
	if (settings->getBeep())
		audio_state->enableState(AudioState::Beep);
	else
		audio_state->disableState(AudioState::Beep);

	setEnableFlag(configurations->getConfiguration(SETTINGS_FILE), Beep, settings->getBeep());
	configurations->saveConfiguration(SETTINGS_FILE);
}

void GlobalProperties::audioStateChangedManagement()
{
	if (audio_state->getState() == AudioState::Screensaver)
		delayed_frame_timer->start();
	else
		delayed_frame_timer->stop();
}

void GlobalProperties::sendDelayedFrames()
{
	bt_global::devices_cache.checkLazyUpdate(LAZY_UPDATE_COUNT);
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
#else
	Q_UNUSED(layout);
#endif
}

#ifdef BT_MALIIT
void GlobalProperties::pluginSettingsReceived(const QList<QSharedPointer<Maliit::PluginSettings> > &settings)
{
	foreach (const QSharedPointer<Maliit::PluginSettings> &setting, settings)
	{
		if (setting->pluginName() == "server")
			maliitFrameworkSettings(setting);
		else if (setting->pluginName() == "libmaliit-keyboard-plugin.so")
			maliitKeyboardSettings(setting);
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

void GlobalProperties::maliitKeyboardSettings(const QSharedPointer<Maliit::PluginSettings> &settings)
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
