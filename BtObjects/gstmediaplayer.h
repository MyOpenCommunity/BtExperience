#ifndef GSTMEDIAPLAYER_H
#define GSTMEDIAPLAYER_H

#include <QObject>
#include <QMap>

class GstMediaPlayerPrivate;


class GstMediaPlayer : public QObject
{
	Q_OBJECT
public:
	GstMediaPlayer(QObject *parent = 0);

	bool play(QString track);

	/*!
		\brief Return information about the playing audio track

		Available tags for all tracks:
		- current_time: (MM:SS)

		Available tags for audio files:
		- file_name: the file name
		- meta_title: track title, as written in ID3 tags
		- meta_artist: track author/performer, as written in ID3 tags
		- meta_album: track album, as written in ID3 tags
		- total_time: total track time, either from ID3 tags or guessed by the player
	 */
	QMap<QString, QString> getPlayingInfo();

	void setTrack(QString track);

public slots:
	void pause();
	void resume();
	void stop();

signals:
	/*!
		\brief Emitted before starting playback of a media file.
	 */
	void gstPlayerStarted();

	/*!
		\brief Emitted after media playback pauses.
	 */
	void gstPlayerPaused();

	/*!
		\brief Emitted before media playback resumes after a pause.
	 */
	void gstPlayerResumed();

	/*!
		\brief Playback completed successfully.
	 */
	void gstPlayerDone();

	/*!
		\brief Playback stopped by explicit request (GUI or other process) or by an error.
	 */
	void gstPlayerStopped();

	/*!
		\brief Information for a video file.

		Emitted when new information about the media is available; works reliably
		both in playing and paused state.
		\a info contains the same data returned by getPlayingInfo().
	 */
	void playingInfoUpdated(const QMap<QString,QString> &info);

private:
	GstMediaPlayerPrivate *impl;
};


class GstMediaPlayerInterface
{
public:
	virtual QObject *createPlayer(QObject *parent = 0) = 0;
};

Q_DECLARE_INTERFACE(GstMediaPlayerInterface, "it.bticino.GstMediaPlayerPluginInterface/1.0")

#endif // GSTMEDIAPLAYER_H
