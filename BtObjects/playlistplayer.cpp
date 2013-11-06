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

#include "playlistplayer.h"
#include "folderlistmodel.h"
#include "mounts.h"
#include "medialink.h"

#include <libqtcommon/list_manager.h>

#include <QDebug>
#include <QTime>

// The timeout for a single item in msec
#define LOOP_TIMEOUT 2000

#define VOLUME_INCREMENT 5


PlayListPlayer::PlayListPlayer(QObject *parent) :
	QObject(parent)
{
	// Sometimes it happens that mplayer can't reproduce a song or a web radio,
	// for example because the network is down. In this case the mplayer exits
	// immediately with the signal mplayerDone (== everything ok). Since the
	// UI starts reproducing the next item when receiving the mplayerDone signal,
	// this causes an infinite loop. To avoid that, we count the time elapsed to
	// reproduce the whole item list, and if it is under LOOP_TIMEOUT * num_of_items
	// we stop the reproduction.
	loop_starting_file = -1;

	is_video = false;
	actual_list = 0;
	upnp_state = 0;
	local_state = 0;
	local_list = new FileListManager;
	connect(local_list, SIGNAL(currentFileChanged()), SLOT(updateCurrentLocal()));

	upnp_list = new UPnpListManager(UPnPListModel::getXmlDevice());
	connect(upnp_list, SIGNAL(currentFileChanged()), SLOT(updateCurrentUpnp()));
	connect(MountWatcher::instance(), SIGNAL(directoryUnmounted(QString,MountPoint::MountType)),
		this, SLOT(directoryUnmounted(QString)));

	emit playingChanged();
}

PlayListPlayer::~PlayListPlayer()
{
	clearListState();
}

void PlayListPlayer::clearListState()
{
	delete upnp_state;
	delete local_state;
	upnp_state = local_state = 0;
}

void PlayListPlayer::generatePlaylistLocal(DirectoryListModel *model, int index, int total_files, bool _is_video)
{
	terminate();
	is_video = _is_video;
	generate(model, index, total_files);
}

void PlayListPlayer::generatePlaylistUPnP(UPnPListModel *model, int index, int total_files, bool _is_video)
{
	terminate();
	is_video = _is_video;
	generate(model, index, total_files);
}

void PlayListPlayer::generatePlaylistWebRadio(QList<QObject *> items, int index, int total_files)
{
	terminate();
	is_video = false;
	generate(items, index, total_files);
}

bool PlayListPlayer::matchesSavedState(bool is_upnp, QVariantList root_path) const
{
	if (!is_upnp && local_state && local_state->getRootPath() == root_path)
		return true;
	else if (is_upnp && upnp_state)
		return true;
	else
		return false;
}

void PlayListPlayer::restoreLocalState(DirectoryListModel *model)
{
	if (local_state)
		model->restore(local_state);
}

void PlayListPlayer::restoreUpnpState(UPnPListModel *model)
{
	if (upnp_state)
		model->restore(upnp_state);
}

bool PlayListPlayer::isPlaying() const
{
	// if actual_list is neither pointing to local_list nor to upnp_list we
	// assume we are not playing anything and one generatePlaylist* method
	// must be called to setup the player; otherwise we are already setup and
	// the generatePlaylist* call may be skipped (or done if we want to reset
	// the player state)
	return (actual_list == local_list || actual_list == upnp_list);
}

void PlayListPlayer::directoryUnmounted(QString dir)
{
	if (actual_list != local_list)
		return;
	if (current.startsWith(dir))
		emit deviceUnmounted();
}

void PlayListPlayer::previous()
{
	if (actual_list)
		actual_list->previousFile();
}

void PlayListPlayer::next()
{
	if (actual_list)
		actual_list->nextFile();
}

bool PlayListPlayer::checkLoop()
{
	if (actual_list == 0)
		return true;

	if (loop_starting_file == -1)
	{
		loop_starting_file = actual_list->currentIndex();
		loop_total_time = actual_list->totalFiles() * LOOP_TIMEOUT;

		loop_time_counter.start();
	}
	else if (loop_starting_file == (actual_list->currentIndex() + 1) % actual_list->totalFiles())
	{
		if (loop_time_counter.elapsed() < loop_total_time)
		{
			qWarning() << "MediaPlayer: loop detected, force stop";
			emit loopDetected();

			return true;
		}
		else
		{
			// we restart the time counter to find loop that happens when the player
			// is already started.
			loop_time_counter.start();
		}
	}

	return false;
}

void PlayListPlayer::resetLoopCheck()
{
	// this is necessary to trigger loop detection for single-file lists
	loop_starting_file = actual_list ? actual_list->currentIndex() : -1;
}

void PlayListPlayer::generate(DirectoryListModel *model, int index, int total_files)
{
	Q_UNUSED(total_files);

	// sets list to use since now
	actual_list = local_list;
	emit playingChanged();

	// saves old range to restore it later
	QVariantList oldRange = model->getRange();

	// here, index is absolute, so removes range
	model->setRange(QVariantList() << -1 << -1);

	// needs file to know file type (needs to select files of the same type)
	FileObject *file = static_cast<FileObject *>(model->getObject(index));

	// creates list of files (of the same type) to play
	EntryInfoList entry_list;
	for (int i = 0; i < model->getCount(); ++i)
	{
		FileObject *fo = static_cast<FileObject *>(model->getObject(i));
		if (file->getFileType() == fo->getFileType())
			entry_list << fo->getEntryInfo();
		if (fo == file)
			index = entry_list.size() - 1;
	}

	// saves retrieved data in internal play_list and seeks to actual selected file
	FileListManager *list = static_cast<FileListManager *>(local_list);
	list->setList(entry_list);
	list->setCurrentIndex(index);

	// restores range (model belongs to QML!)
	model->setRange(oldRange);

	clearListState();
	local_state = model->clone();

	// updates reference to current (emits currentChanged)
	updateCurrent();
}

void PlayListPlayer::generate(UPnPListModel *model, int index, int total_files)
{
	// sets list to use since now
	actual_list = upnp_list;
	emit playingChanged();

	// needs file for setting starting file
	FileObject *file = static_cast<FileObject *>(model->getObject(index));

	// saves retrieved data in internal play_list and seeks to actual selected file
	UPnpListManager *list = static_cast<UPnpListManager *>(upnp_list);
	list->setStartingFile(file->getEntryInfo());
	list->setCurrentIndex(index);
	list->setTotalFiles(total_files);

	clearListState();
	upnp_state = model->clone();

	// no need to call updateCurrent(): it is called when receiving the status update
	// from XmlDevice
}

void PlayListPlayer::generate(QList<QObject *> items, int index, int total_files)
{
	Q_UNUSED(total_files);

	// sets list to use since now
	actual_list = local_list;
	emit playingChanged();

	// creates list of files (of the same type) to play
	EntryInfoList entry_list;
	foreach (QObject *obj, items)
	{
		MediaLink *item = qobject_cast<MediaLink *>(obj);
		if (!item)
		{
			qWarning() << "Invalid object in web radio list" << obj;
			continue;
		}

		EntryInfo info;

		info.type = EntryInfo::AUDIO;
		info.path = item->getAddress();
		info.name = item->getName();
		info.metadata["title"] = info.name;

		entry_list << info;
	}

	// saves retrieved data in internal play_list and seeks to actual selected file
	FileListManager *list = static_cast<FileListManager *>(local_list);
	list->setList(entry_list);
	list->setCurrentIndex(index);

	clearListState();

	// updates reference to current (emits currentChanged)
	updateCurrent();
}

void PlayListPlayer::reset()
{
	is_video = false;
	actual_list = 0;
	emit playingChanged();

	// Also reset loop check index, for example when generating a new playlist
	resetLoopCheck();
	if (!current.isEmpty())
	{
		current = current_name = QString();
		emit currentChanged();
	}
}

void PlayListPlayer::updateCurrentLocal()
{
	if (actual_list == local_list)
		updateCurrent();
}

void PlayListPlayer::updateCurrentUpnp()
{
	if (actual_list == upnp_list)
		updateCurrent();
}

void PlayListPlayer::updateCurrent()
{
	if (!actual_list)
		return;
	QString candidate = actual_list->currentFilePath();
	if (candidate.isEmpty())
		return;
	current = candidate;
	current_name = actual_list->currentMeta()["title"];
	emit currentChanged();
}


PhotoPlayer::PhotoPlayer(QObject *parent) :
	PlayListPlayer(parent)
{
	connect(this, SIGNAL(currentChanged()), SIGNAL(fileNameChanged()));
}

void PhotoPlayer::prevPhoto()
{
	previous();
}

void PhotoPlayer::nextPhoto()
{
	next();
}

void PhotoPlayer::terminate()
{
	PlayListPlayer::reset();
}


AudioVideoPlayer::AudioVideoPlayer(QObject *parent) :
	PlayListPlayer(parent)
{
	user_track_change_request = false;
	current_time_s = total_time_s = percentage = 0;

	media_player = new MultiMediaPlayer();
	connect(media_player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
			SLOT(handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState)));
	connect(media_player, SIGNAL(trackInfoChanged(QVariantMap)), SLOT(trackInfoChanged()));
	connect(media_player, SIGNAL(trackInfoChanged(QVariantMap)), SIGNAL(trackInformationChanged()));
	connect(media_player, SIGNAL(currentSourceChanged(QString)), SIGNAL(trackNameChanged()));
	connect(media_player, SIGNAL(volumeChanged(int)), SIGNAL(volumeChanged()));
	connect(media_player, SIGNAL(muteChanged(bool)), SIGNAL(muteChanged()));
	connect(media_player, SIGNAL(videoRectChanged(QRect)), SIGNAL(videoRectChanged()));

	connect(this, SIGNAL(currentChanged()), SLOT(play()));
	connect(this, SIGNAL(deviceUnmounted()), this, SLOT(terminate()));
}

void AudioVideoPlayer::prevTrack()
{
	resetLoopCheck();
	previous();
}

void AudioVideoPlayer::nextTrack()
{
	resetLoopCheck();
	next();
}

void AudioVideoPlayer::pause()
{
	media_player->pause();
}

void AudioVideoPlayer::resume()
{
	if (media_player->getPlayerState() == MultiMediaPlayer::Stopped)
	{
		if (!getCurrent().isEmpty())
		{
			resetLoopCheck();
			play();
		}
		else
			qWarning("There is no previous playback to resume");
	}
	else
		media_player->resume();
}

void AudioVideoPlayer::restart()
{
	user_track_change_request = true;
	play();
}

void AudioVideoPlayer::terminate()
{
	user_track_change_request = true;
	media_player->stop();
	PlayListPlayer::reset();
}

int AudioVideoPlayer::getVolume() const
{
	return media_player->getVolume();
}

void AudioVideoPlayer::setVolume(int newValue)
{
	media_player->setVolume(newValue);
}

bool AudioVideoPlayer::getMute() const
{
	return media_player->getMute();
}

void AudioVideoPlayer::setMute(bool newValue)
{
	media_player->setMute(newValue);
}

bool AudioVideoPlayer::isPlaying() const
{
	return media_player->getPlayerState() == MultiMediaPlayer::Playing;
}

bool AudioVideoPlayer::isStopped() const
{
	return media_player->getPlayerState() == MultiMediaPlayer::Stopped;
}

QVariantMap AudioVideoPlayer::getTrackInformation() const
{
	return media_player->getTrackInfo();
}

void AudioVideoPlayer::seek(int seconds)
{
	media_player->seek(seconds);
}

QRect AudioVideoPlayer::getVideoRect() const
{
	return media_player->getVideoRect();
}

void AudioVideoPlayer::setVideoRect(QRect newValue)
{
	media_player->setVideoRect(newValue);
}

void AudioVideoPlayer::incrementVolume()
{
	setMute(false);
	setVolume(getVolume() + VOLUME_INCREMENT);
}

void AudioVideoPlayer::decrementVolume()
{
	setMute(false);
	setVolume(getVolume() - VOLUME_INCREMENT);
}

void AudioVideoPlayer::handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state)
{
	if (new_state == MultiMediaPlayer::Stopped && !user_track_change_request)
	{
		if (!checkLoop())
			next();
	}
	user_track_change_request = false;
	emit playingChanged();
	emit stoppedChanged();
}

void AudioVideoPlayer::play()
{
	QVariantMap default_info;

	default_info["meta_title"] = getCurrentName();
	default_info["stream_title"] = getCurrentName();

	// force player restart for single-file lists
	if (media_player->getCurrentSource() == getCurrent())
		media_player->stop();
	media_player->setCurrentSource(getCurrent());
	media_player->setDefaultTrackInfo(default_info);
	if (media_player->getPlayerState() == MultiMediaPlayer::Stopped)
		media_player->play();
}

QString AudioVideoPlayer::getTrackName() const
{
	return media_player->getCurrentSource();
}

QString AudioVideoPlayer::getTimeString(const QVariant& value) const
{
	QTime t = value.toTime();
	if (!t.isValid())
		return "--:--:--";
	QString format = "ss";
	if (t.minute() > 0 || t.hour() > 0)
	{
		format = "mm:" + format;
		if (t.hour() > 0)
			format = "h:" + format;
	}
	return t.toString(format);
}

QString AudioVideoPlayer::getCurrentTime() const
{
	return getTimeString(current_time_s);
}

QString AudioVideoPlayer::getTotalTime() const
{
	return getTimeString(total_time_s);
}

void AudioVideoPlayer::trackInfoChanged()
{
	QVariantMap track_info = media_player->getTrackInfo();

	int total = 0;
	QVariant actual_total = 0;

	if (track_info.contains("total_time"))
	{
		QVariant t = track_info["total_time"];
		QTime v = t.toTime();
		if (v.isValid())
		{
			if (actual_total != t)
				actual_total = t;
			total = v.second() + 60 * v.minute() + 60 * 60 * v.hour();
		}
	}

	if (total_time_s != actual_total)
	{
		total_time_s = actual_total;
		emit totalTimeChanged();
	}

	int current = 0;
	QVariant actual_current = 0;

	if (track_info.contains("current_time"))
	{
		QVariant c = track_info["current_time"];
		QTime v = c.toTime();
		if (v.isValid())
		{
			if (actual_current != c)
				actual_current = c;
			current = v.second() + 60 * v.minute() + 60 * 60 * v.hour();
		}
	}

	if (current_time_s != actual_current)
	{
		current_time_s = actual_current;
		emit currentTimeChanged();
	}

	if (total == 0)
		return;

	double p = 100.0 * current / total;

	if (p < 0.0)
		p = 0.0;
	if (p > 100.0)
		p = 100.0;

	if (percentage != p)
	{
		percentage = p;
		emit percentageChanged();
	}
}
