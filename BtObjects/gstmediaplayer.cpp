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

#include "gstmediaplayer.h"

#include <QCoreApplication>
#include <QMetaEnum>
#include <QtDebug>

namespace
{
	QMap<QString, QString> parsePlayerOutput(QString data)
	{
		QMap<QString, QString> result;

		foreach (QString line, data.split('\n'))
		{
			int colon = line.indexOf(':');
			if (colon == -1)
				continue;

			QString key = line.mid(0, colon);
			QString value = line.mid(colon + 2);

			result[key] = value;
		}

		return result;
	}
}

/*
  Player output lines are key-value pairs, for example:

    current_time: 0
    meta_album: Laundry Service
    meta_artist: Shakira
    meta_title: Underneath your clothes
    total_time: 227
    current_time: 1
    current_time: 2
    ...

   The metadata keys can be: meta_title, meta_artist, meta_album, current_time (seconds), total_time (seconds)

   Commands are terminaed by a newline:

   - resize <x> <y> <width> <height>

   Display the video inside the specified rectangle, preserving aspect ratio.

   - pause

   - resume

   - set_track <url>

   Stop current playback and load the specified URL
*/

GstMediaPlayer::GstMediaPlayer(QObject *parent) : QObject(parent)
{
	gstreamer_proc = new QProcess();
	paused = false;

	connect(gstreamer_proc, SIGNAL(readyReadStandardOutput()), SIGNAL(outputAvailable()));
	// connect(gstreamer_proc, SIGNAL(readyReadStandardError()), SLOT(readStandardError()));
	connect(gstreamer_proc, SIGNAL(finished(int, QProcess::ExitStatus)), SLOT(mplayerFinished(int, QProcess::ExitStatus)));
	connect(gstreamer_proc, SIGNAL(error(QProcess::ProcessError)), SLOT(mplayerError(QProcess::ProcessError)));
}

bool GstMediaPlayer::isInstanceRunning()
{
	return gstreamer_proc->state() != QProcess::NotRunning;
}

bool GstMediaPlayer::play(QRect rect, QString track)
{
	video_rect = rect;

	return runMPlayer(QList<QString>()
			  << QString("--rect=%1,%2,%3,%4").arg(rect.x()).arg(rect.y()).arg(rect.width()).arg(rect.height())
			  << track);
}

void GstMediaPlayer::setPlayerRect(QRect rect)
{
	video_rect = rect;
	execCmd(QString("resize %1 %2 %3 %4").arg(rect.x()).arg(rect.y()).arg(rect.width()).arg(rect.height()));
}

bool GstMediaPlayer::runMPlayer(const QList<QString> &args)
{
	if (gstreamer_proc->state() != QProcess::NotRunning)
	{
		gstreamer_proc->terminate();
		gstreamer_proc->waitForFinished();
	}

	QString global_player_executable = qApp->applicationDirPath() + "/gstmediaplayer";

	qDebug() << "About to start gstreamer exec (" << global_player_executable << ") with args: " << args;
	gstreamer_proc->start(global_player_executable, args);
	paused = really_paused = false;

	bool started = gstreamer_proc->waitForStarted(300);
	if (started)
		emit gstPlayerStarted();

	return started;
}

void GstMediaPlayer::quit()
{
	if (gstreamer_proc->state() == QProcess::Running)
	{
		gstreamer_proc->terminate();
		qDebug("GstMediaPlayer::quit() waiting for gstreamer to quit...");
		if (!gstreamer_proc->waitForFinished(300))
			qWarning() << "Couldn't terminate gstreamer";
	}
}

void GstMediaPlayer::pause()
{
	paused = true;
	execCmd("pause");
}

void GstMediaPlayer::resume()
{
	paused = really_paused = false;
	execCmd("resume");
	emit gstPlayerResumed();
}

void GstMediaPlayer::stop()
{
	// simulate player termination when the player is logically paused
	paused = false;
	quit();
}

void GstMediaPlayer::setTrack(QString track)
{
	if (gstreamer_proc->state() == QProcess::Running)
		execCmd("set_track " + track);
	else
		play(video_rect, track);
}

QMap<QString, QString> GstMediaPlayer::getPlayingInfo()
{
	QString raw_data = gstreamer_proc->readAll();
	QMap<QString, QString> info_data = parsePlayerOutput(raw_data);

	if (info_data.value("state") == "paused" && paused)
	{
		really_paused = true;
		emit gstPlayerPaused();
	}

	return info_data;
}

void GstMediaPlayer::mplayerFinished(int exit_code, QProcess::ExitStatus exit_status)
{
	if (exit_status == QProcess::CrashExit)
	{
		emit gstPlayerStopped();
		return;
	}
	else
	{
		qDebug("[VIDEO] gstreamer exited, with code %d", exit_code);
		if (exit_code == 0) //end of song
		{
			emit gstPlayerDone();
			return;
		}
		else if (exit_code == 1) //signal received
		{
			emit gstPlayerStopped();
			return;
		}
	}
}

void GstMediaPlayer::mplayerError(QProcess::ProcessError error)
{
	int idx = gstreamer_proc->metaObject()->indexOfEnumerator("ProcessError");
	QMetaEnum e = gstreamer_proc->metaObject()->enumerator(idx);
	qDebug() << "[VIDEO] gstreamer_proc raised an error: " << "'" << e.key(error) << "'" << "ProcessError" << error
			 << "exitCode:" << gstreamer_proc->exitCode();
}

void GstMediaPlayer::execCmd(QString command)
{
	if (gstreamer_proc->write(command.toAscii() + "\n") < -1)
		qDebug() << "Error MediaPlayer::execCmd():" << gstreamer_proc->errorString();
}
