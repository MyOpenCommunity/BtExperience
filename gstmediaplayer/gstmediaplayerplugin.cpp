#include "gstmediaplayerplugin.h"

#include <gst/gst.h>

#include <QUrl>
#include <QDebug>
#include <QtPlugin>


class GstMediaPlayerPrivate : public GstMediaPlayer
{
	Q_OBJECT
public:
	GstMediaPlayerPrivate(QObject *parent = 0);
	virtual ~GstMediaPlayerPrivate();
	virtual bool play(QString track);
	virtual QMap<QString, QString> getPlayingInfo();
	virtual void setTrack(QString track);

public slots:
	virtual void pause();
	virtual void resume();
	virtual void stop();

	void handleBusMessage(GstBus *bus, GstMessage *message);

private:
	// disable copy
	GstMediaPlayerPrivate(const GstMediaPlayerPrivate&);

	void handleTagMessage(GstMessage *message);
	void handleStateChange();
	void queryTime();
	bool check_for_state_change;
	GstPipeline *pipeline;
	QMap<QString, QString> metadata;
};


// Anonymous namespaces are useless with extern "C" linkage, see:
// https://groups.google.com/d/msg/comp.lang.c++.moderated/bRso4RIDiBI/F2BscJar_qMJ
extern "C" gboolean gstMediaPlayerBusCallback(GstBus *bus, GstMessage *message, gpointer data)
{
	GstMediaPlayerPrivate *player = static_cast<GstMediaPlayerPrivate *>(data);
	player->handleBusMessage(bus, message);
	return true;
}


GstMediaPlayerPrivate::GstMediaPlayerPrivate(QObject *parent) :
	GstMediaPlayer(parent)
{
	pipeline = GST_PIPELINE(gst_element_factory_make("playbin2", NULL));
	check_for_state_change = false;

	// add bus
	GstBus *bus;
	bus = gst_pipeline_get_bus(GST_PIPELINE(pipeline));
	gst_bus_add_watch(bus, gstMediaPlayerBusCallback, this);
	gst_object_unref(bus);
}

GstMediaPlayerPrivate::~GstMediaPlayerPrivate()
{
	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_NULL);
	gst_object_unref(pipeline);
}

bool GstMediaPlayerPrivate::play(QString track)
{
	setTrack(track);
	GstStateChangeReturn ret = gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PLAYING);
	if (ret == GST_STATE_CHANGE_ASYNC)
	{
		check_for_state_change = true;
		emit gstPlayerStarted();
	}
	else if (ret == GST_STATE_CHANGE_SUCCESS)
		emit gstPlayerResumed();
	return true;
}

void GstMediaPlayerPrivate::setTrack(QString track)
{
	// Get URI
	// Assume that the file is either an absolute path of a local file or
	// an http stream from a media server
	QUrl uri;
	if (track.startsWith('/'))
		uri = QUrl::fromLocalFile(track);
	else if (track.startsWith("http"))
		uri = QUrl(track);
	else
	{
		qWarning() << "GstMediaPlayer::setTrack(), track is not an absolute path or an http uri";
		return;
	}

	GstState saved_state;
	gst_element_get_state(GST_ELEMENT(pipeline), &saved_state, NULL, 0);
	metadata.clear();

	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_READY);
	g_object_set(G_OBJECT(pipeline), "uri", qPrintable(uri.toString()), NULL);
	gst_element_set_state(GST_ELEMENT(pipeline), saved_state);
}

void GstMediaPlayerPrivate::handleBusMessage(GstBus *bus, GstMessage *message)
{
	Q_UNUSED(bus);

	switch (GST_MESSAGE_TYPE(message))
	{
	case GST_MESSAGE_EOS:
	{
		qDebug() << "End-of-stream";
		emit gstPlayerDone();
		break;
	}
	case GST_MESSAGE_ERROR:
	{
		GError *err;
		gst_message_parse_error(message, &err, NULL);
		qWarning("%s", err->message);
		g_error_free(err);
		emit gstPlayerStopped();
		break;
	}
	case GST_MESSAGE_STATE_CHANGED:
		if (check_for_state_change)
		{
			handleStateChange();
			check_for_state_change = false;
		}
		break;

	case GST_MESSAGE_TAG:
		handleTagMessage(message);
		break;

	default:
		break;
	}
}


#define CHANGE_STATE(signal, new_state) \
	do { \
		GstStateChangeReturn ret = gst_element_set_state(GST_ELEMENT(pipeline), new_state); \
		if (ret == GST_STATE_CHANGE_SUCCESS) \
			emit signal(); \
		else if (ret == GST_STATE_CHANGE_ASYNC) \
			check_for_state_change = true; \
	} while (0)

void GstMediaPlayerPrivate::pause()
{
	CHANGE_STATE(gstPlayerPaused, GST_STATE_PAUSED);
}

void GstMediaPlayerPrivate::resume()
{
	CHANGE_STATE(gstPlayerResumed, GST_STATE_PLAYING);
}

void GstMediaPlayerPrivate::stop()
{
	CHANGE_STATE(gstPlayerStopped, GST_STATE_READY);
}

QMap<QString, QString> GstMediaPlayerPrivate::getPlayingInfo()
{
	queryTime();
	return metadata;
}

void GstMediaPlayerPrivate::handleTagMessage(GstMessage *message)
{
	GstTagList *current_tags = NULL;
	gchar *value = NULL;
	gst_message_parse_tag(message, &current_tags);

	// parse title
	if (gst_tag_list_get_string(current_tags, GST_TAG_TITLE, &value))
	{
		metadata["meta_title"] = QString(value);
		g_free(value);
	}

	// parse artist
	if (gst_tag_list_get_string(current_tags, GST_TAG_ARTIST, &value))
	{
		metadata["meta_artist"] = QString(value);
		g_free(value);
	}

	// parse album
	if (gst_tag_list_get_string(current_tags, GST_TAG_ALBUM, &value))
	{
		metadata["meta_album"] = QString(value);
		g_free(value);
	}
}

void GstMediaPlayerPrivate::handleStateChange()
{
	GstState current, next;
	gst_element_get_state(GST_ELEMENT(pipeline), &current, &next, 0);

	switch (GST_STATE_TRANSITION(current, next))
	{
	case GST_STATE_CHANGE_PAUSED_TO_PLAYING:
		emit gstPlayerResumed();
		break;
	case GST_STATE_CHANGE_PLAYING_TO_PAUSED:
		emit gstPlayerPaused();
		break;
	case GST_STATE_CHANGE_PAUSED_TO_READY:
		emit gstPlayerStopped();
		break;
	default:
		break;
	}
}

void GstMediaPlayerPrivate::queryTime()
{
	GstFormat f = GST_FORMAT_TIME;
	gint64 position, duration;
	if (gst_element_query_position(GST_ELEMENT(pipeline), &f, &position))
		metadata["current_time"] = QString::number(GST_TIME_AS_SECONDS(position));
	if (gst_element_query_duration(GST_ELEMENT(pipeline), &f, &duration))
		metadata["total_time"] = QString::number(GST_TIME_AS_SECONDS(duration));
}


GstMediaPlayer *GstMediaPlayerPlugin::createPlayer(QObject *parent)
{
	GError *err;

	if (gst_init_check(NULL, NULL, &err))
	{
		return new GstMediaPlayerPrivate(parent);
	}
	else
	{
		qWarning("Couldn't init GStreamer, error: %s", err->message);
		g_error_free(err);
		return 0;
	}
}

Q_EXPORT_PLUGIN2(gstmediaplayer, GstMediaPlayerPlugin)

#include "gstmediaplayerplugin.moc"
