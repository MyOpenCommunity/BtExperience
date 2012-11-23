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


GstMediaPlayer::GstMediaPlayer(QObject *parent) : QObject(parent)
{
	gstreamer_proc = new QProcess();
	paused = false;

	// connect(gstreamer_proc, SIGNAL(readyReadStandardError()), SLOT(readStandardError()));
	connect(gstreamer_proc, SIGNAL(finished(int, QProcess::ExitStatus)), SLOT(mplayerFinished(int, QProcess::ExitStatus)));
	connect(gstreamer_proc, SIGNAL(error(QProcess::ProcessError)), SLOT(mplayerError(QProcess::ProcessError)));
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

	qDebug() << "About to start mplayer exec (" << global_player_executable << ") with args: " << args;
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
		qDebug("MediaPlayer::quit() waiting for mplayer to quit...");
		if (!gstreamer_proc->waitForFinished(300))
			qWarning() << "Couldn't terminate mplayer";
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
	if (paused)
	{
		paused = false;
		emit gstPlayerStopped();
	}

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
		qDebug("[AUDIO] mplayer exited, with code %d", exit_code);
		if (exit_code == 0) //end of song
		{
			emit gstPlayerDone();
			return;
		}
		else if(exit_code == 1) //signal received
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
	qDebug() << "[AUDIO] mplayer_proc raised an error: " << "'" << e.key(error) << "'";
}

void GstMediaPlayer::execCmd(QString command)
{
	if (gstreamer_proc->write(command.toAscii() + "\n") < -1)
		qDebug() << "Error MediaPlayer::execCmd():" << gstreamer_proc->errorString();
}
