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
}


MultiMediaPlayer::MultiMediaPlayer(QObject *parent) :
	QObject(parent)
{
	// Try to load plugin
	gst_player = 0;
	QDir pluginsDir = QDir(qApp->applicationDirPath() + "/plugins/");

	foreach (QString fileName, pluginsDir.entryList(QDir::Files)) {
		QPluginLoader loader(pluginsDir.absoluteFilePath(fileName));
		GstMediaPlayerInterface *plugin = qobject_cast<GstMediaPlayerInterface *>(loader.instance());
		if (plugin)
			gst_player = qobject_cast<GstMediaPlayer *>(plugin->createPlayer(this));
	}
	if (!gst_player)
		qWarning() << "Could not load GStreamer plugin in directory" << pluginsDir.absolutePath();

	player = new MediaPlayer(this);

	is_video_track = false;
	player_state = Stopped;
	output_state = AudioOutputStopped;
	mediaplayer_output_mode = MediaPlayer::OutputAll;
	seek_tick_count = 0;
	volume = 100;
	mute = false;

	connect(player, SIGNAL(mplayerStarted()), SLOT(mplayerStarted()));
	connect(player, SIGNAL(mplayerResumed()), SLOT(mplayerResumed()));
	connect(player, SIGNAL(mplayerDone()), SLOT(mplayerDone()));
	connect(player, SIGNAL(mplayerStopped()), SLOT(mplayerStopped()));
	connect(player, SIGNAL(mplayerPaused()), SLOT(mplayerPaused()));

	connect(player, SIGNAL(playingInfoUpdated(QMap<QString,QString>)),
		SLOT(playerInfoReceived(QMap<QString,QString>)));

	if (gst_player)
	{
		connect(gst_player, SIGNAL(gstPlayerStarted()), SLOT(mplayerStarted()));
		connect(gst_player, SIGNAL(gstPlayerResumed()), SLOT(mplayerResumed()));
		connect(gst_player, SIGNAL(gstPlayerDone()), SLOT(mplayerDone()));
		connect(gst_player, SIGNAL(gstPlayerStopped()), SLOT(mplayerStopped()));
		connect(gst_player, SIGNAL(gstPlayerPaused()), SLOT(mplayerPaused()));

		connect(gst_player, SIGNAL(playingInfoUpdated(QMap<QString,QString>)),
				SLOT(gstPlayerInfoReceived(QMap<QString,QString>)));
	}

	info_poll_timer = new QTimer(this);
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
	return player_state;
}

MultiMediaPlayer::AudioOutputState MultiMediaPlayer::getAudioOutputState() const
{
	return output_state;
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
	QVariantMap new_info = track_info;

	// if we're paused, and the timer is active, it means it was reactivated by seek(),
	// so we can stop it now
	if (player_state != Playing && info_poll_timer->isActive())
	{
		++seek_tick_count;
		if (seek_tick_count > SEEK_TICK_TIMEOUT)
			info_poll_timer->stop();
	}

	// TODO maybe handle here out-of-band metadata from UPnP
	foreach (QString key, COMMON_ATTRIBUTES)
		if (new_track_info.contains(key))
			new_info[key] = new_track_info[key];

	if (new_track_info.contains("total_time"))
		new_info["total_time"] = parseMPlayerTime(new_track_info["total_time"]);

	if (new_track_info.contains("current_time"))
		new_info["current_time"] = parseMPlayerTime(new_track_info["current_time"]);
	else if (new_track_info.contains("current_time_only"))
		new_info["current_time"] = parseMPlayerTime(new_track_info["current_time_only"]);

	if (new_info == track_info)
		return;

	track_info = new_info;
	emit trackInfoChanged(track_info);
}

void MultiMediaPlayer::gstPlayerInfoReceived(QMap<QString, QString> new_track_info)
{
	QVariantMap new_info = track_info;

	// if we're paused, and the timer is active, it means it was reactivated by seek(),
	// so we can stop it now
	if (player_state != Playing && info_poll_timer->isActive())
	{
		++seek_tick_count;
		if (seek_tick_count > SEEK_TICK_TIMEOUT)
			info_poll_timer->stop();
	}

	// TODO maybe handle here out-of-band metadata from UPnP
	foreach (QString key, COMMON_ATTRIBUTES)
		if (new_track_info.contains(key))
			new_info[key] = new_track_info[key];

	if (new_track_info.contains("total_time"))
		new_info["total_time"] = QTime().addSecs(new_track_info["total_time"].toInt());

	if (new_track_info.contains("current_time"))
		new_info["current_time"] = QTime().addSecs(new_track_info["current_time"].toInt());

	if (new_info == track_info)
		return;

	track_info = new_info;
	emit trackInfoChanged(track_info);
}

void MultiMediaPlayer::play()
{
	if (player_state == Playing)
		return;

	if (current_source.isEmpty())
		return;

	if (is_video_track)
		gst_player->play(current_source);
	else
		player->play(current_source, static_cast<MediaPlayer::OutputMode>(mediaplayer_output_mode));
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
	if (player_state != Paused && player_state != AboutToPause)
		return;

	if (is_video_track)
	{
		gst_player->resume();
	}
	else
	{
		if (player->isInstanceRunning())
			player->resume();
		else
			play();
	}
}

void MultiMediaPlayer::stop()
{
	setCurrentSource("");
}

void MultiMediaPlayer::seek(int seconds)
{
	if (player_state == Stopped)
		return;

	// TODO does not handle the case pause() -> setSource() -> seek()
	player->seek(seconds);
	// restart poll timer so we get the new position
	if (player_state != Playing)
	{
		seek_tick_count = 0;
		info_poll_timer->start();
	}
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
				player->play(source, static_cast<MediaPlayer::OutputMode>(mediaplayer_output_mode));
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

void MultiMediaPlayer::setPlayerState(PlayerState new_state)
{
	if (new_state == player_state)
		return;

	player_state = new_state;
	emit playerStateChanged(player_state);
}

void MultiMediaPlayer::setAudioOutputState(AudioOutputState new_state)
{
	if (new_state == output_state)
		return;

	output_state = new_state;
	emit audioOutputStateChanged(output_state);
}

// handle player signals

void MultiMediaPlayer::playbackStarted()
{
	info_poll_timer->start();
}

void MultiMediaPlayer::playbackStopped()
{
	info_poll_timer->stop();
}

void MultiMediaPlayer::mplayerStarted()
{
	playbackStarted();
	setPlayerState(Playing);
	setAudioOutputState(AudioOutputActive);
}

void MultiMediaPlayer::mplayerStopped()
{
	// this handles the pause() -> change source sequence: MPlayer is stopped,
	// but the "logical" state is still paused
	if (player_state == Paused && !current_source.isEmpty())
		return;

	playbackStopped();
	// for instructions order see comment in mplayerDone
	setCurrentSource("");
	setPlayerState(Stopped);
	setAudioOutputState(AudioOutputStopped);
}

void MultiMediaPlayer::mplayerPaused()
{
	playbackStopped();
	setPlayerState(Paused);
	setAudioOutputState(AudioOutputStopped);
}

void MultiMediaPlayer::mplayerResumed()
{
	playbackStarted();
	setPlayerState(Playing);
	setAudioOutputState(AudioOutputActive);
}

void MultiMediaPlayer::mplayerDone()
{
	playbackStopped();
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
	setAudioOutputState(AudioOutputStopped);
}
