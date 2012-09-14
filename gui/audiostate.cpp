#include "audiostate.h"

#include "multimediaplayer.h"

#include <QtDebug>


namespace
{
	const char *descriptions[AudioState::StateCount + 1] =
	{
		"Invalid",
		"Idle",
		"Beep",
		"Screensaver",
		"LocalPlayback",
		"Ringtone",
		"VdeRingtone",
		"ScsVideoCall",
		"IpVideoCall",
		"ScsIntercomCall",
		"IpIntercomCall",
		"Mute",
		"FloorCall",
	};
}


AudioState::AudioState(QObject *parent) :
	QObject(parent)
{
	for (int i = 0; i < StateCount; ++i)
		states[i] = false;

	current_state = pending_state = Invalid;
	direct_audio_access = direct_video_access = sound_diffusion = false;

	connect(this, SIGNAL(directAudioAccessChanged(bool)),
		this, SLOT(completeTransition(bool)));
}

void AudioState::disableState(State state)
{
	states[state] = false;

	if (state == current_state)
		updateState();
}

void AudioState::enableState(State state)
{
	states[state] = true;

	if (state > current_state)
		updateState();
}

void AudioState::updateState()
{
	State new_state = Idle;
	int i;

	for (i = StateCount - 1; i >= 0; --i)
	{
		if (states[i])
		{
			new_state = static_cast<State>(i);
			break;
		}
	}

	Q_ASSERT_X(i >= 0, "AudioState::updateState", "Idle state not set in audio state machine");

	if (new_state == pending_state || new_state == current_state)
		return;

	emit stateAboutToChange(current_state, new_state);

	if (isDirectAudioAccess())
	{
		pending_state = new_state;

		if (pauseActivePlayer())
			updateAudioPaths(current_state, new_state);
	}
	else
		updateAudioPaths(current_state, new_state);
}

AudioState::State AudioState::getState() const
{
	return current_state;
}

void AudioState::setVolume(int volume)
{
	// TODO
}

int AudioState::getVolume() const
{
	// TODO
}

void AudioState::registerMediaPlayer(MultiMediaPlayer *player)
{
	players.append(PlayerInfo(player, MultiMedia));

	connect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		this, SLOT(checkDirectAudioAccess()));
}

void AudioState::registerSoundPlayer(MultiMediaPlayer *player)
{
	players.append(PlayerInfo(player, SoundEffect));

	connect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		this, SLOT(checkDirectAudioAccess()));
}

void AudioState::registerSoundDiffusionPlayer(MultiMediaPlayer *player)
{
	players.append(PlayerInfo(player, SoundDiffusion));

	connect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		this, SLOT(changeSoundDiffusionAccess()));
}

bool AudioState::isDirectAudioAccess() const
{
	return direct_audio_access;
}

bool AudioState::isDirectVideoAccess() const
{
	return direct_video_access;
}

void AudioState::updateAudioPaths(State old_state, State new_state)
{
	pending_state = Invalid;

	qDebug() << "Leaving state" << descriptions[old_state + 1];

	switch (old_state)
	{
	default:
		qWarning("Add code to leave old state");
		break;
	case Invalid:
		// nothing to do
		break;
	}

	qDebug() << "Entering state" << descriptions[new_state + 1];

	switch (new_state)
	{
	default:
		qWarning("Add code to enter new state");
		break;
	case Invalid:
		Q_ASSERT_X(false, "AudioState::updateAudioPaths", "Entering invalid audio state");
		break;
	}

	current_state = new_state;
	emit stateChanged(old_state, new_state);

	if (new_state == LocalPlayback)
		resumeActivePlayer();
}

void AudioState::completeTransition(bool state)
{
	if (pending_state == Invalid)
		return;

	Q_ASSERT_X(!state, "AudioState::completeTransition", "Inconsistent state during transition");

	updateAudioPaths(current_state, pending_state);
}

void AudioState::checkDirectAudioAccess()
{
	bool new_state = false, is_playback = false;

	foreach (PlayerInfo info, players)
	{
		if (info.type == SoundDiffusion)
			continue;

		if (info.player->getPlayerState() == MultiMediaPlayer::Playing)
		{
			if (info.type == MultiMedia)
				is_playback = true;
			new_state = true;
		}
		else if (info.player->getPlayerState() != MultiMediaPlayer::Stopped && info.temporary_pause)
		{
			is_playback = true;
		}
	}

	if (is_playback)
		enableState(LocalPlayback);

	if (new_state != direct_audio_access)
	{
		direct_audio_access = new_state;
		emit directAudioAccessChanged(direct_audio_access);
	}

	if (!is_playback)
		disableState(LocalPlayback);
}

void AudioState::changeSoundDiffusionAccess()
{
	bool new_sound_diffusion = false;

	for (int i = 0; i < players.count(); ++i)
	{
		PlayerInfo &info = players[i];

		if (info.type == SoundDiffusion && info.player->getPlayerState() == MultiMediaPlayer::Playing)
			new_sound_diffusion = true;
	}

	if (new_sound_diffusion == sound_diffusion)
		return;

	if (new_sound_diffusion)
		qWarning("Add code to enable sound diffusion");
	else
		qWarning("Add code to disable sound diffusion");
}

bool AudioState::pauseActivePlayer()
{
	for (int i = 0; i < players.count(); ++i)
	{
		PlayerInfo &info = players[i];

		if (info.player->getAudioOutputState() == MultiMediaPlayer::AudioOutputActive)
		{
			if (info.type == SoundDiffusion)
				continue;

			if (info.type == SoundEffect)
			{
				qDebug() << "Stopping sound player";

				info.player->stop();
			}
			else
			{
				if (pending_state == LocalPlayback)
					return true;

				qDebug() << "Media player entering temporary pause";

				info.temporary_pause = true;
				info.player->pause();
			}

			break;
		}
	}

	return false;
}

void AudioState::resumeActivePlayer()
{
	for (int i = 0; i < players.count(); ++i)
	{
		PlayerInfo &info = players[i];

		if (info.temporary_pause && info.player->getPlayerState() != MultiMediaPlayer::Stopped)
		{
			qDebug() << "Player leaving temporary pause";

			info.temporary_pause = false;
			info.player->resume();
		}
	}
}
