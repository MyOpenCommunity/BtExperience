#include "multimediaplayer.h"
#include "mediaplayer.h"

#include <QTime>
#include <QTimer>

#define INFO_POLL_INTERVAL 500


MultiMediaPlayer::MultiMediaPlayer()
{
	player = new MediaPlayer(this);
	player_state = Stopped;
	output_state = AudioOutputStopped;

	connect(player, SIGNAL(mplayerStarted()), SLOT(mplayerStarted()));
	connect(player, SIGNAL(mplayerResumed()), SLOT(mplayerResumed()));
	connect(player, SIGNAL(mplayerDone()), SLOT(mplayerDone()));
	connect(player, SIGNAL(mplayerStopped()), SLOT(mplayerStopped()));
	connect(player, SIGNAL(mplayerPaused()), SLOT(mplayerPaused()));

	info_poll_timer = new QTimer(this);
	info_poll_timer->setInterval(INFO_POLL_INTERVAL);
	connect(info_poll_timer, SIGNAL(timeout()), this, SLOT(readPlayerInfo()));

	qRegisterMetaType<MultiMediaPlayer::PlayerState>();
	qRegisterMetaType<MultiMediaPlayer::AudioOutputState>();
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

void MultiMediaPlayer::readPlayerInfo()
{
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

void MultiMediaPlayer::play()
{
	player->play(current_source);
}

void MultiMediaPlayer::pause()
{
	// TODO only when playing
	setPlayerState(AboutToPause);

	player->pause();
}

void MultiMediaPlayer::resume()
{
	// TODO only when paused
	if (player->isInstanceRunning())
		player->resume();
	else
		play();
}

void MultiMediaPlayer::stop()
{
	player->stop();
}

void MultiMediaPlayer::seek(int seconds)
{
	// TODO only when playing/paused
	player->seek(seconds);
}

void MultiMediaPlayer::setCurrentSource(QString source)
{
	if (source == current_source)
		return;

	current_source = source;
	track_info.clear();

	// if playing, start playing new track right now (which automatically gets
	// track info), otherwise request track info separately
	if (player->isPlaying())
	{
		player->play(current_source);
	}
	else if (player->isPaused())
	{
		// TODO maybe request after some time, in case we start playing
		player->requestInitialPlayingInfo(current_source);
	}

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
	playbackStopped();
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
	setPlayerState(Stopped);
	setAudioOutputState(AudioOutputStopped);
}
