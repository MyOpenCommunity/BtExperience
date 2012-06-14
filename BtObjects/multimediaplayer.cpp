#include "multimediaplayer.h"
#include "mediaplayer.h"

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
	qRegisterMetaType<MultiMediaPlayer::TrackInfo>();
}

QString MultiMediaPlayer::getCurrentSource() const
{
	return current_source;
}

MultiMediaPlayer::TrackInfo MultiMediaPlayer::getTrackInfo() const
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

void MultiMediaPlayer::playerInfoReceived(QMap<QString, QString> new_track_info)
{
	if (new_track_info == track_info)
		return;

	track_info = new_track_info;
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
	setPlayerState(AboutToResume);

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
