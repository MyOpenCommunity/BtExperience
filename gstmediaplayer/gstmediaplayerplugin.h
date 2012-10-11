#ifndef GSTMEDIAPLAYERPLUGIN_H
#define GSTMEDIAPLAYERPLUGIN_H

#include <QObject>

#include <gstmediaplayer.h>

class GstMediaPlayerPlugin : public QObject, public GstMediaPlayerInterface
{
	Q_OBJECT
	Q_INTERFACES(GstMediaPlayerInterface)

public:
	virtual GstMediaPlayer *createPlayer(QObject *parent = 0);
};

#endif // GSTMEDIAPLAYERPLUGIN_H
