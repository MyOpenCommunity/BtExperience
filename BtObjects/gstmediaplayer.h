#ifndef GSTMEDIAPLAYER_H
#define GSTMEDIAPLAYER_H

#include <gst/gst.h>

#include <QObject>
#include <QMap>

// Anonymous namespaces are useless with extern "C" linkage, see:
// https://groups.google.com/d/msg/comp.lang.c++.moderated/bRso4RIDiBI/F2BscJar_qMJ
extern "C" gboolean gstMediaPlayerBusCallback(GstBus *bus, GstMessage *message, gpointer data);

class GstMediaPlayer : public QObject
{
friend gboolean gstMediaPlayerBusCallback(GstBus *bus, GstMessage *message, gpointer data);
	Q_OBJECT
public:
	GstMediaPlayer(QObject *parent = 0);

	virtual ~GstMediaPlayer();

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

public slots:
	void pause();
	void resume();

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
		\brief Information for a video/audio file.

		Emitted by requestInitialVideoInfo() and requestInitialPlayingInfo().
		\a info contains the same data returned by getPlayingInfo() and getVideoInfo().
	 */
	void playingInfoUpdated(const QMap<QString,QString> &info);

private:
	void handleBusMessage(GstBus *bus, GstMessage *message);
	void handleTagMessage(GstMessage *message);
	GstPipeline *pipeline;
	QMap<QString, QString> metadata;
};

#endif // GSTMEDIAPLAYER_H
