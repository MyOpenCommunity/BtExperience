#include "audiovideoplayer.h"
#include "folderlistmodel.h"
#include "list_manager.h"

#include <QDebug>
#include <QTime>


AudioVideoPlayer::AudioVideoPlayer(QObject *parent) :
	QObject(parent)
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

	play_list = new FileListManager;
	connect(play_list, SIGNAL(currentFileChanged()), SLOT(playListTrackChanged()));
}

QObject *AudioVideoPlayer::getMediaPlayer() const
{
	return media_player;
}

void AudioVideoPlayer::generatePlaylist(DirectoryListModel *model, int index)
{
	FileObject *file = static_cast<FileObject *>(model->getObject(index));

	EntryInfoList entry_list;
	for (int i = 0; i < model->getCount(); ++i)
	{
		FileObject *fo = static_cast<FileObject *>(model->getObject(i));
		if (file->getFileType() == fo->getFileType())
			entry_list << fo->getEntryInfo();
	}

	FileListManager *list = static_cast<FileListManager *>(play_list);
	list->setList(entry_list);
	list->setCurrentIndex(index);
	play(file->getPath());
}

void AudioVideoPlayer::prevTrack()
{
	user_track_change_request = true;
	play_list->previousFile();
}

void AudioVideoPlayer::nextTrack()
{
	user_track_change_request = true;
	play_list->nextFile();
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
		play_list->nextFile();
	user_track_change_request = false;
}

void AudioVideoPlayer::playListTrackChanged()
{
	if (play_list->currentFilePath().isEmpty())
	{
		// nothing to play
		return;
	}
	play(play_list->currentFilePath());
}

void AudioVideoPlayer::play(const QString &file_path)
{
	user_track_change_request = true;
	media_player->setCurrentSource(file_path);
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
