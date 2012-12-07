#include "globalproperties.h"
#include "guisettings.h"
#include "playlistplayer.h"
#include "audiostate.h"
#include "screenstate.h"
#include "mediaplayer.h" // SoundPlayer
#include "mediaobjects.h" // SourceMedia
#include "ringtonemanager.h"
#include "configfile.h"
#include "devices_cache.h"
#include "xmlobject.h"
#include "hwkeys.h"
#include "calibration.h"
#include "browserprocess.h"

#include <QTimer>
#include <QDateTime>
#include <QScreen>
#include <QPixmap>
#include <QDeclarativeView>
#include <QtDeclarative>

#define LAZY_UPDATE_INTERVAL 2000
#define LAZY_UPDATE_COUNT 2


namespace
{
	enum Parsing
	{
		Beep = 14001,
		Password = 14003,
		Brightness = 14151,
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

	void setRingtone(QDomDocument document, int id, int ringtone)
	{
		setIntSetting(document, id, "id_ringtone", ringtone);
	}

	int parseRingtone(QDomNode xml_node)
	{
		return parseIntSetting(xml_node, "id_ringtone");
	}

	void setVolume(QDomDocument document, int id, int volume)
	{
		setIntSetting(document, id, "volume", volume);
	}

	int parseVolume(QDomNode xml_node)
	{
		return parseIntSetting(xml_node, "volume");
	}

	void setBrightness(QDomDocument document, int id, int brightness)
	{
		setIntSetting(document, id, "brightness", brightness);
	}

	int parseBrightness(QDomNode xml_node)
	{
		return parseIntSetting(xml_node, "brightness");
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
}


GlobalProperties::GlobalProperties(logger *log) : GlobalPropertiesCommon(log)
{
	delayed_frame_timer = new QTimer(this);
	delayed_frame_timer->setInterval(LAZY_UPDATE_INTERVAL);

	connect(delayed_frame_timer, SIGNAL(timeout()),
		this, SLOT(sendDelayedFrames()));

	qmlRegisterUncreatableType<AudioState>("BtExperience", 1, 0, "AudioState", "");
	qmlRegisterUncreatableType<RingtoneManager>("BtExperience", 1, 0, "RingtoneManager", "");
	qmlRegisterUncreatableType<DebugTiming>("BtExperience", 1, 0, "DebugTiming", "");
	qmlRegisterUncreatableType<Calibration>("BtExperience", 1, 0, "Calibration", "");


	configurations = new ConfigFile(this);
	photo_player = new PhotoPlayer(this);
	video_player = 0;
	audio_state = new AudioState(this);
	sound_player = 0;
	ringtone_manager = new RingtoneManager(getExtraPath() + "5/ringtones.xml", new MultiMediaPlayer(this), audio_state, this);
	hardware_keys = new HwKeys(this);
	screen_state = new ScreenState(this);
	calibration = new Calibration(this);
	browser = new BrowserProcess(this);

	if (!(*bt_global::config)[DEFAULT_PE].isEmpty())
		default_external_place = new ExternalPlace(QString(), ObjectInterface::IdExternalPlace,
							   (*bt_global::config)[DEFAULT_PE]);
	else
		default_external_place = 0;

	parseSettings();

	screen_state->enableState(ScreenState::Normal);
	screen_state->enableState(ScreenState::ScreenOff);

	connect(ringtone_manager, SIGNAL(ringtoneChanged(int,int)),
		this, SLOT(ringtoneChanged(int,int)));
	connect(audio_state, SIGNAL(volumeChanged(int,int)),
		this, SLOT(volumeChanged(int,int)));
	connect(screen_state, SIGNAL(stateChanged(ScreenState::State,ScreenState::State)),
		this, SLOT(screenStateChangedManagement()));
	connect(browser, SIGNAL(clicked()), screen_state, SLOT(simulateClick()));
	connect(screen_state, SIGNAL(normalBrightnessChanged()),
		this, SLOT(brightnessChanged()));
}

void GlobalProperties::initAudio()
{
	if (video_player)
		return;

	Q_ASSERT_X(bt_global::config, "GlobalProperties::initAudio", "BtObjects plugin not initialized yet");

	video_player = new AudioVideoPlayer(this);
	video_player->setVolume(audio_state->getStateVolume(AudioState::LocalPlaybackVolume));
	emit audioVideoPlayerChanged();

	sound_player = new SoundPlayer(this);

	audio_state->registerMediaPlayer(qobject_cast<MultiMediaPlayer *>(video_player->getMediaPlayer()));
	audio_state->registerBeep(sound_player);
	audio_state->enableState(AudioState::Idle);

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
		case Password:
			parsePassword(xml_obj, &password, &password_enabled);
			screen_state->setPasswordEnabled(password_enabled);
			break;
		case Brightness:
			screen_state->setNormalBrightness(parseBrightness(xml_obj));
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
			audio_state->setStateVolume(AudioState::BeepVolume, parseVolume(xml_obj));
			break;
		case VolumeLocalPlayback:
			audio_state->setStateVolume(AudioState::LocalPlaybackVolume, parseVolume(xml_obj));
			break;
		case VolumeRingtone:
			audio_state->setStateVolume(AudioState::RingtoneVolume, parseVolume(xml_obj));
			break;
		case VolumeVdeCall:
			audio_state->setStateVolume(AudioState::VdeCallVolume, parseVolume(xml_obj));
			break;
		case VolumeIntercomCall:
			audio_state->setStateVolume(AudioState::IntercomCallVolume, parseVolume(xml_obj));
			break;
		}
	}
}

QObject *GlobalProperties::getHardwareKeys() const
{
	return hardware_keys;
}

QObject *GlobalProperties::getCalibration() const
{
	return calibration;
}

QObject *GlobalProperties::getBrowser() const
{
	return browser;
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

QObject *GlobalProperties::getScreenState() const
{
	return screen_state;
}

QObject *GlobalProperties::getRingtoneManager() const
{
	return ringtone_manager;
}

void GlobalProperties::setMaxTravelledDistanceOnLastMove(QPoint value)
{
	max_travelled_distance = value;
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

void GlobalProperties::brightnessChanged()
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	setBrightness(document, Brightness, screen_state->getNormalBrightness());
	configurations->saveConfiguration(SETTINGS_FILE);
}

void GlobalProperties::screenStateChangedManagement()
{
	if (screen_state->getState() == ScreenState::Screensaver ||
	    screen_state->getState() == ScreenState::ScreenOff)
	{
		audio_state->enableState(AudioState::Screensaver);
		delayed_frame_timer->start();
	}
	else
	{
		audio_state->disableState(AudioState::Screensaver);
		delayed_frame_timer->stop();
	}
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
	screen_state->setPasswordEnabled(enabled);
	emit passwordEnabledChanged();
	::setPassword(configurations->getConfiguration(SETTINGS_FILE), Password, password, password_enabled);
	configurations->saveConfiguration(SETTINGS_FILE);
}

bool GlobalProperties::isPasswordEnabled() const
{
	return password_enabled;
}
