#ifndef GSTMEDIAPLAYER_H
#define GSTMEDIAPLAYER_H

#include <QObject>
#include <QMap>
#include <QRect>

#include <gst/gst.h>


class GstMediaPlayerImplementation : public QObject
{
	Q_OBJECT

public:
	GstMediaPlayerImplementation(QObject *parent = 0);

	virtual ~GstMediaPlayerImplementation();
	virtual bool play(QString track);
	virtual QMap<QString, QString> getPlayingInfo();
	virtual void setTrack(QString track);

	static bool initialize();

	void setPlayerRect(int x, int y, int width, int height);

public slots:
	virtual void pause();
	virtual void resume();
	virtual void stop();

	void handleBusMessage(GstBus *bus, GstMessage *message);

signals:
	void gstPlayerStarted();
	void gstPlayerPaused();
	void gstPlayerResumed();
	void gstPlayerDone();
	void gstPlayerStopped();

private:
	// disable copy
	GstMediaPlayerImplementation(const GstMediaPlayerImplementation&);

	QSize getVideoSize();
	void setOverlayRect(QRect rect);
	void centerOverlay();

	void handleTagMessage(GstMessage *message);
	void handleStateChange(GstMessage *message);
	void queryTime();

	bool check_for_state_change;
	GstPipeline *pipeline;
	QMap<QString, QString> metadata;
	QSize video_size;
	QRect player_rect;
};



#endif // GSTMEDIAPLAYER_H
