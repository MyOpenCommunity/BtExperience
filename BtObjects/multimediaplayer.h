#ifndef MULTIMEDIAPLAYER_H
#define MULTIMEDIAPLAYER_H

/*!
	\defgroup Multimedia Multimedia
*/

#include <QObject>
#include <QVariant>
#include <QMetaType>

class MediaPlayer;

class QTimer;


/*!
	\ingroup Multimedia
	\brief Plays audio and video files

	Note that communication with the media player is asynchronous, so status changes
	only happen some time after tha status-changing method is called.

	Typical usage is:
	- set \ref currentSource to the first source path/URL
	- call \ref play() to start playback
	- use \ref pause(), \ref resume() and \ref stop() to control playback
	- during playback, set \ref currentSource to move to the previous/next track
*/
class MultiMediaPlayer : public QObject
{
	friend class TestMultiMediaPlayer;

	Q_OBJECT

	/*!
		\brief Current source for the audio/video data (typically a file name or URL)
	*/
	Q_PROPERTY(QString currentSource READ getCurrentSource WRITE setCurrentSource NOTIFY currentSourceChanged)

	/*!
		\brief Metadata aboot current track

		- total_time (QTime): total time of the track
		- current_time (QTime): current time of the track

		For files:

		- meta_title (string): song title
		- file_name (string): file name (does not include the path)
		- meta_artist (string): artist
		- meta_album (string) album

		For network streams:

		- stream_url (string): source URL of the stream (may be different from \ref currentSource)
		- stream_title (string): description of the stream
	*/
	Q_PROPERTY(QVariantMap trackInfo READ getTrackInfo NOTIFY trackInfoChanged)

	/*!
		\brief Playback status
	*/
	Q_PROPERTY(PlayerState playerState READ getPlayerState NOTIFY playerStateChanged)

	/*!
		\brief Whether the player is currently using audio output
	*/
	Q_PROPERTY(AudioOutputState audioOutputState READ getAudioOutputState NOTIFY audioOutputStateChanged)

	Q_ENUMS(PlayerState AudioOutputState)

public:
	/// Player status
	enum PlayerState
	{
		/// Player is stopped
		Stopped = 1,
		/// Player is paused
		Paused = 2,
		/// Player is reproducing audio
		Playing = 3,
		/// Player will go in pause mode as soon as possible
		AboutToPause = 4
	};

	/// Whether player is using audio output
	enum AudioOutputState
	{
		/// Player is using audio output
		AudioOutputActive = 1,
		/// Player is not using audio output
		AudioOutputStopped = 2
	};

	MultiMediaPlayer();

	QString getCurrentSource() const;
	QVariantMap getTrackInfo() const;
	PlayerState getPlayerState() const;
	AudioOutputState getAudioOutputState() const;

public slots:
	/*!
		\brief Start reporducing current source
	*/
	void play();

	/*!
		\brief Pause playback
	*/
	void pause();

	/*!
		\brief Resume playback after a pause
	*/
	void resume();

	/*!
		\brief Stop current playback
	*/
	void stop();

	/*!
		\brief Seek forward/backward

		Moves the playback backward/forward by the given offset.  Due to
		limitations of various audio/video formats, the actual seek time will
		rarely equal the offset.
	*/
	void seek(int seconds);

	/*!
		\brief Change the current audio/video source

		This does not affect player status, so if the player is stopped,
		playback does not start until \ref play() is called.
	*/
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
	int seek_tick_count;
	int mediaplayer_output_mode;
};

Q_DECLARE_METATYPE(MultiMediaPlayer::PlayerState)
Q_DECLARE_METATYPE(MultiMediaPlayer::AudioOutputState)

#endif // MULTIMEDIAPLAYER_H
