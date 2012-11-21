#include "globalproperties.h"
#include "guisettings.h"
#include "inputcontextwrapper.h"
#include "playlistplayer.h"
#include "audiostate.h"
#include "mediaplayer.h" // SoundPlayer
#include "mediaobjects.h" // SourceMedia
#include "ringtonemanager.h"
#include "xml_functions.h"
#include "ts/main.h"
#include "configfile.h"
#include "devices_cache.h"
#include "xmlobject.h"
#include "hwkeys.h"
#include <logger.h>

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
#define EXTRA_11_DIR "11/"
#else
#define SETTINGS_FILE "/home/bticino/cfg/extra/0/settings.xml"
#define EXTRA_11_DIR "/home/bticino/cfg/extra/11/"
#endif


namespace
{
	enum Parsing
	{
		Beep = 14001,
		Password = 14003,
		DebugTouchscreen = 123456,
		DebugEventTiming,
		RingtoneS0 = 14101,
		RingtoneS1,
		RingtoneS2,
		RingtoneS3,
		RingtoneInternal,
		RingtoneExternal,
		RingtoneDoor,
		RingtoneAlarm,
		RingtoneMessage,
		VolumeBeep = 14121,
		VolumeLocalPlayback,
		VolumeRingtone,
		VolumeVdeCall,
		VolumeIntercomCall
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

	void setRingtone(QDomDocument document, int id, int ringtone)
	{
		foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == id)
			{
				foreach (QDomNode ist, getChildren(xml_obj, "ist"))
					setAttribute(ist, "id_ringtone", QString::number(ringtone));
				break;
			}
		}
	}

	int parseRingtone(QDomNode xml_node)
	{
		int result = -1;
		XmlObject v(xml_node);

		foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
		{
			v.setIst(ist);
			result = v.intValue("id_ringtone");
		}
		return result;
	}

	void setVolume(QDomDocument document, int id, int ringtone)
	{
		foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == id)
			{
				foreach (QDomNode ist, getChildren(xml_obj, "ist"))
					setAttribute(ist, "volume", QString::number(ringtone));
				break;
			}
		}
	}

	int parseVolume(QDomNode xml_node)
	{
		int result = -1;
		XmlObject v(xml_node);

		foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
		{
			v.setIst(ist);
			result = v.intValue("volume");
		}
		return result;
	}

	void setPassword(QDomDocument document, int id, QString password, bool enabled)
	{
		foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == id)
			{
				foreach (QDomNode ist, getChildren(xml_obj, "ist"))
				{
					setAttribute(ist, "password", password);
					setAttribute(ist, "mode", QString::number(bool(enabled)));
				}
				break;
			}
		}
	}

	void parsePassword(QDomNode xml_node, QString *password, bool *enabled)
	{
		XmlObject v(xml_node);

		foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
		{
			v.setIst(ist);
			*password = v.value("password");
			*enabled = bool(v.intValue("mode"));
		}
	}

	void setMonitorEnabled(int value)
	{
		QFile display_device("/sys/devices/platform/omapdss/display0/enabled");

		display_device.open(QFile::WriteOnly);
		display_device.write(qPrintable(QString::number(value)));
		display_device.close();
	}
}


GlobalProperties::GlobalProperties(logger *log)
{
	parseConfFile();

	wrapper = new InputContextWrapper(this);
	main_widget = NULL;
	monitor_off = false;

	delayed_frame_timer = new QTimer(this);
	delayed_frame_timer->setInterval(LAZY_UPDATE_INTERVAL);

	connect(delayed_frame_timer, SIGNAL(timeout()),
		this, SLOT(sendDelayedFrames()));

	qmlRegisterUncreatableType<GuiSettings>("BtExperience", 1, 0, "GuiSettings", "");
	qmlRegisterUncreatableType<AudioState>("BtExperience", 1, 0, "AudioState", "");
	qmlRegisterUncreatableType<RingtoneManager>("BtExperience", 1, 0, "RingtoneManager", "");
	qmlRegisterUncreatableType<DebugTiming>("BtExperience", 1, 0, "DebugTiming", "");

	configurations = new ConfigFile(this);
	settings = new GuiSettings(this);
	photo_player = new PhotoPlayer(this);
	video_player = 0;
	audio_state = new AudioState(this);
	sound_player = 0;
	ringtone_manager = new RingtoneManager(getExtraPath() + "5/ringtones.xml", new MultiMediaPlayer(this), audio_state, this);
	debug_touchscreen = false;
	debug_timing = 0;
	hardware_keys = new HwKeys(this);

	if (!(*bt_global::config)[DEFAULT_PE].isEmpty())
		default_external_place = new ExternalPlace(QString(), ObjectInterface::IdExternalPlace,
							   (*bt_global::config)[DEFAULT_PE]);
	else
		default_external_place = 0;

	setMonitorEnabled(1);
	updateTime();
	// We emit a signal every second to update the time.
	QTimer *secs_timer = new QTimer(this);
	connect(secs_timer, SIGNAL(timeout()), this, SIGNAL(lastTimePressChanged()));
	secs_timer->start(1000);

	parseSettings(log);

#ifdef BT_MALIIT
	maliit_settings = Maliit::SettingsManager::create();
	maliit_settings->setParent(this);

	connect(maliit_settings, SIGNAL(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)),
		this, SLOT(pluginSettingsReceived(QList<QSharedPointer<Maliit::PluginSettings> >)));

	maliit_settings->loadPluginSettings();
#endif

	connect(ringtone_manager, SIGNAL(ringtoneChanged(int,int)),
		this, SLOT(ringtoneChanged(int,int)));
	connect(audio_state, SIGNAL(volumeChanged(int,int)),
		this, SLOT(volumeChanged(int,int)));
}

void GlobalProperties::initAudio()
{
	if (video_player)
		return;

	Q_ASSERT_X(bt_global::config, "GlobalProperties::initAudio", "BtObjects plugin not initialized yet");

	video_player = new AudioVideoPlayer(this);
	video_player->setVolume(audio_state->getVolume(AudioState::LocalPlaybackVolume));
	emit audioVideoPlayerChanged();

	sound_player = new SoundPlayer(this);

	audio_state->registerMediaPlayer(qobject_cast<MultiMediaPlayer *>(video_player->getMediaPlayer()));
	audio_state->registerBeep(sound_player);
	audio_state->enableState(AudioState::Idle);

	connect(audio_state, SIGNAL(stateChanged(AudioState::State,AudioState::State)),
		this, SLOT(audioStateChangedManagement()));

	audio_state->registerSoundPlayer(ringtone_manager->getMediaPlayer());

	connect(settings, SIGNAL(beepChanged()),
		this, SLOT(beepChanged()));
	if (settings->getBeep())
		audio_state->enableState(AudioState::Beep);

	bool sound_diffusion_enabled = !(*bt_global::config)[SOURCE_ADDRESS].isEmpty();

	if (sound_diffusion_enabled)
	{
		AudioVideoPlayer *sound_diffusion_player = 0;

		// find all source objects
		ObjectModel sources;

		sources.setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdSoundSource);

		for (int i = 0; i < sources.getCount(); ++i)
		{
			SourceMedia *source = qobject_cast<SourceMedia *>(sources.getObject(i));

			if (source)
			{
				sound_diffusion_player = static_cast<AudioVideoPlayer *>(source->getAudioVideoPlayer());
				break;
			}
		}

		if (sound_diffusion_player)
		{
			MultiMediaPlayer *player = static_cast<MultiMediaPlayer *>(sound_diffusion_player->getMediaPlayer());

			audio_state->registerSoundDiffusionPlayer(player);
		}
	}
}

void GlobalProperties::parseSettings(logger *log)
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	bool debug_timing_enabled = false;
	foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
	{
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case Beep:
			settings->setBeep(parseEnableFlag(xml_obj));
			break;
		case Password:
			parsePassword(xml_obj, &password, &password_enabled);
			break;
		case DebugTouchscreen:
			debug_touchscreen = parseEnableFlag(xml_obj);
			break;
		case DebugEventTiming:
			debug_timing_enabled = parseEnableFlag(xml_obj);
			break;
		case RingtoneS0:
			ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace1, parseRingtone(xml_obj));
			break;
		case RingtoneS1:
			ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace2, parseRingtone(xml_obj));
			break;
		case RingtoneS2:
			ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace3, parseRingtone(xml_obj));
			break;
		case RingtoneS3:
			ringtone_manager->setRingtone(RingtoneManager::CCTVExternalPlace4, parseRingtone(xml_obj));
			break;
		case RingtoneInternal:
			ringtone_manager->setRingtone(RingtoneManager::InternalIntercom, parseRingtone(xml_obj));
			break;
		case RingtoneExternal:
			ringtone_manager->setRingtone(RingtoneManager::ExternalIntercom, parseRingtone(xml_obj));
			break;
		case RingtoneDoor:
			ringtone_manager->setRingtone(RingtoneManager::IntercomFloorcall, parseRingtone(xml_obj));
			break;
		case RingtoneAlarm:
			ringtone_manager->setRingtone(RingtoneManager::Alarm, parseRingtone(xml_obj));
			break;
		case RingtoneMessage:
			ringtone_manager->setRingtone(RingtoneManager::Message, parseRingtone(xml_obj));
			break;
		case VolumeBeep:
			audio_state->setVolume(AudioState::BeepVolume, parseVolume(xml_obj));
			break;
		case VolumeLocalPlayback:
			audio_state->setVolume(AudioState::LocalPlaybackVolume, parseVolume(xml_obj));
			break;
		case VolumeRingtone:
			audio_state->setVolume(AudioState::RingtoneVolume, parseVolume(xml_obj));
			break;
		case VolumeVdeCall:
			audio_state->setVolume(AudioState::VdeCallVolume, parseVolume(xml_obj));
			break;
		case VolumeIntercomCall:
			audio_state->setVolume(AudioState::IntercomCallVolume, parseVolume(xml_obj));
			break;
		}
	}

	debug_timing = new DebugTiming(log, debug_timing_enabled, this);
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

	qDebug() << "Writing" <<  transmitted_value << "to /sys/devices/platform/omapdss/display0/enabled";
#if !defined(BT_HARDWARE_X11)
	setMonitorEnabled(transmitted_value);
#endif

	emit monitorOffChanged();
}

bool GlobalProperties::getDebugTs()
{
	return debug_touchscreen;
}

DebugTiming *GlobalProperties::getDebugTiming()
{
	return debug_timing;
}

QObject *GlobalProperties::getHardwareKeys() const
{
	return hardware_keys;
}

QVariantList GlobalProperties::getStockImagesFolder() const
{
	QVariantList result;

#if defined(BT_HARDWARE_X11)
	QString base = getBasePath();
	QStringList base_list = base.split("/");
	foreach (const QString &comp, base_list)
		result.append(comp);
	result.append("images");
#else
	QString extra = getExtraPath();
	QStringList extra_list = extra.split("/");
	foreach (const QString &comp, extra_list)
		result.append(comp);
	result.append("1");
#endif

	return result;
}

QObject *GlobalProperties::getDefaultExternalPlace() const
{
	return default_external_place;
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

AudioVideoPlayer *GlobalProperties::getAudioVideoPlayer() const
{
	return video_player;
}

PhotoPlayer *GlobalProperties::getPhotoPlayer() const
{
	return photo_player;
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

void GlobalProperties::setMaxTravelledDistanceOnLastMove(QPoint value)
{
	max_travelled_distance = value;
}

void GlobalProperties::setMainWidget(QDeclarativeView *_viewport)
{
	main_widget = _viewport;
}

QString GlobalProperties::takeScreenshot(QRect rect, QString filename)
{
	QWidget *viewport = main_widget->viewport();

	if (!viewport)
		viewport = main_widget;

	QImage image = QPixmap::grabWidget(viewport, rect).toImage();

#if defined(BT_HARDWARE_X11)
	QDir().mkdir(EXTRA_11_DIR);
#endif

	QDir customDir = QDir(EXTRA_11_DIR);
	QString fn = customDir.canonicalPath() + "/" + filename;
	image.save(fn);

	return fn;
}

QString GlobalProperties::saveInCustomDirIfNeeded(QString filename, QString new_filename, QSize size)
{
	QString result;

#if defined(BT_HARDWARE_X11)
	QDir().mkdir(EXTRA_11_DIR);
#endif

	QDir customDir = QDir(EXTRA_11_DIR);

	if (filename.startsWith(customDir.canonicalPath() + "/"))
		result = filename;
	else
		result = customDir.canonicalPath() + "/" + new_filename + "." + filename.split(".").last();

	QImage image = QImage(filename);
	if (size.isValid())
		image = image.scaled(size);

	image.save(result);

	return result;
}

void GlobalProperties::beep()
{
	QString path = getExtraPath() + "10/beep.wav";

	if (QFile::exists(path) && audio_state->getState() == AudioState::Beep)
		sound_player->play(path);
}

QPoint GlobalProperties::maxTravelledDistanceOnLastMove() const
{
	return max_travelled_distance;
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

void GlobalProperties::volumeChanged(int state, int volume)
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	switch (state)
	{
	case AudioState::BeepVolume:
		setVolume(document, VolumeBeep, volume);
		break;
	case AudioState::LocalPlaybackVolume:
		video_player->setVolume(volume);
		setVolume(document, VolumeLocalPlayback, volume);
		break;
	case AudioState::RingtoneVolume:
		setVolume(document, VolumeRingtone, volume);
		break;
	case AudioState::VdeCallVolume:
		setVolume(document, VolumeVdeCall, volume);
		break;
	case AudioState::IntercomCallVolume:
		setVolume(document, VolumeIntercomCall, volume);
		break;
	}
	configurations->saveConfiguration(SETTINGS_FILE);
}

void GlobalProperties::ringtoneChanged(int ringtone, int index)
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	switch (ringtone)
	{
	case RingtoneManager::Alarm:
		setRingtone(document, RingtoneAlarm, index);
		break;
	case RingtoneManager::Message:
		setRingtone(document, RingtoneMessage, index);
		break;
	case RingtoneManager::CCTVExternalPlace1:
		setRingtone(document, RingtoneS0, index);
		break;
	case RingtoneManager::CCTVExternalPlace2:
		setRingtone(document, RingtoneS1, index);
		break;
	case RingtoneManager::CCTVExternalPlace3:
		setRingtone(document, RingtoneS2, index);
		break;
	case RingtoneManager::CCTVExternalPlace4:
		setRingtone(document, RingtoneS3, index);
		break;
	case RingtoneManager::InternalIntercom:
		setRingtone(document, RingtoneInternal, index);
		break;
	case RingtoneManager::ExternalIntercom:
		setRingtone(document, RingtoneExternal, index);
		break;
	case RingtoneManager::IntercomFloorcall:
		setRingtone(document, RingtoneDoor, index);
		break;
	}
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

void GlobalProperties::setPassword(QString _password)
{
	if (password == _password)
		return;
	password = _password;
	emit passwordChanged();
	::setPassword(configurations->getConfiguration(SETTINGS_FILE), Password, password, password_enabled);
	configurations->saveConfiguration(SETTINGS_FILE);
}

QString GlobalProperties::getPassword() const
{
	return password;
}

void GlobalProperties::setPasswordEnabled(bool enabled)
{
	if (password_enabled == enabled)
		return;
	password_enabled = enabled;
	emit passwordEnabledChanged();
	::setPassword(configurations->getConfiguration(SETTINGS_FILE), Password, password, password_enabled);
	configurations->saveConfiguration(SETTINGS_FILE);
}

bool GlobalProperties::isPasswordEnabled() const
{
	return password_enabled;
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
	if (!language_map.contains(layout))
		return;

	// setting the allowed layout list to the current layout is a roundabout way of disabling
	// the swipe left/right gesture used to change keyboard layout
	allowed_layouts->set(QStringList() << language_map[layout]);
	keyboard_layout->set(language_map[layout]);
#else
	Q_UNUSED(layout);
#endif
}

QStringList GlobalProperties::getKeyboardLayouts() const
{
#ifdef BT_MALIIT
	return language_map.keys();
#else
	return QStringList();
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
			allowed_layouts = entry;

			foreach (QString value, entry->attributes()[Maliit::SettingEntryAttributes::valueDomain].toStringList())
				if (value.section(':', 1).endsWith("_bticino"))
					language_map[value.section(':', 1)] = value;

			emit keyboardLayoutsChanged();
		}
		else if (entry->key() == "/maliit/onscreen/active")
		{
			keyboard_layout = entry;

			connect(keyboard_layout.data(), SIGNAL(valueChanged()),
				this, SIGNAL(keyboardLayoutChanged()));
		}
	}

	// see comment in setKeyboardLayout()
	setKeyboardLayout(getKeyboardLayout());
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
