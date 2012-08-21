#include "audiovideoplayer.h"
#include "folderlistmodel.h"

#include <QDebug>


AudioVideoPlayer::AudioVideoPlayer(QObject *parent) :
	QObject(parent)
{
	user_track_change_request = false;
	media_player = new MultiMediaPlayer();
	connect(media_player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		SLOT(handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState)));
}

QObject *AudioVideoPlayer::getMediaPlayer() const
{
	return media_player;
}

void AudioVideoPlayer::generatePlaylist(DirectoryListModel *model, int index)
{
	// TODO temp implementation: this code must go into play method
	user_track_change_request = true;
	FileObject *fo = static_cast<FileObject *>(model->getObject(index));
	media_player->setCurrentSource(fo->getPath());
	if (media_player->getPlayerState() == MultiMediaPlayer::Stopped)
		media_player->play();
}

void AudioVideoPlayer::handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state)
{
	// TODO to be done
	user_track_change_request = false;
}
