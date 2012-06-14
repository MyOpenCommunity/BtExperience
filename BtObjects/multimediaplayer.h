#ifndef MULTIMEDIAPLAYER_H
#define MULTIMEDIAPLAYER_H

#include <QObject>
#include <QVariant>
#include <QMetaType>

class MediaPlayer;

class QTimer;


class MultiMediaPlayer : public QObject
{
	friend class TestMultiMediaPlayer;

	Q_OBJECT

	Q_PROPERTY(QString currentSource READ getCurrentSource WRITE setCurrentSource NOTIFY currentSourceChanged)
	Q_PROPERTY(QVariantMap trackInfo READ getTrackInfo NOTIFY trackInfoChanged)
	Q_PROPERTY(PlayerState playerState READ getPlayerState NOTIFY playerStateChanged)
	Q_PROPERTY(AudioOutputState audioOutputState READ getAudioOutputState NOTIFY audioOutputStateChanged)

	Q_ENUMS(PlayerState)

public:
	enum PlayerState
	{
		Stopped = 1,
		Paused = 2,
		Playing = 3,
		AboutToPause = 4,
		AboutToResume = 5
	};

	enum AudioOutputState
	{
		AudioOutputActive = 1,
		AudioOutputStopped = 2
	};

	MultiMediaPlayer();

	QString getCurrentSource() const;
	QVariantMap getTrackInfo() const;
	PlayerState getPlayerState() const;
	AudioOutputState getAudioOutputState() const;

public slots:
	void play();
	void pause();
	void resume();
	void stop();
	void seek(int seconds);

	void setCurrentSource(QString current_source);

signals:
	void currentSourceChanged(QString current_source);
	void trackInfoChanged(QVariantMap info);
	void playerStateChanged(MultiMediaPlayer::PlayerState state);
	void audioOutputStateChanged(MultiMediaPlayer::AudioOutputState state);

private slots:
	void readPlayerInfo();
	void playerInfoReceived(QMap<QString, QString> new_track_info);

	void playbackStarted();
	void playbackStopped();

	void mplayerStarted();
	void mplayerStopped();
	void mplayerPaused();
	void mplayerResumed();
	void mplayerDone();

private:
	void setPlayerState(PlayerState new_state);
	void setAudioOutputState(AudioOutputState new_state);

	MediaPlayer *player;
	QTimer *info_poll_timer;

	QString current_source;
	QVariantMap track_info;
	PlayerState player_state;
	AudioOutputState output_state;
};

Q_DECLARE_METATYPE(MultiMediaPlayer::PlayerState)
Q_DECLARE_METATYPE(MultiMediaPlayer::AudioOutputState)

#endif // MULTIMEDIAPLAYER_H
