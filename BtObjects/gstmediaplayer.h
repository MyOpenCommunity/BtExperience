/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef GSTMEDIAPLAYER_H
#define GSTMEDIAPLAYER_H

#include <QObject>
#include <QMap>
#include <QProcess>
#include <QRect>


class GstMediaPlayer : public QObject
{
	Q_OBJECT

public:
	GstMediaPlayer(QObject *parent = 0);

	bool play(QRect rect, QString track);

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

	void setPlayerRect(QRect rect);

	bool isInstanceRunning();

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

	/*!
		\brief Emitted when there is new player output to parse
	*/
	void outputAvailable();

private slots:
	void mplayerFinished(int exit_code, QProcess::ExitStatus exit_status);
	void mplayerError(QProcess::ProcessError error);

private:
	void quit();
	bool runMPlayer(const QList<QString> &args);
	void execCmd(QString command);

	QProcess *gstreamer_proc;
	QRect video_rect;
	bool paused, really_paused;
};

#endif // GSTMEDIAPLAYER_H
