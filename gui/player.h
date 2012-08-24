#ifndef PLAYER_H
#define PLAYER_H


#include "multimediaplayer.h"

class DirectoryListModel;
class ListManager;


// TODO do we need a common ancestor?

/*!
	\brief A model to encapsulate logic for photo player
*/
class PhotoPlayer : public QObject
{
	Q_OBJECT

	/*!
		\brief The name of the image file to be rendered in QML
	*/
	Q_PROPERTY(QString fileName READ getFileName NOTIFY fileNameChanged)

public:
	explicit PhotoPlayer(QObject *parent = 0);

	Q_INVOKABLE void generatePlaylist(DirectoryListModel *model, int index);
	Q_INVOKABLE void prevPhoto();
	Q_INVOKABLE void nextPhoto();

	QString getFileName() const { return fileName; }

signals:
	void fileNameChanged();

private slots:
	void playedFileChanged();

private:
	ListManager *play_list;
	QString fileName;
};

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

	/*!
		\brief Get elapsed time in percentage
	*/
	Q_PROPERTY(int percentage READ getPercentage NOTIFY percentageChanged)

	/*!
		\brief Set and/or get if player is muted or not
	*/
	Q_PROPERTY(bool mute READ getMute WRITE setMute NOTIFY muteChanged)

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
	int getPercentage() const { return percentage; }
	bool getMute() const { return mute; }
	void setMute(bool newValue);

signals:
	void currentTimeChanged();
	void totalTimeChanged();
	void trackNameChanged();
	void volumeChanged();
	void percentageChanged();
	void muteChanged();

private slots:
	void handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state);
	void playListTrackChanged();
	void trackInfoChanged();

private:
	QString getTimeString(const QVariant &value) const;
	void play(const QString &file_path);

	MultiMediaPlayer *media_player;
	ListManager *play_list;
	bool user_track_change_request;
	int volume, percentage;
	QVariant current_time_s, total_time_s;
	bool mute;
};

#endif // PLAYER_H
