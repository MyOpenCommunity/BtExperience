#include "player.h"
#include "folderlistmodel.h"
#include "list_manager.h"

#include <QDebug>
#include <QTime>


PlayListPlayer::PlayListPlayer(QObject *parent) :
	QObject(parent)
{
	play_list = new FileListManager;
	connect(play_list, SIGNAL(currentFileChanged()), SLOT(updateCurrent()));
}

void PlayListPlayer::previous()
{
	play_list->previousFile();
}

void PlayListPlayer::next()
{
	play_list->nextFile();
}

void PlayListPlayer::generate(DirectoryListModel *model, int index)
{
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
	}

	// saves retrieved data in internal play_list and seeks to actual selected file
	FileListManager *list = static_cast<FileListManager *>(play_list);
	list->setList(entry_list);
	list->setCurrentIndex(index);

	// restores range (model belongs to QML!)
	model->setRange(oldRange);

	// updates reference to current (emits currentChanged)
	updateCurrent();
}

void PlayListPlayer::updateCurrent()
{
	QString candidate = play_list->currentFilePath();
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

void PhotoPlayer::generatePlaylist(DirectoryListModel *model, int index)
{
	generate(model, index);
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
	volume = 100;
	mute = false;
	current_time_s = total_time_s = percentage = 0;

	media_player = new MultiMediaPlayer();
	connect(media_player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
			SLOT(handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState)));
	connect(media_player, SIGNAL(trackInfoChanged(QVariantMap)), SLOT(trackInfoChanged()));
	connect(media_player, SIGNAL(currentSourceChanged(QString)), SIGNAL(trackNameChanged()));

	connect(this, SIGNAL(currentChanged()), SLOT(play()));
}

void AudioVideoPlayer::generatePlaylist(DirectoryListModel *model, int index)
{
	generate(model, index);
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

void AudioVideoPlayer::terminate()
{
	user_track_change_request = true;
	media_player->stop();
}

void AudioVideoPlayer::setVolume(int newValue)
{
	if (volume == newValue || newValue < 0 || newValue > 100)
		return; // nothing to do

	// TODO set new volume value on device
	volume = newValue;
	emit volumeChanged();
}

void AudioVideoPlayer::setMute(bool newValue)
{
	if (mute == newValue)
		return; // nothing to do

	// TODO mute/unmute the device
	mute = newValue;
	emit muteChanged();
}

void AudioVideoPlayer::incrementVolume()
{
	setMute(false);
	setVolume(getVolume() + 1);
}

void AudioVideoPlayer::decrementVolume()
{
	setMute(false);
	setVolume(getVolume() - 1);
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
	int current = 0;

	if (track_info.contains("total_time"))
	{
		QVariant t = track_info["total_time"];
		QTime v = t.toTime();
		if (v.isValid())
		{
			if (total_time_s != t)
			{
				total_time_s = t;
				emit totalTimeChanged();
			}
			total = v.second() + 60 * v.minute() + 60 * 60 * v.hour();
		}
	}

	if (track_info.contains("current_time"))
	{
		QVariant c = track_info["current_time"];
		QTime v = c.toTime();
		if (v.isValid())
		{
			if (current_time_s != c)
			{
				current_time_s = c;
				emit currentTimeChanged();
			}
			current = v.second() + 60 * v.minute() + 60 * 60 * v.hour();
		}
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
