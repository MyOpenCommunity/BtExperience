#ifndef AUDIOVIDEOPLAYER_H
#define AUDIOVIDEOPLAYER_H


#include "multimediaplayer.h"

class DirectoryListModel;


/*!
	\brief A model to interface with MPlayer for audio and video players
*/
class AudioVideoPlayer : public QObject
{
	Q_OBJECT

	Q_PROPERTY(QObject *mediaPlayer READ getMediaPlayer CONSTANT)

public:
	explicit AudioVideoPlayer(QObject *parent = 0);

	Q_INVOKABLE void generatePlaylist(DirectoryListModel *model, int index);

	QObject *getMediaPlayer() const;

private slots:
	void handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state);

private:
	MultiMediaPlayer *media_player;
	bool user_track_change_request;
};

#endif // AUDIOVIDEOPLAYER_H
