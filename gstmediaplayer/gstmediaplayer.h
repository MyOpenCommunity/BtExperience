/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
	void pause();
	void resume();
	void stop();
	void seek(int seconds);

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
