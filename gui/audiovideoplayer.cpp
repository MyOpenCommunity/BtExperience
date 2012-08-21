#include "audiovideoplayer.h"
#include "folderlistmodel.h"
#include "list_manager.h"

#include <QDebug>
#include <QTime>


AudioVideoPlayer::AudioVideoPlayer(QObject *parent) :
	QObject(parent)
{
	user_track_change_request = false;
	is_terminating = false;
	media_player = new MultiMediaPlayer();
	connect(media_player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
			SLOT(handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState)));
	connect(media_player, SIGNAL(trackInfoChanged(QVariantMap)), SIGNAL(currentTimeChanged()));
	connect(media_player, SIGNAL(trackInfoChanged(QVariantMap)), SIGNAL(totalTimeChanged()));
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
	is_terminating = true;
	media_player->stop();
}

void AudioVideoPlayer::handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state)
{
	if (new_state == MultiMediaPlayer::Stopped && !user_track_change_request)
		play_list->nextFile();
	user_track_change_request = false;
}

void AudioVideoPlayer::playListTrackChanged()
{
	if (is_terminating)
	{
		is_terminating = false;
		// if I'm terminating the player I don't want to play anything more
		return;
	}
	play(play_list->currentFilePath());
}

QString AudioVideoPlayer::getTimeString(const QString &key) const
{
	QVariantMap track_info = media_player->getTrackInfo();
	if (!track_info.contains(key))
		return "--:--";
	QVariant v = track_info[key];
	QTime t = v.toTime();
	QString format = "ss";
	if (t.minute() > 0 || t.hour() > 0)
	{
		format = "mm:" + format;
		if (t.hour() > 0)
			format = "hh:" + format;
	}
	return t.toString(format);
}

void AudioVideoPlayer::play(const QString &file_path)
{
	user_track_change_request = true;
	media_player->setCurrentSource(file_path);
	if (media_player->getPlayerState() == MultiMediaPlayer::Stopped)
		media_player->play();
}

QString AudioVideoPlayer::getCurrentTime() const
{
	return getTimeString("current_time");
}

QString AudioVideoPlayer::getTotalTime() const
{
	return getTimeString("total_time");
}
