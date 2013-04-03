#include "audiostate.h"

#include "multimediaplayer.h"
#include "mediaplayer.h" // SoundPlayer
#include "generic_functions.h"
#include "mediaobjects.h"

#include <QStringList>
#include <QMetaEnum>

#include <QtDebug>


#define VDE_ON_DELAY 300


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
		AudioState::InvalidVolume,      //14
		AudioState::RingtoneVolume,     //15
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
		// 1-100 -> 0 -> 88 (0x58)
		QString scaled_volume = QString::number(volume * 88 / 100, 16);
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

	QString scs_source_on          = "/usr/local/bin/HwBsp-D-Audio-SCS_Multimedia.sh";
	QString scs_source_off         = "/usr/local/bin/HwBsp-D-Audio-SCS_Multimedia_off.sh";
	QString vde_audio_on           = "/usr/local/bin/HwBsp-D-Audio-VDE_Conversation_silent.sh";
	QString vde_audio_off          = "/usr/local/bin/HwBsp-D-Audio-VDE_Conversation_off_silent.sh";
	QString intercom_audio_on      = "/usr/local/bin/HwBsp-D-Audio-Intercom_silent.sh";
	QString intercom_audio_off     = "/usr/local/bin/HwBsp-D-Audio-Intercom_off_silent.sh";
	QString pager_mic_on           = "/usr/local/bin/HwBsp-D-Audio-Find-MicToScs_silent.sh";
	QString pager_speaker_on       = "/usr/local/bin/HwBsp-D-Audio-Find-ScsToSpeaker_silent.sh";
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

	vde_on_delay.setSingleShot(true);
	vde_on_delay.setInterval(300);
	connect(&vde_on_delay, SIGNAL(timeout()), this, SLOT(runVdeOn()));

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

bool AudioState::isStateEnabled(State state)
{
	Q_ASSERT_X(state != Invalid, "AudioState::enableState", "Do not use \"Invalid\" state");
	if (state < AudioState::StateCount)
		return states[state];
	return false;
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
		this, SLOT(checkPlayerState(MultiMediaPlayer::PlayerState)));
}

void AudioState::registerSoundPlayer(MultiMediaPlayer *player)
{
	players.append(PlayerInfo(player, SoundEffect));

	// this assumes audioOutputState is changed together with playerState
	connect(player, SIGNAL(audioOutputStateChanged(MultiMediaPlayer::AudioOutputState)),
		this, SLOT(checkDirectAudioAccess()));
	connect(player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		this, SLOT(checkPlayerState(MultiMediaPlayer::PlayerState)));
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

void AudioState::registerSoundAmbient(SoundAmbientBase *ambient)
{
	connect(ambient, SIGNAL(currentSourceChanged()), this, SLOT(checkLocalSoundDiffusion()));
}

void AudioState::checkLocalSoundDiffusion()
{
	// finds all ambients and checks if 1+ are active on local sound diffusion source
	QScopedPointer<ObjectModel> ambientModel(new ObjectModel());
	ambientModel->setFilters(
				ObjectModelFilters() << "objectId" << ObjectInterface::IdMultiChannelSpecialAmbient
				<< ObjectModelFilters() << "objectId" << ObjectInterface::IdMultiChannelSoundAmbient
				<< ObjectModelFilters() << "objectId" << ObjectInterface::IdMonoChannelSoundAmbient
				<< ObjectModelFilters() << "objectId" << ObjectInterface::IdMultiGeneral);
	for (int i = 0; i < ambientModel->getCount(); ++i)
	{
		ItemInterface *item = ambientModel->getObject(i);
		SoundAmbientBase *ambient = qobject_cast<SoundAmbientBase *>(item);
		if (!ambient)
			continue;
		QObject *o = ambient->getCurrentSource();
		if (!o)
			continue;
		SourceObject *s = qobject_cast<SourceObject *>(o);
		if (!s)
			continue;
		SourceObject::SourceObjectType t = s->getSourceType();
		if (t == SourceObject::RdsRadio || t == SourceObject::Aux || t == SourceObject::Touch)
			continue;
		// one local source found, activates local sound diffusion
		smartExecute(scs_source_on);
		return;
	}
	// no local source found, deactivates local sound diffusion
	smartExecute(scs_source_off);
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
		if (new_state != AudioState::Mute)
			smartExecute_synch(vde_audio_off);
		break;
	case ScsIntercomCall:
		if (new_state != AudioState::Mute)
			smartExecute_synch(intercom_audio_off);
		break;
	case SenderPagerCall:
		if (new_state != AudioState::Mute)
			smartExecute_synch(vde_audio_off);
		break;
	case ReceiverPagerCall:
		if (new_state != AudioState::Mute)
			smartExecute_synch(vde_audio_off);
		break;
	case Mute:
		setZlMute(false);
		if (new_state != AudioState::ScsVideoCall && new_state != AudioState::ScsIntercomCall)
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
		if (old_state != AudioState::Mute)
		{
			smartExecute_synch("zl38005_ioctl", QStringList() << "/dev/zl380050" << "WR" << "044D" << "8A0C");
			if (current_volume != InvalidVolume)
		                setHardwareVolume(current_volume, volumes[current_volume]);
			smartExecute_synch(vde_audio_on);
		}
		break;
	case ScsIntercomCall:
		if (old_state != AudioState::Mute)
		{
			smartExecute_synch("zl38005_ioctl", QStringList() << "/dev/zl380050" << "WR" << "044D" << "870C");
			if (current_volume != InvalidVolume)
				setHardwareVolume(current_volume, volumes[current_volume]);
			smartExecute_synch(intercom_audio_on);
		}
		break;
	case SenderPagerCall:
		if (old_state != AudioState::Mute)
		{
			if (current_volume != InvalidVolume)
				setHardwareVolume(current_volume, volumes[current_volume]);
			smartExecute_synch(pager_mic_on);
		}
		break;
	case ReceiverPagerCall:
		if (old_state != AudioState::Mute)
		{
			if (current_volume != InvalidVolume)
				setHardwareVolume(current_volume, volumes[current_volume]);
			smartExecute_synch(pager_speaker_on);
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

	if (current_state > Ringtone)
		pauseSoundDiffusionPlayer();
	resumeActivePlayer();
}

void AudioState::vdeEnable(bool enable)
{
	// this slot enables/disables the vde audio; it is used during camera
	// cycling to avoid to introduce an additional state on audio state machine
	vde_on_delay.stop();
	if (enable)
		vde_on_delay.start();
	else
		smartExecute_synch(vde_audio_off);
}

void AudioState::runVdeOn()
{
	vde_on_delay.stop();
	smartExecute_synch(vde_audio_on);
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

void AudioState::checkPlayerState(MultiMediaPlayer::PlayerState state)
{
	// We need to process the audio state only when the player is really paused
	// Consider this scenario: the player is playing at low volume and the
	// beep state (or ringtone) is at high volume.
	// As soon as we get the AboutToPause state we rise the volume, but the
	// player is not yet stopped, so we hear a "noise" in output (which is just
	// the last bits of the song playing at high volume).
	// See bug #20351
	if (state != MultiMediaPlayer::AboutToPause)
		checkDirectAudioAccess();
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

void AudioState::pauseSoundDiffusionPlayer()
{
	for (int i = 0; i < players.count(); ++i)
	{
		PlayerInfo &info = players[i];

		if (info.player->getAudioOutputState() == MultiMediaPlayer::AudioOutputActive)
		{
			if (info.type == SoundDiffusion)
			{
				qDebug() << "Sound diffusion player entering temporary pause";
				info.temporary_pause = true;
				info.player->pause();
			}
		}
	}
}

void AudioState::resumeActivePlayer()
{
	for (int i = 0; i < players.count(); ++i)
	{
		PlayerInfo &info = players[i];

		if (info.temporary_pause && info.player->getPlayerState() != MultiMediaPlayer::Stopped)
		{
			if (((current_state == LocalPlayback || current_state == LocalPlaybackMute) && info.type == MultiMedia) ||
			    ((current_state <= Ringtone) && info.type == SoundDiffusion))
			{
				qDebug() << (info.type == SoundDiffusion ? "Sound diffusion player" : "Player") << "leaving temporary pause";

				info.temporary_pause = false;
				info.player->resume();
			}
		}
	}
}
