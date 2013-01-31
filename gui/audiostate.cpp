#include "audiostate.h"

#include "multimediaplayer.h"
#include "mediaplayer.h" // SoundPlayer
#include "generic_functions.h"

#include <QStringList>
#include <QMetaEnum>

#include <QtDebug>


namespace
{
	AudioState::Volume volume_map[AudioState::StateCount + 1] =
	{
		AudioState::InvalidVolume,      //-1
		AudioState::InvalidVolume,      //0
		AudioState::BeepVolume,         //1
		AudioState::InvalidVolume,      //2
		AudioState::LocalPlaybackVolume,//3
		AudioState::InvalidVolume,      //4
		AudioState::RingtoneVolume,     //5
		AudioState::RingtoneVolume,     //6
		AudioState::VdeCallVolume,      //7
		AudioState::VdeCallVolume,      //8
		AudioState::IntercomCallVolume, //9
		AudioState::IntercomCallVolume, //10
		AudioState::VdeCallVolume,      //11
		AudioState::VdeCallVolume,      //12
		AudioState::InvalidVolume,      //13
		AudioState::RingtoneVolume,     //14
	};

	void setTpaVolume(int volume)
	{
		QString scaled_volume = QString::number(volume * 30 / 100);

		//smartExecute("amixer", QStringList() << "-c" << "0" << "sset" << "TPA2016D2 Gain" << scaled_volume);
	}

	void setHpDacVolume(int volume)
	{
		// 0 -> 0 (mute)
		// 1 -> 20
		// 2-100 -> 21-118
		QString scaled_volume = QString::number(volume == 0 ? 0 :
							volume == 1 ? 20 :
								      (volume - 2) * 97 / 98 + 21);
		smartExecute_synch("amixer", QStringList() << "cset" << "name='HP DAC Playback Volume'" << scaled_volume + "," + scaled_volume);
	}

	void setZlVolume(int volume)
	{
		// 0 -> mute (not used in this function)
		// 1-100 -> 0 -> 80 (0x50)
		QString scaled_volume = QString::number(volume * 80 / 100, 16);
		scaled_volume = QString("%1").arg(scaled_volume, 4, '0');
		smartExecute_synch("zl38005_ioctl", QStringList() << "/dev/zl380051" << "WR" << "046B" << scaled_volume);
	}

	void setZlMute(bool mute)
	{
		if (mute)
			smartExecute_synch("zl38005_ioctl", QStringList() << "/dev/zl380051" << "WR" << "044a" << "6104");
		else
			smartExecute_synch("zl38005_ioctl", QStringList() << "/dev/zl380051" << "WR" << "044a" << "6004");
	}

	void setHardwareVolume(AudioState::Volume state, int volume)
	{
		switch (state)
		{
		case AudioState::BeepVolume:
		case AudioState::LocalPlaybackVolume:
		case AudioState::RingtoneVolume:
			setHpDacVolume(volume);
			break;
		case AudioState::Mute:
			break;
		case AudioState::VdeCallVolume:
		case AudioState::IntercomCallVolume:
			setZlVolume(volume);
			break;
		default:
			setTpaVolume(volume);
			break;
		}
	}

	QString enumerationName(const QObject *obj, const char *enumeration, int value)
	{
		int idx = obj->metaObject()->indexOfEnumerator(enumeration);
		QMetaEnum e = obj->metaObject()->enumerator(idx);

		return e.valueToKey(value);
	}

	QString scs_source_on     = "/usr/local/bin/HwBsp-D-Audio-SCS_Multimedia.sh";
	QString vde_audio_on      = "/usr/local/bin/HwBsp-D-Audio-VDE_Conversation_silent.sh";
	QString vde_audio_off     = "/usr/local/bin/HwBsp-D-Audio-VDE_Conversation_off_silent.sh";
}

#define VOLUME_MIN 0
#define VOLUME_MAX 100
#define VOLUME_DEFAULT 70


AudioState::AudioState(QObject *parent) :
	QObject(parent)
{
	for (int i = 0; i < StateCount; ++i)
		states[i] = false;
	for (int i = 0; i < VolumeCount; ++i)
		volumes[i] = VOLUME_DEFAULT;

	current_state = pending_state = Invalid;
	current_volume = InvalidVolume;
	direct_audio_access = direct_video_access = sound_diffusion = false;

	connect(this, SIGNAL(directAudioAccessChanged(bool)),
		this, SLOT(completeTransition(bool)));
}

void AudioState::disableState(State state)
{
	Q_ASSERT_X(state != Invalid, "AudioState::enableState", "Do not use \"Invalid\" state");
	states[state] = false;

	if (state == current_state)
		updateState();
}

void AudioState::enableState(State state)
{
	Q_ASSERT_X(state != Invalid, "AudioState::enableState", "Do not use \"Invalid\" state");
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
	{
		updateAudioPaths(current_state, new_state);
		// called after updateAudioPaths() to avoid player state change triggering another update
		releasePausedPlayer();
	}
}

AudioState::State AudioState::getState() const
{
	return current_state;
}

bool AudioState::isLocalSource() const
{
	return !(*bt_global::config)[SOURCE_ADDRESS].isEmpty();
}

bool AudioState::isLocalAmplifier() const
{
	return !(*bt_global::config)[AMPLIFIER_ADDRESS].isEmpty();
}

void AudioState::setVolume(Volume state, int volume)
{
	Q_ASSERT_X(state != InvalidVolume, "AudioState::setVolume", "invalid volume");
	Q_ASSERT_X(volume >= VOLUME_MIN && volume <= VOLUME_MAX, "AudioState::setVolume",
		qPrintable(QString("Volume value %1 out of range for volume %2!").arg(volume).arg(state)));

	if (volumes[state] == volume)
		return;

	volumes[state] = volume;
	emit volumeChanged(state, volume);
	if (state == current_volume)
		setHardwareVolume(current_volume, volume);
}

int AudioState::getVolume(Volume state) const
{
	Q_ASSERT_X(state != InvalidVolume, "AudioState::setVolume", "invalid volume");

	return volumes[state];
}

void AudioState::registerMediaPlayer(MultiMediaPlayer *player)
{
	players.append(PlayerInfo(player, MultiMedia));

	// this assumes audioOutputState is changed together with playerState
	connect(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)),
		this, SLOT(checkDirectAudioAccess()));
	connect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		this, SLOT(checkDirectAudioAccess()));
}

void AudioState::registerSoundPlayer(MultiMediaPlayer *player)
{
	players.append(PlayerInfo(player, SoundEffect));

	// this assumes audioOutputState is changed together with playerState
	connect(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)),
		this, SLOT(checkDirectAudioAccess()));
	connect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		this, SLOT(checkDirectAudioAccess()));
}

void AudioState::registerBeep(SoundPlayer *player)
{
	beep = player;

	connect(beep, SIGNAL(soundStarted()),
		this, SLOT(checkDirectAudioAccess()));
	connect(beep, SIGNAL(soundFinished()),
		this, SLOT(checkDirectAudioAccess()));
}

void AudioState::registerSoundDiffusionPlayer(MultiMediaPlayer *player)
{
	players.append(PlayerInfo(player, SoundDiffusion));

	// this assumes audiioOutputState is changed after playerState
	connect(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)),
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

	qDebug() << "Leaving audio state" << enumerationName(this, "State", old_state);

	switch (old_state)
	{
	case Beep:
	case LocalPlayback:
	case LocalPlaybackMute:
	case Ringtone:
		break;
	case ScsVideoCall:
	case ScsIntercomCall:
		if(new_state != AudioState::Mute)
			smartExecute_synch(vde_audio_off);
		break;
	case Mute:
		setZlMute(false);
		if(new_state != AudioState::ScsVideoCall && new_state != AudioState::ScsIntercomCall)
			smartExecute_synch(vde_audio_off);
		break;
	default:
		qWarning("Add code to leave old state");
		break;
	case Invalid:
		// nothing to do
		break;
	}

	qDebug() << "Entering audio state" << enumerationName(this, "State", new_state);

	current_volume = volume_map[new_state + 1];

	switch (new_state)
	{
	case Beep:
	case LocalPlayback:
	case Ringtone:
	case VdeRingtone:
	case FloorCall:
		if (current_volume != InvalidVolume)
			setHardwareVolume(current_volume, volumes[current_volume]);
		break;
	case ScsVideoCall:
		if(old_state != AudioState::Mute)
		{
			smartExecute_synch("zl38005_ioctl", QStringList() << "/dev/zl380050" << "WR" << "044D" << "8A0C");
			if (current_volume != InvalidVolume)
		                setHardwareVolume(current_volume, volumes[current_volume]);
			smartExecute_synch(vde_audio_on);
		}
		break;
	case ScsIntercomCall:
		if(old_state != AudioState::Mute)
		{
			smartExecute_synch("zl38005_ioctl", QStringList() << "/dev/zl380050" << "WR" << "044D" << "870C");
			if (current_volume != InvalidVolume)
				setHardwareVolume(current_volume, volumes[current_volume]);
			smartExecute_synch(vde_audio_on);
		}
		break;
	case LocalPlaybackMute:
		setHardwareVolume(LocalPlaybackVolume, 0);
		break;
	case Mute:
		setZlMute(true);
		break;
	default:
		qWarning("Add code to enter new state");
		break;
	case Invalid:
		Q_ASSERT_X(false, "AudioState::updateAudioPaths", "Entering invalid audio state");
		break;
	}

	current_state = new_state;

	emit stateChanged(old_state, new_state);

	if (new_state == LocalPlayback || new_state == LocalPlaybackMute)
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
	bool new_state = false, is_playback = false, is_mute = false;

	foreach (PlayerInfo info, players)
	{
		if (info.type == SoundDiffusion)
			continue;

		if (info.player->getPlayerState() == MultiMediaPlayer::Playing)
		{
			if (info.type == MultiMedia)
			{
				is_playback = true;
				is_mute = info.player->getMute();
			}
			new_state = true;
		}
		else if (info.player->getPlayerState() != MultiMediaPlayer::Stopped && info.temporary_pause)
		{
			is_playback = true;
			is_mute = info.player->getMute();
		}
	}

	if (beep->isActive())
		new_state = true;

	if (is_mute)
		enableState(LocalPlaybackMute);
	if (is_playback)
		enableState(LocalPlayback);

	if (new_state != direct_audio_access)
	{
		direct_audio_access = new_state;
		emit directAudioAccessChanged(direct_audio_access);
	}

	if (!is_playback)
		disableState(LocalPlayback);
	if (!is_mute)
		disableState(LocalPlaybackMute);
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
		smartExecute(scs_source_on);
	else
		qWarning("Add code to disable sound diffusion");

	sound_diffusion = new_sound_diffusion;
}

void AudioState::releasePausedPlayer()
{
	for (int i = 0; i < players.count(); ++i)
	{
		PlayerInfo &info = players[i];

		if (info.player->getAudioOutputState() == MultiMediaPlayer::AudioOutputActive &&
		    (info.player->getPlayerState() == MultiMediaPlayer::Paused ||
		     info.player->getPlayerState() == MultiMediaPlayer::AboutToPause))
		{
			if (info.type == MultiMedia)
			{
				if (pending_state == LocalPlayback || pending_state == LocalPlaybackMute)
					return;

				if (pending_state != Idle && pending_state != Screensaver)
				{
					qDebug() << "Releasing paused media player output device";
					info.player->releaseOutputDevices();
				}
			}
		}
	}
}

bool AudioState::pauseActivePlayer()
{
	releasePausedPlayer();

	// equal to SoundEffect below
	beep->stop();

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
				if (pending_state == LocalPlayback || pending_state == LocalPlaybackMute)
					return true;

				if (info.player->getPlayerState() != MultiMediaPlayer::Paused)
				{
					qDebug() << "Media player entering temporary pause";
					info.temporary_pause = true;
					info.player->pause();
				}

				if (pending_state != Idle && pending_state != Screensaver)
				{
					qDebug() << "Releasing media player device";
					info.player->releaseOutputDevices();
				}
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
