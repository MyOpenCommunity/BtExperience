#include "gstmediaplayer.h"

#include <QCoreApplication>
#include <QStringList>
#include <QSocketNotifier>
#include <QtDebug>

#include <fcntl.h>


class GstMain : public QObject
{
	Q_OBJECT

public:
	GstMain(GstMediaPlayerImplementation *player);

	void start(int argc, char **argv);

private slots:
	void readInput();
	void parseLine(QString line);

private:
	GstMediaPlayerImplementation *player;
	QString input;
};


GstMain::GstMain(GstMediaPlayerImplementation *_player)
{
	QSocketNotifier *stdin = new QSocketNotifier(0, QSocketNotifier::Read, this);

	connect(stdin, SIGNAL(activated(int)), this, SLOT(readInput()));
	fcntl(0, F_SETFL, (long)O_NONBLOCK);

	player = _player;
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
}


int main(int argc, char **argv)
{
	QCoreApplication app(argc, argv);

	if (!GstMediaPlayerImplementation::initialize())
		return 1;

	GstMediaPlayerImplementation player;
	GstMain main(&player);

	main.start(argc, argv);
	return app.exec();
}

#include "gstmain.moc"
