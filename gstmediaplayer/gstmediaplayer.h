#ifndef GSTMEDIAPLAYER_H
#define GSTMEDIAPLAYER_H

#include <QObject>
#include <QMap>

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

	void handleTagMessage(GstMessage *message);
	void handleStateChange();
	void queryTime();
	bool check_for_state_change;
	GstPipeline *pipeline;
	QMap<QString, QString> metadata;
};



#endif // GSTMEDIAPLAYER_H
