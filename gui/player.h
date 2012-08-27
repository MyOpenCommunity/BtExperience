#ifndef PLAYER_H
#define PLAYER_H


#include "multimediaplayer.h"

class DirectoryListModel;
class UPnPListModel;
class ListManager;


/*!
	\brief A common ancestor for players. Contains logic for playlist management.
*/
class PlayListPlayer : public QObject
{
	Q_OBJECT

protected:
	explicit PlayListPlayer(QObject *parent = 0);

	QString getCurrent() const { return current; }
	void previous();
	void next();
	void generate(DirectoryListModel *model, int index, int total_files);
	void generate(UPnPListModel *model, int index, int total_files);

signals:
	void currentChanged();

protected slots:
	virtual void updateCurrent();

private:
	ListManager *local_list, *upnp_list, *actual_list;
	QString current;
};

/*!
	\brief A model to encapsulate logic for photo player
*/
class PhotoPlayer : public PlayListPlayer
{
	Q_OBJECT

	/*!
		\brief The name of the image file to be rendered in QML
	*/
	Q_PROPERTY(QString fileName READ getCurrent NOTIFY fileNameChanged)

public:
	explicit PhotoPlayer(QObject *parent = 0);

	Q_INVOKABLE void generatePlaylist(DirectoryListModel *model, int index, int total_files);
	Q_INVOKABLE void generatePlaylist(UPnPListModel *model, int index, int total_files);
	Q_INVOKABLE void prevPhoto();
	Q_INVOKABLE void nextPhoto();

signals:
	// the following is needed because I didn't manage to compile if using currentChanged directly
	void fileNameChanged();
};

/*!
	\brief A model to interface with MPlayer for audio and video players
*/
class AudioVideoPlayer : public PlayListPlayer
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

	// as stated in documentation, it is possible to overload invokable methods
	// to be used in QML with same name, but different arguments; of course it
	// turned out to be a urban tale, so I changed names to be different: pay
	// attention when using them in QML code
	Q_INVOKABLE void generatePlaylistLocal(DirectoryListModel *model, int index, int total_files);
	Q_INVOKABLE void generatePlaylistUPnP(UPnPListModel *model, int index, int total_files);
	Q_INVOKABLE void prevTrack();
	Q_INVOKABLE void nextTrack();
	Q_INVOKABLE void terminate();
	Q_INVOKABLE void incrementVolume();
	Q_INVOKABLE void decrementVolume();

	QObject *getMediaPlayer() const { return media_player; }
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
	void play();
	void trackInfoChanged();

private:
	QString getTimeString(const QVariant &value) const;

	MultiMediaPlayer *media_player;
	bool user_track_change_request;
	int volume, percentage;
	QVariant current_time_s, total_time_s;
	bool mute;
};

#endif // PLAYER_H
