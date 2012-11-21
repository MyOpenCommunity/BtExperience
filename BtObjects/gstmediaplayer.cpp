#include "gstmediaplayer.h"

#include <QCoreApplication>
#include <QMetaEnum>
#include <QtDebug>


GstExternalMediaPlayer::GstExternalMediaPlayer(QObject *parent)
{
	gstreamer_proc = new QProcess();
	paused = false;

	// connect(gstreamer_proc, SIGNAL(readyReadStandardError()), SLOT(readStandardError()));
	connect(gstreamer_proc, SIGNAL(finished(int, QProcess::ExitStatus)), SLOT(mplayerFinished(int, QProcess::ExitStatus)));
	connect(gstreamer_proc, SIGNAL(error(QProcess::ProcessError)), SLOT(mplayerError(QProcess::ProcessError)));
}

bool GstExternalMediaPlayer::play(QString track)
{
	return runMPlayer(QList<QString>() << track);
}

bool GstExternalMediaPlayer::runMPlayer(const QList<QString> &args)
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

void GstExternalMediaPlayer::quit()
{
	if (gstreamer_proc->state() == QProcess::Running)
	{
		gstreamer_proc->terminate();
		qDebug("MediaPlayer::quit() waiting for mplayer to quit...");
		if (!gstreamer_proc->waitForFinished(300))
			qWarning() << "Couldn't terminate mplayer";
	}
}


void GstExternalMediaPlayer::stop()
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

void GstExternalMediaPlayer::mplayerFinished(int exit_code, QProcess::ExitStatus exit_status)
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

void GstExternalMediaPlayer::mplayerError(QProcess::ProcessError error)
{
	int idx = gstreamer_proc->metaObject()->indexOfEnumerator("ProcessError");
	QMetaEnum e = gstreamer_proc->metaObject()->enumerator(idx);
	qDebug() << "[AUDIO] mplayer_proc raised an error: " << "'" << e.key(error) << "'";
}
