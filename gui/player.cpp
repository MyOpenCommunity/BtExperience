#include "player.h"
#include "folderlistmodel.h"
#include "list_manager.h"

#include <QDebug>
#include <QTime>

#define VOLUME_INCREMENT 5


PlayListPlayer::PlayListPlayer(QObject *parent) :
	QObject(parent)
{
	is_video = false;
	actual_list = 0;
	emit playingChanged();
	local_list = new FileListManager;
	connect(local_list, SIGNAL(currentFileChanged()), SLOT(updateCurrent()));
	upnp_list = new UPnpListManager(UPnPListModel::getXmlDevice());
	connect(upnp_list, SIGNAL(currentFileChanged()), SLOT(updateCurrent()));
}

void PlayListPlayer::generatePlaylistLocal(DirectoryListModel *model, int index, int total_files, bool _is_video)
{
	is_video = _is_video;
	generate(model, index, total_files);
}

void PlayListPlayer::generatePlaylistUPnP(UPnPListModel *model, int index, int total_files, bool _is_video)
{
	is_video = _is_video;
	generate(model, index, total_files);
}

bool PlayListPlayer::isPlaying()
{
	// if actual_list is neither pointing to local_list nor to upnp_list we
	// assume we are not playing anything and one generatePlaylist* method
	// must be called to setup the player; otherwise we are already setup and
	// the generatePlaylist* call may be skipped (or done if we want to reset
	// the player state)
	return (actual_list == local_list || actual_list == upnp_list);
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

	// updates reference to current (emits currentChanged)
	updateCurrent();
}

void PlayListPlayer::reset()
{
	is_video = false;
	actual_list = 0;
	emit playingChanged();
}

void PlayListPlayer::updateCurrent()
{
	if (!actual_list)
		return;
	QString candidate = actual_list->currentFilePath();
	if (candidate == current)
		return;
	if (candidate.isEmpty())
		return;
	current = candidate;
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


AudioVideoPlayer::AudioVideoPlayer(QObject *parent) :
	PlayListPlayer(parent)
{
	user_track_change_request = false;
	current_time_s = total_time_s = percentage = 0;

	media_player = new MultiMediaPlayer();
	connect(media_player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
			SLOT(handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState)));
	connect(media_player, SIGNAL(trackInfoChanged(QVariantMap)), SLOT(trackInfoChanged()));
	connect(media_player, SIGNAL(currentSourceChanged(QString)), SIGNAL(trackNameChanged()));
	connect(media_player, SIGNAL(volumeChanged(int)), SIGNAL(volumeChanged()));
	connect(media_player, SIGNAL(muteChanged(bool)), SIGNAL(muteChanged()));

	connect(this, SIGNAL(currentChanged()), SLOT(play()));
}

void AudioVideoPlayer::prevTrack()
{
	user_track_change_request = true;
	previous();
}

void AudioVideoPlayer::nextTrack()
{
	user_track_change_request = true;
	next();
}

void AudioVideoPlayer::pause()
{
	media_player->pause();
}

void AudioVideoPlayer::resume()
{
	media_player->resume();
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
		next();
	user_track_change_request = false;
}

void AudioVideoPlayer::play()
{
	user_track_change_request = true;
	media_player->setCurrentSource(getCurrent());
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

	int p = 100 * current / total;
	if (percentage != p)
	{
		percentage = p;
		emit percentageChanged();
	}
}
