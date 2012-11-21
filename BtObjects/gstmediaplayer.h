#ifndef GSTMEDIAPLAYER_H
#define GSTMEDIAPLAYER_H

#include <QObject>
#include <QMap>
#include <QProcess>


class GstMediaPlayerImplementation : public QObject
{
	Q_OBJECT
public:
	GstMediaPlayerImplementation(QObject *parent = 0) : QObject(parent) { }

	virtual bool play(QString track) { Q_UNUSED(track); return false; }

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
	virtual QMap<QString, QString> getPlayingInfo() { return QMap<QString, QString>(); }

	virtual void setTrack(QString track) { Q_UNUSED(track) }

public slots:
	virtual void pause() { }
	virtual void resume() { }
	virtual void stop() { }

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
};

class GstExternalMediaPlayer : public GstMediaPlayerImplementation
{
	Q_OBJECT

public:
	GstExternalMediaPlayer(QObject *parent = 0);

	virtual bool play(QString track);

	virtual void stop();

private slots:
	void mplayerFinished(int exit_code, QProcess::ExitStatus exit_status);
	void mplayerError(QProcess::ProcessError error);

private:
	void quit();
	bool runMPlayer(const QList<QString> &args);

	QProcess *gstreamer_proc;
	bool paused, really_paused;
};

#endif // GSTMEDIAPLAYER_H
