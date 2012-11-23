#include "gstmediaplayer.h"

#include <QCoreApplication>
#include <QStringList>
#include <QSocketNotifier>
#include <QTimer>
#include <QtDebug>

#include <fcntl.h>


class GstMain : public QObject
{
	Q_OBJECT

public:
	GstMain(GstMediaPlayerImplementation *player);

	void start(int argc, char **argv);

private slots:
	void paused();
	void checkMetadata();
	void pollGlib();

	void readInput();
	void parseLine(QString line);

private:
	QTimer *poll;
	GstMediaPlayerImplementation *player;
	QMap<QString, QString> metadata;
	QString input;
};


GstMain::GstMain(GstMediaPlayerImplementation *_player)
{
	QSocketNotifier *stdin = new QSocketNotifier(0, QSocketNotifier::Read, this);

	connect(stdin, SIGNAL(activated(int)), this, SLOT(readInput()));
	fcntl(0, F_SETFL, (long)O_NONBLOCK);

	poll = new QTimer();
	poll->setInterval(500);
	connect(poll, SIGNAL(timeout()), this, SLOT(checkMetadata()));

	player = _player;

	connect(player, SIGNAL(gstPlayerStarted()), poll, SLOT(start()));
	connect(player, SIGNAL(gstPlayerPaused()), poll, SLOT(stop()));
	connect(player, SIGNAL(gstPlayerResumed()), poll, SLOT(start()));

	connect(player, SIGNAL(gstPlayerPaused()), this, SLOT(paused()));
	connect(player, SIGNAL(gstPlayerDone()), qApp, SLOT(quit()));
	connect(player, SIGNAL(gstPlayerStopped()), qApp, SLOT(quit()));

#ifdef QT_NO_GLIB
	// if Qt is compiled without Glib integration, run the Glib event loop from a timer
	QTimer *glib_integration = new QTimer(this);
	glib_integration->setInterval(100);
	glib_integration->start();
	connect(glib_integration, SIGNAL(timeout()), this, SLOT(pollGlib()));
#endif
}

void GstMain::pollGlib()
{
	while (g_main_context_iteration(g_main_context_default(), FALSE))
		;
}

void GstMain::start(int argc, char **argv)
{
	int i;

	for (i = 1; i < argc; ++i)
	{
		if (argv[i][0] != '-')
			break;

		QByteArray arg(argv[i]);

		if (arg.startsWith("--rect="))
		{
			QList<QByteArray> parts = arg.mid(7).split(',');

			player->setPlayerRect(parts[0].toInt(), parts[1].toInt(), parts[2].toInt(), parts[3].toInt());
		}
	}

	metadata.clear();
	player->play(QString::fromLocal8Bit(argv[i]));
}

void GstMain::readInput()
{
	char buf[30];

	for (;;)
	{
		int rd = read(0, buf, sizeof(buf) - 1);

		if (rd <= 0)
			break;
		buf[rd] = 0;

		input.append(buf);
	}

	QStringList lines = input.split("\n");

	// put back incomplete last line
	input = lines.back();
	lines.pop_back();

	foreach (QString line, lines)
		parseLine(line);
}

void GstMain::parseLine(QString line)
{
	if (line.startsWith("resize "))
	{
		QStringList parts = line.split(" ");

		player->setPlayerRect(parts[1].toInt(), parts[2].toInt(), parts[3].toInt(), parts[4].toInt());
	}
	else if (line.startsWith("set_track "))
	{
		metadata.clear();
		player->setTrack(line.mid(10));
	}
	else if (line == "pause")
	{
		player->pause();
	}
	else if (line == "resume")
	{
		player->resume();
	}
}

void GstMain::paused()
{
	static char buffer[] = "state: paused\n";

	write(1, buffer, sizeof(buffer));
}

void GstMain::checkMetadata()
{
	QMap<QString, QString> new_metadata = player->getPlayingInfo();

	foreach (QString key, new_metadata.keys())
	{
		if (metadata.value(key) == new_metadata.value(key))
			continue;
		QByteArray line = (key + ": " + new_metadata.value(key) + "\n").toUtf8();

		metadata[key] = new_metadata[key];
		write(1, line.constData(), line.length());
	}
}


int main(int argc, char **argv)
{
#ifdef QT_NO_GLIB
	g_thread_init(NULL);
#endif
	QCoreApplication app(argc, argv);

	if (!GstMediaPlayerImplementation::initialize())
		return 1;

	GstMediaPlayerImplementation player;
	GstMain main(&player);

	main.start(argc, argv);
	return app.exec();
}

#include "gstmain.moc"
