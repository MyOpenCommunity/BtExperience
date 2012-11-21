#include "gstmediaplayer.h"

#include <QCoreApplication>
#include <QStringList>


class GstMain : public QObject
{
	Q_OBJECT

public:
	GstMain(GstMediaPlayerImplementation *player);

	void start(QStringList args);

private:
	GstMediaPlayerImplementation *player;
};


GstMain::GstMain(GstMediaPlayerImplementation *_player)
{
	player = _player;
}

void GstMain::start(QStringList args)
{
	player->play(args[1]);
}


int main(int argc, char **argv)
{
	QCoreApplication app(argc, argv);

	if (!GstMediaPlayerImplementation::initialize())
		return 1;

	GstMediaPlayerImplementation player;
	GstMain main(&player);

	main.start(QCoreApplication::arguments());
	return app.exec();
}

#include "gstmain.moc"
