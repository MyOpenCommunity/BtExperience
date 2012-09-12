#ifndef AUDIOSTATE_H
#define AUDIOSTATE_H

#include <QObject>
#include <QList>

class MultiMediaPlayer;


class AudioState : public QObject
{
	Q_OBJECT
	Q_PROPERTY(State state READ getState NOTIFY stateChanged)
	Q_PROPERTY(bool audioAccess READ isDirectAudioAccess NOTIFY directAudioAccessChanged)
	Q_PROPERTY(bool videoAccess READ isDirectVideoAccess NOTIFY directVideoAccessChanged)

	Q_ENUMS(State)

public:
	enum State
	{
		Invalid = -1,
		Idle,
		Beep,
		Screensaver,
		LocalPlayback,
		Ringtone,
		// this must be last
		StateCount
	};

	AudioState(QObject *parent);

	Q_INVOKABLE void disableState(State state);
	Q_INVOKABLE void enableState(State state);

	State getState() const;

	Q_INVOKABLE void setVolume(int volume);
	Q_INVOKABLE int getVolume() const;

	void registerMediaPlayer(MultiMediaPlayer *player);
	void registerSoundPlayer(MultiMediaPlayer *player);
	void registerSoundDiffusionPlayer(MultiMediaPlayer *player);

	bool isDirectAudioAccess() const;
	bool isDirectVideoAccess() const;

signals:
	void stateChanged(AudioState::State old_state, AudioState::State new_state);

	void stateAboutToChange(AudioState::State old_state, AudioState::State new_state);

	void directAudioAccessChanged(bool value);

	void directVideoAccessChanged(bool value);

private slots:
	void completeTransition(bool state);
	void checkDirectAudioAccess();
	void changeSoundDiffusionAccess();

private:
	enum PlayerType
	{
		MultiMedia,
		SoundEffect,
		SoundDiffusion
	};

	struct PlayerInfo
	{
		explicit PlayerInfo(MultiMediaPlayer *_player, PlayerType _type)
		{
			player = _player;
			temporary_pause = false;
			type = _type;
		}

		MultiMediaPlayer *player;
		bool temporary_pause;
		PlayerType type;
	};

	bool pauseActivePlayer();
	void resumeActivePlayer();

	void updateState();
	void updateAudioPaths(State old_state, State new_state);

	State current_state, pending_state;
	bool direct_audio_access, direct_video_access;
	bool states[StateCount];
	bool sound_diffusion;
	QList<PlayerInfo> players;
};

#endif // AUDIOSTATE_H

