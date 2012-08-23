#ifndef AUDIOVIDEOPLAYER_H
#define AUDIOVIDEOPLAYER_H


#include "multimediaplayer.h"

class DirectoryListModel;
class ListManager;


/*!
	\brief A model to interface with MPlayer for audio and video players
*/
class AudioVideoPlayer : public QObject
{
	Q_OBJECT

	/*!
		\brief A reference to the media player object
	*/
	Q_PROPERTY(QObject *mediaPlayer READ getMediaPlayer CONSTANT)

	/*!
		\brief Returns current time in hh:mm:ss format
	*/
	Q_PROPERTY(QString currentTime READ getCurrentTime NOTIFY currentTimeChanged)

	/*!
		\brief Returns total time in hh:mm:ss format
	*/
	Q_PROPERTY(QString totalTime READ getTotalTime NOTIFY totalTimeChanged)

	/*!
		\brief Returns actual track name
	*/
	Q_PROPERTY(QString trackName READ getTrackName NOTIFY trackNameChanged)

	/*!
		\brief Set and/or get volume of player (it must be between 0 and 100)
	*/
	Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)

public:
	explicit AudioVideoPlayer(QObject *parent = 0);

	Q_INVOKABLE void generatePlaylist(DirectoryListModel *model, int index);
	Q_INVOKABLE void prevTrack();
	Q_INVOKABLE void nextTrack();
	Q_INVOKABLE void terminate();
	Q_INVOKABLE void incrementVolume();
	Q_INVOKABLE void decrementVolume();

	QObject *getMediaPlayer() const;
	QString getCurrentTime() const;
	QString getTotalTime() const;
	QString getTrackName() const;
	int getVolume() const { return volume; }
	void setVolume(int newValue);

signals:
	void currentTimeChanged();
	void totalTimeChanged();
	void trackNameChanged();
	void volumeChanged();

private slots:
	void handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state);
	void playListTrackChanged();

private:
	QString getTimeString(const QString &key) const;
	void play(const QString &file_path);

	MultiMediaPlayer *media_player;
	ListManager *play_list;
	bool user_track_change_request;
	int volume;
};

#endif // AUDIOVIDEOPLAYER_H
