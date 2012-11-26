#include "gstmediaplayer.h"

#include <gst/video/video.h>

#include <QRect>
#include <QUrl>
#include <QDebug>

#define READY_TIMEOUT 30


// Anonymous namespaces are useless with extern "C" linkage, see:
// https://groups.google.com/d/msg/comp.lang.c++.moderated/bRso4RIDiBI/F2BscJar_qMJ
extern "C" gboolean gstMediaPlayerBusCallback(GstBus *bus, GstMessage *message, gpointer data)
{
	GstMediaPlayerImplementation *player = static_cast<GstMediaPlayerImplementation *>(data);
	player->handleBusMessage(bus, message);
	return true;
}


GstMediaPlayerImplementation::GstMediaPlayerImplementation(QObject *parent) :
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

GstMediaPlayerImplementation::~GstMediaPlayerImplementation()
{
	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_NULL);
	gst_object_unref(pipeline);
}

bool GstMediaPlayerImplementation::play(QString track)
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

void GstMediaPlayerImplementation::setPlayerRect(int x, int y, int width, int height)
{
	player_rect = QRect(x, y, width, height);
	centerOverlay();
}

void GstMediaPlayerImplementation::setTrack(QString track)
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
	if (saved_state == GST_STATE_NULL)
		saved_state = GST_STATE_PAUSED;

	gst_element_set_state(GST_ELEMENT(pipeline), GST_STATE_READY);
	g_object_set(G_OBJECT(pipeline), "uri", qPrintable(uri.toString()), NULL);
	gst_element_set_state(GST_ELEMENT(pipeline), saved_state);

	for (int i = 0; i < READY_TIMEOUT; ++i)
	{
		GstState state = GST_STATE_NULL;

		// wait for pipeline to become ready
		gst_element_get_state(GST_ELEMENT(pipeline), &state, NULL, GST_SECOND);
		if (state == saved_state)
		{
			video_size = getVideoSize();
			centerOverlay();
			break;
		}
	}
}

void GstMediaPlayerImplementation::centerOverlay()
{
	// center over
	double h_ratio = double(player_rect.width()) / video_size.width();
	double v_ratio = double(player_rect.height()) / video_size.height();
	QRect overlay;

	if (h_ratio < 1 || v_ratio < 1)
	{
		double ratio = qMin(h_ratio, v_ratio);

		overlay = QRect(0, 0, video_size.width() * ratio, video_size.height() * ratio);
	}
	else
		overlay = QRect(0, 0, video_size.width(), video_size.height());

	setOverlayRect(overlay.translated(-overlay.center() + player_rect.center()));
}

void GstMediaPlayerImplementation::handleBusMessage(GstBus *bus, GstMessage *message)
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
		qWarning("Error: %s", err->message);
		g_error_free(err);
		emit gstPlayerStopped();
		break;
	}
	case GST_MESSAGE_STATE_CHANGED:
		if (check_for_state_change)
		{
			handleStateChange(message);
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

void GstMediaPlayerImplementation::pause()
{
	CHANGE_STATE(gstPlayerPaused, GST_STATE_PAUSED);
}

void GstMediaPlayerImplementation::resume()
{
	CHANGE_STATE(gstPlayerResumed, GST_STATE_PLAYING);
}

void GstMediaPlayerImplementation::stop()
{
	CHANGE_STATE(gstPlayerStopped, GST_STATE_READY);
}

QMap<QString, QString> GstMediaPlayerImplementation::getPlayingInfo()
{
	queryTime();
	return metadata;
}

void GstMediaPlayerImplementation::handleTagMessage(GstMessage *message)
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

QSize GstMediaPlayerImplementation::getVideoSize()
{
	GstPad *pad;
	int width = -1, height = -1;

	g_signal_emit_by_name(GST_ELEMENT(pipeline), "get-video-pad", 0, &pad, NULL);
	GstCaps *caps = gst_pad_get_negotiated_caps(pad);

	gst_structure_get_int(gst_caps_get_structure(caps, 0), "width", &width);
	gst_structure_get_int(gst_caps_get_structure(caps, 0), "height", &height);

	gst_object_unref(pad);

	return QSize(width, height);
}

void GstMediaPlayerImplementation::setOverlayRect(QRect rect)
{
	GstElement *element = gst_bin_get_by_name(GST_BIN(pipeline), "videosink-actual-sink-tidisplaysink2");
	if (!element)
		return;

	g_object_set(GST_OBJECT(element),
		     "overlay-top", rect.top(),
		     "overlay-left", rect.left(),
		     "overlay-width", rect.width(),
		     "overlay-height", rect.height(),
		     NULL);
	gst_object_unref(element);
}

void GstMediaPlayerImplementation::handleStateChange(GstMessage *message)
{
	GstState current, next;
	gst_message_parse_state_changed(message, &current, &next, 0);

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

void GstMediaPlayerImplementation::queryTime()
{
	GstFormat f = GST_FORMAT_TIME;
	gint64 position, duration;
	if (gst_element_query_position(GST_ELEMENT(pipeline), &f, &position))
		metadata["current_time"] = QString::number(GST_TIME_AS_SECONDS(position));
	if (gst_element_query_duration(GST_ELEMENT(pipeline), &f, &duration))
		metadata["total_time"] = QString::number(GST_TIME_AS_SECONDS(duration));
}

bool GstMediaPlayerImplementation::initialize()
{
	GError *err;

	if (gst_init_check(NULL, NULL, &err))
	{
		return true;
	}
	else
	{
		qWarning("Couldn't init GStreamer, error: %s", err->message);
		g_error_free(err);
		return false;
	}
}
