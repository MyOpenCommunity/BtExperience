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
#include "imagesaver.h"
#include "medialink.h"
#include "bt_global_config.h"

#include <QTimer>
#include <QDateTime>
#include <QScreen>
#include <QPixmap>
#include <QDeclarativeView>
#include <QtDeclarative>

#if !defined(BT_HARDWARE_X11)
#include <devicelghal.h>
#endif

#define LAZY_UPDATE_INTERVAL 2000
#define LAZY_UPDATE_COUNT 2

#define CPU_FREQ_DEVICE    "/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
#define CPU_CLOCK_IDLE    300000
#define CPU_CLOCK_ACTIVE  1000000

#define BROWSER_HISTORY_SIZE 10

namespace
{
	enum Parsing
	{
		Beep = 14001,
		Brightness = 14151,
		RingtoneS0 = 14101,
		RingtoneS1,
		RingtoneS2,
		RingtoneS3,
		RingtoneInternal,
		RingtoneExternal,
		RingtoneDoor,
		// 14108 has been removed from possible values
		RingtoneAlarm = 14109,
		RingtoneMessage,
		VolumeBeep = 14121,
		VolumeLocalPlayback,
		VolumeRingtone,
		VolumeVdeCall,
		VolumeIntercomCall
	};

	void setRingtone(QDomDocument document, int id, int ringtone, QString description)
	{
		foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == id)
			{
				foreach (QDomNode ist, getChildren(xml_obj, "ist"))
				{
					setAttribute(ist, "id_ringtone", QString::number(ringtone));
					setAttribute(ist, "descr", description);
				}
				break;
			}
		}
	}

	void parseRingtone(QDomNode xml_node, RingtoneManager *ringtone_manager, RingtoneManager::Ringtone ringtone)
	{
		XmlObject v(xml_node);

		foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
		{
			v.setIst(ist);
			ringtone_manager->setRingtone(ringtone, v.intValue("id_ringtone"), v.value("descr"));
		}
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

	void setBrowser(QDomDocument document, int id, QString home_page, bool keep_history)
	{
		foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == id)
			{
				foreach (QDomNode ist, getChildren(xml_obj, "ist"))
				{
					setAttribute(ist, "homepage_url", home_page);
					setAttribute(ist, "history_enabled", QString::number(keep_history));
				}
				break;
			}
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
	sound_diffusion_player = 0;
	audio_state = new AudioState(this);
	sound_player = 0;
	ringtone_manager = new RingtoneManager(getExtraPath() + "5/ringtones.xml", new MultiMediaPlayer(this), audio_state, this);
	hardware_keys = new HwKeys(this);
	screen_state = new ScreenState(this);
	calibration = new Calibration(this);
	browser = new BrowserProcess(this);
	home_page_url = QString("http://www.google.com");
	keeping_history = true;
	upnp_status = UpnpInactive;
	cpu_frequency = 0;

	if (!(*bt_global::config)[DEFAULT_PE].isEmpty())
		default_external_place = new ExternalPlace(QString(), ObjectInterface::IdExternalPlace,
							   (*bt_global::config)[DEFAULT_PE]);
	else
		default_external_place = 0;

	password = (*bt_global::config)[USER_PASSWORD];
	password_enabled = (*bt_global::config)[USER_PASSWORD_ENABLED] == "1" ? true : false;
	screen_state->setPasswordEnabled(password_enabled);

	parseSettings();
	parseBrowser();

	screen_state->enableState(ScreenState::Normal);
	screen_state->enableState(ScreenState::ScreenOff);

	connect(ringtone_manager, SIGNAL(ringtoneChanged(int,int,QString)),
		this, SLOT(ringtoneChanged(int,int,QString)));
	connect(audio_state, SIGNAL(volumeChanged(int,int)),
		this, SLOT(volumeChanged(int,int)));
	connect(audio_state, SIGNAL(stateChanged(AudioState::State,AudioState::State)),
		this, SLOT(updateCpuFrequency()));
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
	video_player->setVolume(audio_state->getVolume(AudioState::LocalPlaybackVolume));
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

	connect(video_player->getMediaPlayer(), SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)),
		this, SLOT(manageUpnpPlayers()));
	connect(photo_player, SIGNAL(playingChanged()), this, SLOT(manageUpnpPlayers()));

	bool sound_diffusion_enabled = !(*bt_global::config)[SOURCE_ADDRESS].isEmpty();

	if (sound_diffusion_enabled)
	{
		// find all source objects
		ObjectModel sources;

		sources.setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdSoundSource);

		for (int i = 0; i < sources.getCount(); ++i)
		{
			SourceMedia *source = qobject_cast<SourceMedia *>(sources.getObject(i));

			if (source)
			{
				sound_diffusion_player = static_cast<AudioVideoPlayer *>(source->getAudioVideoPlayer());
				audio_state->registerLocalSource(source->getSource());
				break;
			}
		}

		if (sound_diffusion_player)
		{
			MultiMediaPlayer *player = static_cast<MultiMediaPlayer *>(sound_diffusion_player->getMediaPlayer());

			audio_state->registerSoundDiffusionPlayer(player);

			connect(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)),
				this, SLOT(manageUpnpPlayers()));
			connect(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)),
				this, SLOT(updateCpuFrequency()));
		}

#if !defined(BT_HARDWARE_X11)
		// enable sound diffusion source
		if (!hal_set_difson_carriers()) qDebug() << "\nError setting difson carriers\n";
#endif
	}
}

void GlobalProperties::deleteHistory()
{
	browser->clearHistory();
}

QString GlobalProperties::getHomePageUrl() const
{
	return home_page_url;
}

QString GlobalProperties::getMultimediaSourceAddress() const
{
	return (*bt_global::config)[SOURCE_ADDRESS];
}

void GlobalProperties::setHomePageUrl(QString new_value)
{
	if (home_page_url == new_value)
		return;
	home_page_url = new_value;
	emit homePageUrlChanged();
	::setBrowser(configurations->getConfiguration(ARCHIVE_FILE), MediaLink::Browser, home_page_url, keeping_history);
	configurations->saveConfiguration(ARCHIVE_FILE);
}

bool GlobalProperties::getKeepingHistory() const
{
	return keeping_history;
}

void GlobalProperties::setKeepingHistory(bool new_value)
{
	if (keeping_history == new_value)
		return;
	keeping_history = new_value;
	emit keepingHistoryChanged();
	browser->setPersistentHistory(keeping_history);
	::setBrowser(configurations->getConfiguration(ARCHIVE_FILE), MediaLink::Browser, home_page_url, keeping_history);
	configurations->saveConfiguration(ARCHIVE_FILE);
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
		case Brightness:
			screen_state->setNormalBrightness(parseBrightness(xml_obj));
			break;
		case RingtoneS0:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::CCTVExternalPlace1);
			break;
		case RingtoneS1:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::CCTVExternalPlace2);
			break;
		case RingtoneS2:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::CCTVExternalPlace3);
			break;
		case RingtoneS3:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::CCTVExternalPlace4);
			break;
		case RingtoneInternal:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::InternalIntercom);
			break;
		case RingtoneExternal:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::ExternalIntercom);
			break;
		case RingtoneDoor:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::IntercomFloorcall);
			break;
		case RingtoneAlarm:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::Alarm);
			break;
		case RingtoneMessage:
			parseRingtone(xml_obj, ringtone_manager, RingtoneManager::Message);
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
}

void GlobalProperties::parseBrowser()
{
	QDomDocument document = configurations->getConfiguration(ARCHIVE_FILE);

	foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
	{
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case MediaLink::Browser:
		{
			XmlObject v(xml_obj);

			foreach (const QDomNode &ist, getChildren(xml_obj, "ist"))
			{
				v.setIst(ist);
				home_page_url = v.value("homepage_url");
				keeping_history = v.intValue("history_enabled");
				browser->setHistorySize(BROWSER_HISTORY_SIZE);
				browser->setPersistentHistory(keeping_history);
			}

			break;
		}
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

QVariantList GlobalProperties::getDefaultPathAsVariantList(QString base_dir) const
{
	QVariantList result;

#if defined(BT_HARDWARE_X11)
	Q_UNUSED(base_dir);
	QString base = getBasePath();
	QStringList base_list = base.split("/");
	foreach (const QString &comp, base_list)
		result.append(comp);
#else
	QString extra = getExtraPath();
	QStringList extra_list = extra.split("/");
	foreach (const QString &comp, extra_list)
		result.append(comp);
	result.append(base_dir);
#endif

	return result;
}

QVariantList GlobalProperties::getCardStockImagesFolder() const
{
	QVariantList result = getDefaultPathAsVariantList("1");
	result << "images" << "card";
	return result;
}

QVariantList GlobalProperties::getBackgroundStockImagesFolder() const
{
	QVariantList result = getDefaultPathAsVariantList("1");
	result << "images" << "background";
	return result;
}

QVariantList GlobalProperties::getCardCustomImagesFolder() const
{
	QVariantList result = getDefaultPathAsVariantList("12");
#if defined(BT_HARDWARE_X11)
	result << ".." << ".." << ".." << "bin" << "x86" << "12" << "." << ".";
#endif
	result << "custom_images" << "card";
	return result;
}

QVariantList GlobalProperties::getBackgroundCustomImagesFolder() const
{
	QVariantList result = getDefaultPathAsVariantList("12");
#if defined(BT_HARDWARE_X11)
	result << ".." << ".." << ".." << "bin" << "x86" << "12" << "." << ".";
#endif
	result << "custom_images" << "background";
	return result;
}

QVariantList GlobalProperties::getX11PrependPath() const
{
	QVariantList result;
	// last 2 elements are removed by the getPath function, so adds 2 fake elements
	// to have right path
	result << ".." << ".." << ".." << "bin" << "x86" << "12" << "." << ".";
	return result;
}

void GlobalProperties::createExtra12Folders()
{
#if defined(BT_HARDWARE_X11)
	QDir().mkdir(EXTRA_12_DIR);
#endif

	QDir(EXTRA_12_DIR).mkdir("images");
	QDir(EXTRA_12_DIR).mkdir("custom_images");

	QDir(QString("%1/%2").arg(EXTRA_12_DIR).arg("images")).mkdir("background");
	QDir(QString("%1/%2").arg(EXTRA_12_DIR).arg("images")).mkdir("card");
	QDir(QString("%1/%2").arg(EXTRA_12_DIR).arg("custom_images")).mkdir("background");
	QDir(QString("%1/%2").arg(EXTRA_12_DIR).arg("custom_images")).mkdir("card");
}

QString GlobalProperties::takeScreenshot(QRect rect, QString filename)
{
	QWidget *viewport = main_widget->viewport();

	if (!viewport)
		viewport = main_widget;

	QImage image = QPixmap::grabWidget(viewport, rect).toImage();

	createExtra12Folders();
	QDir customDir = QDir(EXTRA_12_DIR);

	QString fn = customDir.canonicalPath() + "/" + filename;

	int progressive_id = computeMaxId(fn) + 1;
	fn = computeSaveFilePath(fn, progressive_id);

	image.save(fn);

	cleanOldFiles(fn, progressive_id);

	return fn;
}

QString GlobalProperties::saveInCustomDirIfNeeded(QObject *object, QString property, QString filename, QString new_filename, QSize size)
{
	QString result;

	createExtra12Folders();
	QDir customDir = QDir(EXTRA_12_DIR);

	if (filename.startsWith(customDir.canonicalPath() + "/"))
		result = filename;
	else
		result = customDir.canonicalPath() + "/" + new_filename + "." + filename.split(".").last();

	ImageSaver *downloader = new ImageSaver(this);
	connect(downloader, SIGNAL(jobDone(ImageSaver*)), this, SLOT(cleanImageSaver(ImageSaver*)));
	downloader->startDownload(object, property, filename, result, size);
	return result;
}

QObject *GlobalProperties::getDefaultExternalPlace() const
{
	return default_external_place;
}

QString GlobalProperties::getPIAddress() const
{
	return (*bt_global::config)[PI_ADDRESS];
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

void GlobalProperties::cleanImageSaver(ImageSaver *cleanee)
{
	cleanee->deleteLater();
}

int GlobalProperties::getPathviewOffset(int pathview_id)
{
	return pathview_offsets[pathview_id];
}

void GlobalProperties::setPathviewOffset(int pathview_id, int value)
{
	pathview_offsets[pathview_id] = value;
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

void GlobalProperties::ringtoneChanged(int ringtone, int index, QString description)
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	switch (ringtone)
	{
	case RingtoneManager::Alarm:
		setRingtone(document, RingtoneAlarm, index, description);
		break;
	case RingtoneManager::Message:
		setRingtone(document, RingtoneMessage, index, description);
		break;
	case RingtoneManager::CCTVExternalPlace1:
		setRingtone(document, RingtoneS0, index, description);
		break;
	case RingtoneManager::CCTVExternalPlace2:
		setRingtone(document, RingtoneS1, index, description);
		break;
	case RingtoneManager::CCTVExternalPlace3:
		setRingtone(document, RingtoneS2, index, description);
		break;
	case RingtoneManager::CCTVExternalPlace4:
		setRingtone(document, RingtoneS3, index, description);
		break;
	case RingtoneManager::InternalIntercom:
		setRingtone(document, RingtoneInternal, index, description);
		break;
	case RingtoneManager::ExternalIntercom:
		setRingtone(document, RingtoneExternal, index, description);
		break;
	case RingtoneManager::IntercomFloorcall:
		setRingtone(document, RingtoneDoor, index, description);
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

	browser->setClicksBlocked(screen_state->getClicksBlocked());
}

void GlobalProperties::manageUpnpPlayers()
{
	bool sound_diffusion = sound_diffusion_player && sound_diffusion_player->isPlaying() && sound_diffusion_player->isUpnp();
	bool local_media = video_player && video_player->isPlaying() && video_player->isUpnp();
	bool photo = photo_player && photo_player->isPlaying() && photo_player->isUpnp();

	Q_ASSERT_X(sound_diffusion + local_media + photo <= 1, "GlobalProperties::manageUpnpPlayers",
		   "More than one player can't be active at the same time for UPnP");

	UpnpStatus new_status = UpnpInactive;

	if (sound_diffusion)
		new_status = UpnpSoundDiffusion;
	else if (local_media)
		new_status = UpnpLocalMedia;
	else if (photo)
		new_status = UpnpLocalPhoto;

	// required in case there is a paused UPnP player: resume will not work after another UPnP
	// player re-used the playlist
	if (video_player->isUpnp() && new_status != UpnpLocalMedia && new_status != UpnpInactive)
		video_player->terminate();
	if (sound_diffusion_player &&
		sound_diffusion_player->isUpnp() && new_status != UpnpSoundDiffusion && new_status != UpnpInactive)
		sound_diffusion_player->terminate();
	if (photo_player->isUpnp() && new_status != UpnpLocalPhoto && new_status != UpnpInactive)
		photo_player->terminate();

	if (new_status == upnp_status)
		return;
	upnp_status = new_status;
	emit upnpStatusChanged();
}

void GlobalProperties::updateCpuFrequency()
{
	MultiMediaPlayer *player = sound_diffusion_player ? qobject_cast<MultiMediaPlayer *>(sound_diffusion_player->getMediaPlayer()) : 0;
	int new_cpu_frequency;

	if (audio_state->getState() == AudioState::Screensaver &&
		(!player || player->getAudioOutputState() == MultiMediaPlayer::AudioOutputStopped))
		new_cpu_frequency = CPU_CLOCK_IDLE;
	else
		new_cpu_frequency = CPU_CLOCK_ACTIVE;

	if (cpu_frequency == new_cpu_frequency)
		return;
	cpu_frequency = new_cpu_frequency;

	QFile dev(CPU_FREQ_DEVICE);
	QByteArray freq = QByteArray::number(new_cpu_frequency);

	qDebug() << "Disabled: Setting CPU min frequency to" << freq;

	if (!dev.open(QFile::WriteOnly) || dev.write(freq) != freq.size())
		qWarning() << "Error setting CPU min frequency to" << freq;

}

GlobalProperties::UpnpStatus GlobalProperties::getUpnpStatus() const
{
	return upnp_status;
}

bool GlobalProperties::getUpnpPlaying() const
{
	return upnp_status != UpnpInactive;
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
	::setConfValue(configurations->getConfiguration(CONF_FILE), "generale/password/pwd", password);
	configurations->saveConfiguration(CONF_FILE);
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
	::setConfValue(configurations->getConfiguration(CONF_FILE), "generale/password/enabled", QString::number(password_enabled));
	configurations->saveConfiguration(CONF_FILE);
}

bool GlobalProperties::isPasswordEnabled() const
{
	return password_enabled;
}
