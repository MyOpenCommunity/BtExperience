#include "gstmediaplayer.h"

#include <QUrl>
#include <QDebug>

extern "C" gboolean gstMediaPlayerBusCallback(GstBus *bus, GstMessage *message, gpointer data)
{
	GstMediaPlayer *player = static_cast<GstMediaPlayer *>(data);
	player->handleBusMessage(bus, message);
	return true;
}

GstMediaPlayer::GstMediaPlayer(QObject *parent) :
	QObject(parent)
{
	pipeline = GST_PIPELINE(gst_element_factory_make("playbin2", NULL));
	check_for_state_change = false;

	// add bus
	GstBus *bus;
	bus = gst_pipeline_get_bus(GST_PIPELINE(pipeline));
	gst_bus_add_watch(bus, gstMediaPlayerBusCallback, this);
	gst_object_unref(bus);
}

GstMediaPlayer::~GstMediaPlayer()
{
	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_NULL);
	gst_object_unref(pipeline);
}

bool GstMediaPlayer::play(QString track)
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

void GstMediaPlayer::setTrack(QString track)
{
	// Get URI
	// Assume that the file is either an absolute path of a local file or
	// an http stream from a media server
	QUrl uri;
	if (track.startsWith('/'))
		uri.fromLocalFile(track);
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

void GstMediaPlayer::handleBusMessage(GstBus *bus, GstMessage *message)
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

void GstMediaPlayer::pause()
{
	CHANGE_STATE(gstPlayerPaused, GST_STATE_PAUSED);
}

void GstMediaPlayer::resume()
{
	CHANGE_STATE(gstPlayerResumed, GST_STATE_PLAYING);
}

void GstMediaPlayer::stop()
{
	CHANGE_STATE(gstPlayerStopped, GST_STATE_READY);
}

QMap<QString, QString> GstMediaPlayer::getPlayingInfo()
{
	queryTime();
	return metadata;
}

void GstMediaPlayer::handleTagMessage(GstMessage *message)
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

void GstMediaPlayer::handleStateChange()
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

void GstMediaPlayer::queryTime()
{
	GstFormat f = GST_FORMAT_TIME;
	gint64 position, duration;
	if (gst_element_query_position(GST_ELEMENT(pipeline), &f, &position))
		metadata["current_time"] = QString::number(GST_TIME_AS_SECONDS(position));
	if (gst_element_query_duration(GST_ELEMENT(pipeline), &f, &duration))
		metadata["total_time"] = QString::number(GST_TIME_AS_SECONDS(duration));
}
