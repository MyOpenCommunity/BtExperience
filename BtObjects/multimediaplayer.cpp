#include "multimediaplayer.h"
#include "mediaplayer.h"
#include "gstmediaplayer.h"

#include "generic_functions.h"

#include <QTime>
#include <QTimer>
#include <QDir>
#include <QPluginLoader>
#include <QCoreApplication> // qApp

#define INFO_POLL_INTERVAL 500
#define SEEK_TICK_TIMEOUT 4

namespace
{
	bool isVideoFile(QString track)
	{
		QStringList extensions = getFileExtensions(EntryInfo::VIDEO);
		QString ext = track.mid(track.lastIndexOf(".") + 1);
		return extensions.contains(ext);
	}

	// internal state entered after calling releaseOutputDevices: the reported player state is Paused,
	// output state is AudioOutputStopped and the player process is not running; calling resume() works
	// as if the player were actually paused
	const int OutputDeviceReleased = -2;
}


MultiMediaPlayer::MultiMediaPlayer(QObject *parent) :
	QObject(parent)
{
	gst_player = new GstMediaPlayer(this);
	player = new MediaPlayer(this);

	is_video_track = false;
	is_releasing_device = false;
	player_state = Stopped;
	mediaplayer_output_mode = MediaPlayer::OutputAll;
	volume = 100;
	mute = false;
	is_changing_track = false;

	connect(player, SIGNAL(mplayerStarted()), SLOT(mplayerStarted()));
	connect(player, SIGNAL(mplayerResumed()), SLOT(mplayerResumed()));
	connect(player, SIGNAL(mplayerDone()), SLOT(mplayerDone()));
	connect(player, SIGNAL(mplayerStopped()), SLOT(mplayerStopped()));
	connect(player, SIGNAL(mplayerPaused()), SLOT(mplayerPaused()));

	connect(player, SIGNAL(playingInfoUpdated(QMap<QString,QString>)),
		SLOT(playerInfoReceived(QMap<QString,QString>)));
	connect(player, SIGNAL(outputAvailable()), this, SLOT(playerOutputAvailable()));

	connect(gst_player, SIGNAL(gstPlayerStarted()), SLOT(mplayerStarted()));
	connect(gst_player, SIGNAL(gstPlayerResumed()), SLOT(mplayerResumed()));
	connect(gst_player, SIGNAL(gstPlayerDone()), SLOT(mplayerDone()));
	connect(gst_player, SIGNAL(gstPlayerStopped()), SLOT(mplayerStopped()));
	connect(gst_player, SIGNAL(gstPlayerPaused()), SLOT(mplayerPaused()));

	connect(gst_player, SIGNAL(playingInfoUpdated(QMap<QString,QString>)),
		SLOT(gstPlayerInfoReceived(QMap<QString,QString>)));
	connect(gst_player, SIGNAL(outputAvailable()), this, SLOT(playerOutputAvailable()));

	info_poll_timer = new QTimer(this);
	info_poll_timer->setSingleShot(true);
	info_poll_timer->setInterval(INFO_POLL_INTERVAL);
	connect(info_poll_timer, SIGNAL(timeout()), this, SLOT(readPlayerInfo()));

	qRegisterMetaType<MultiMediaPlayer::PlayerState>();
	qRegisterMetaType<MultiMediaPlayer::AudioOutputState>();
}

void MultiMediaPlayer::setGlobalCommandLineArguments(QString executable, QStringList audio, QStringList video)
{
	MediaPlayer::setGlobalCommandLineArguments(executable, audio, video);
}

void MultiMediaPlayer::setCommandLineArguments(QStringList audio, QStringList video)
{
	player->setCommandLineArguments(audio, video);
}

QString MultiMediaPlayer::getCurrentSource() const
{
	return current_source;
}

QVariantMap MultiMediaPlayer::getTrackInfo() const
{
	return track_info;
}

MultiMediaPlayer::PlayerState MultiMediaPlayer::getPlayerState() const
{
	if (player_state == OutputDeviceReleased)
		return Paused;
	else
		return static_cast<PlayerState>(player_state);
}

MultiMediaPlayer::AudioOutputState MultiMediaPlayer::getAudioOutputState() const
{
	if (player_state == Stopped || player_state == OutputDeviceReleased)
		return AudioOutputStopped;
	else
		return AudioOutputActive;
}

void MultiMediaPlayer::setVolume(int newValue)
{
	if (volume == newValue || newValue < 0 || newValue > 100)
		return; // nothing to do

	// TODO set new volume value on device
	volume = newValue;
	emit volumeChanged(volume);
}

void MultiMediaPlayer::setMute(bool newValue)
{
	if (mute == newValue)
		return; // nothing to do

	// TODO mute/unmute the device
	mute = newValue;
	emit muteChanged(mute);
}

QRect MultiMediaPlayer::getVideoRect() const
{
	return video_rect;
}

void MultiMediaPlayer::setVideoRect(QRect rect)
{
	if (rect == video_rect)
		return;
	video_rect = rect;
	if (gst_player)
		gst_player->setPlayerRect(video_rect);
	emit videoRectChanged(video_rect);
}

void MultiMediaPlayer::playerOutputAvailable()
{
	// calling readPlayerInfo() too often consumes too much CPU
	if (!info_poll_timer->isActive())
		info_poll_timer->start();
}

void MultiMediaPlayer::readPlayerInfo()
{
	if (is_video_track)
		gstPlayerInfoReceived(gst_player->getPlayingInfo());
	else
		playerInfoReceived(player->getPlayingInfo());
}

namespace
{
	QStringList COMMON_ATTRIBUTES =
		QStringList() << "meta_title" << "file_name" << "meta_artist" << "meta_album"
			      << "stream_url" << "stream_title";
}

void MultiMediaPlayer::playerInfoReceived(QMap<QString, QString> new_track_info)
{
	updateTrackInfo(new_track_info);
}

void MultiMediaPlayer::gstPlayerInfoReceived(QMap<QString, QString> new_track_info)
{
	updateTrackInfo(new_track_info);
}

void MultiMediaPlayer::play()
{
	if (player_state == Playing)
		return;

	if (current_source.isEmpty())
		return;

	if (is_video_track)
		gst_player->play(video_rect, current_source);
	else
		player->play(current_source, 0, static_cast<MediaPlayer::OutputMode>(mediaplayer_output_mode));
}

void MultiMediaPlayer::playAt(float position)
{
	if (!is_video_track)
		player->play(current_source, position, static_cast<MediaPlayer::OutputMode>(mediaplayer_output_mode));
}

void MultiMediaPlayer::pause()
{
	if (player_state != Playing)
		return;

	setPlayerState(AboutToPause);
	is_video_track ? gst_player->pause() : player->pause();
}

void MultiMediaPlayer::resume()
{
	if (player_state != Paused && player_state != AboutToPause && player_state != OutputDeviceReleased)
		return;

	if (is_video_track)
	{
		if (gst_player->isInstanceRunning())
			gst_player->resume();
		else
			play();
	}
	else
	{
		if (player->isInstanceRunning())
		{
			player->resume();
		}
		else if (player_state == OutputDeviceReleased)
		{
			QTime time = track_info["current_time"].toTime();

			playAt(time.hour() * 3600 + time.minute() * 60 + time.second() + time.msec() / 1000.0);
		}
		else
			play();
	}
}

void MultiMediaPlayer::stop()
{
	setCurrentSource("");
}

void MultiMediaPlayer::releaseOutputDevices()
{
	if (player_state == Stopped || player_state == OutputDeviceReleased)
		return;
	is_releasing_device = true;
	is_video_track ? gst_player->stop() : player->stop();
}

void MultiMediaPlayer::seek(int seconds)
{
	if (player_state == Stopped)
		return;

	// TODO does not handle the case pause() -> setSource() -> seek()
	player->seek(seconds);
}

void MultiMediaPlayer::setCurrentSource(QString source)
{
	if (source == current_source)
		return;

	bool had_track_info = track_info.size() != 0;
	bool is_new_track_video = isVideoFile(source) && gst_player;

	// if playing, start playing new track right now (which automatically gets
	// track info), otherwise request track info separately
	if (source.isEmpty())
	{
		// player->stop() emits mplayerStopped which needs the new source to
		// work properly, sets new value now; please note that play may need
		// the new value, too, if empty to avoid running MPlayer with an empty
		// source
		current_source = source;
		track_info.clear();
		is_video_track? gst_player->stop() : player->stop();
	}
	else if (is_video_track)
	{
		if (is_new_track_video)
			gst_player->setTrack(source);
		else
			gst_player->stop();
		// TODO: discover file properties (duration etc) while in pause mode.
	}
	else
	{
		if (is_new_track_video)
		{
			player->stop();
		}
		else
		{
			if (player->isPlaying())
			{
				is_changing_track = true;
				player->play(source, 0, static_cast<MediaPlayer::OutputMode>(mediaplayer_output_mode));
			}
			else if (player->isPaused())
			{
				// accourding to documentation, "pausing_keep loadfile" should do the right thing, but
				// it does not, so we call quit() here to force a restart when resume() is called
				player->quit();
				// TODO maybe request after some time, in case we start playing
				player->requestInitialPlayingInfo(source);
			}
		}
	}

	current_source = source;
	is_video_track = is_new_track_video;
	track_info.clear();

	if (had_track_info)
		emit trackInfoChanged(track_info);
	emit currentSourceChanged(current_source);
}

void MultiMediaPlayer::setDefaultTrackInfo(QVariantMap new_track_info)
{
	updateTrackInfo(new_track_info);
}

void MultiMediaPlayer::updateTrackInfo(QMap<QString, QString> new_track_info)
{
	QVariantMap info;

	foreach (QString key, new_track_info.keys())
		info[key] = new_track_info[key];

	updateTrackInfo(info);
}

void MultiMediaPlayer::updateTrackInfo(QVariantMap new_track_info)
{
	QVariantMap new_info = track_info;

	foreach (QString key, COMMON_ATTRIBUTES)
		if (new_track_info.contains(key))
			new_info[key] = new_track_info[key];

	if (new_track_info.contains("total_time"))
		new_info["total_time"] = parseMPlayerTime(new_track_info["total_time"].toString());

	if (new_track_info.contains("current_time"))
		new_info["current_time"] = parseMPlayerTime(new_track_info["current_time"].toString());
	else if (new_track_info.contains("current_time_only"))
		new_info["current_time"] = parseMPlayerTime(new_track_info["current_time_only"].toString());

	if (new_info == track_info)
		return;

	track_info = new_info;
	emit trackInfoChanged(track_info);
}

void MultiMediaPlayer::setPlayerState(int new_state)
{
	AudioOutputState old_audio_output = getAudioOutputState();

	if (new_state != player_state)
	{
		player_state = new_state;
		emit playerStateChanged(getPlayerState());
	}
	if (getAudioOutputState() != old_audio_output)
		emit audioOutputStateChanged(getAudioOutputState());
}

// handle player signals

void MultiMediaPlayer::mplayerStarted()
{
	setPlayerState(Playing);
}

void MultiMediaPlayer::mplayerStopped()
{
	// handles the case when player is stopped to release output device
	if (is_releasing_device)
	{
		is_releasing_device = false;
		setPlayerState(OutputDeviceReleased);
		return;
	}
	if (is_changing_track)
	{
		is_changing_track = false;
		return;
	}
	if (player_state == Paused || player_state == AboutToPause || player_state == OutputDeviceReleased)
	{
		// this handles the pause() -> change source sequence: MPlayer is stopped,
		// but the "logical" state is still paused
		if (!current_source.isEmpty())
			return;
	}

	// for instructions order see comment in mplayerDone
	setCurrentSource("");
	setPlayerState(Stopped);
}

void MultiMediaPlayer::mplayerPaused()
{
	setPlayerState(Paused);
}

void MultiMediaPlayer::mplayerResumed()
{
	setPlayerState(Playing);
}

void MultiMediaPlayer::mplayerDone()
{
	// this should not be necessary, but sometimes GStreamer fails with an assert with exit code 0
	// since it should never happen that the player exits with success while paused, we can treat the same way
	// as if it were an error
	if (is_video_track && (player_state == Paused || player_state == AboutToPause) && !current_source.isEmpty())
	{
		mplayerStopped();
		return;
	}

	// beware: order is important!
	// Since setCurrentSource() is empty, it will stop the player and emit a
	// state change signal.
	// If someone reacts to player Stopped state, here is what happens:
	//  - state set to Stopped
	//  - outside code reacts and plays again
	//  - setCurrentSource("") will stop the player again
	//  - state set to Stopped
	// This will loop forever.
	// TODO: can we avoid calling setCurrentSource()?
	setCurrentSource("");
	setPlayerState(Stopped);
}
