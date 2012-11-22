#include "gstmediaplayer.h"

#include <QCoreApplication>
#include <QStringList>


class GstMain : public QObject
{
	Q_OBJECT

public:
	GstMain(GstMediaPlayerImplementation *player);

	void start(int argc, char **argv);

private:
	GstMediaPlayerImplementation *player;
};


GstMain::GstMain(GstMediaPlayerImplementation *_player)
{
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
