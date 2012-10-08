#include "gstmediaplayer.h"

#include <QUrl>
#include <QDebug>

namespace {
	extern "C" gboolean gstBusCallback(GstBus *bus, GstMessage *message, gpointer data)
	{
		GstMediaPlayer *player = static_cast<GstMediaPlayer *>(data);
		player->handleBusMessage(bus, message);
		return true;
	}

	inline gint64 nsToSecs(gint64 val)
	{
		return val / 1000000000;
	}
}

GstMediaPlayer::GstMediaPlayer(QObject *parent) :
	QObject(parent)
{
	pipeline = GST_PIPELINE(gst_element_factory_make("playbin2", NULL));

	// add bus
	GstBus *bus;
	bus = gst_pipeline_get_bus(GST_PIPELINE(pipeline));
	gst_bus_add_watch(bus, gstBusCallback, this);
	gst_object_unref(bus);

}

GstMediaPlayer::~GstMediaPlayer()
{
	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_NULL);
	gst_object_unref(pipeline);
}

bool GstMediaPlayer::play(QString track)
{
	// Get URI
	QUrl uri = QUrl::fromLocalFile(track);

	g_object_set(G_OBJECT(pipeline), "uri", qPrintable(uri.toString()), NULL);
	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PLAYING);
	return true;
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
	{
		GstState current;
		gst_element_get_state(GST_ELEMENT(pipeline), &current, NULL, 0);
		// TODO: maybe this should be:
		// switch (GST_STATE_TRANSITION(current, next))
		// so that we have a finer control on the state transitions
		if (current == GST_STATE_PLAYING)
		{
			GstFormat f = GST_FORMAT_TIME;
			gint64 duration;
			if (gst_element_query_duration(GST_ELEMENT(pipeline), &f, &duration))
				metadata["total_time"] = QString::number(nsToSecs(duration));

			emit gstPlayerResumed();
		}
		else if (current == GST_STATE_PAUSED)
			emit gstPlayerPaused();
		break;
	}

	case GST_MESSAGE_TAG:
		handleTagMessage(message);
		break;

	default:
		break;
	}
}

void GstMediaPlayer::pause()
{
	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PAUSED);
}

void GstMediaPlayer::resume()
{
	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_PLAYING);
}

QMap<QString, QString> GstMediaPlayer::getPlayingInfo()
{
	GstFormat f = GST_FORMAT_TIME;
	gint64 position;
	if (gst_element_query_position(GST_ELEMENT(pipeline), &f, &position))
		metadata["current_time"] = QString::number(nsToSecs(position));
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
