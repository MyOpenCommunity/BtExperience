#ifndef PLAYLISTPLAYER_H
#define PLAYLISTPLAYER_H

#include "multimediaplayer.h"

#include <QTime>

class DirectoryListModel;
class UPnPListModel;
class ListManager;


/*!
	\brief A common ancestor for players. Contains logic for playlist management.
*/
class PlayListPlayer : public QObject
{
	Q_OBJECT

	/*!
		\brief Returns if the player is playing.
	*/
	Q_PROPERTY(bool playing READ isPlaying NOTIFY playingChanged)

public:
	// as stated in documentation, it is possible to overload invokable methods
	// to be used in QML with same name, but different arguments; of course it
	// turned out to be a urban tale, so I changed names to be different: pay
	// attention when using them in QML code
	Q_INVOKABLE void generatePlaylistLocal(DirectoryListModel *model, int index, int total_files, bool is_video);
	Q_INVOKABLE void generatePlaylistUPnP(UPnPListModel *model, int index, int total_files, bool is_video);
	Q_INVOKABLE void generatePlaylistWebRadio(QList<QVariant> urls, int index, int total_files);
	// methods needed to restore state when coming back to player page
	Q_INVOKABLE bool isUpnp() const { return ((actual_list == upnp_list) ? true : false); }

	bool isPlaying();

public slots:
	virtual void terminate() { }

protected:
	explicit PlayListPlayer(QObject *parent = 0);

	QString getCurrent() const { return current; }
	void previous();
	void next();
	void generate(DirectoryListModel *model, int index, int total_files);
	void generate(UPnPListModel *model, int index, int total_files);
	void generate(QList<QVariant> urls, int index, int total_files);
	void reset();

signals:
	void currentChanged();
	void playingChanged();
	void loopDetected();

	/// emitted when player is active and the device for current file gets unmounted
	void deviceUnmounted();

protected slots:
	virtual void updateCurrent();

protected:
	bool checkLoop();
	void resetLoopCheck();

private slots:
	void directoryUnmounted(QString dir);

private:
	ListManager *local_list, *upnp_list, *actual_list;
	QString current;
	bool is_video;

	int loop_starting_file; // the index of the song used to detect loop
	int loop_total_time; // the total time used to detect a loop
	QTime loop_time_counter; // used to count the time elapsed
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
	Q_PROPERTY(double percentage READ getPercentage NOTIFY percentageChanged)

	/*!
		\brief Set and/or get if player is muted or not
	*/
	Q_PROPERTY(bool mute READ getMute WRITE setMute NOTIFY muteChanged)

	/*!
		\brief Is player playing anything?
	*/
	Q_PROPERTY(bool playing READ getPlaying NOTIFY playingChanged)

public:
	explicit AudioVideoPlayer(QObject *parent = 0);

	QObject *getMediaPlayer() const { return media_player; }
	QString getCurrentTime() const;
	QString getTotalTime() const;
	QString getTrackName() const;
	int getVolume() const;
	void setVolume(int newValue);
	double getPercentage() const { return percentage; }
	bool getMute() const;
	void setMute(bool newValue);
	bool getPlaying() const;

public slots:
	void prevTrack();
	void nextTrack();
	void pause();
	void resume();
	virtual void terminate();
	void incrementVolume();
	void decrementVolume();

signals:
	void currentTimeChanged();
	void totalTimeChanged();
	void trackNameChanged();
	void volumeChanged();
	void percentageChanged();
	void muteChanged();
	void playingChanged();

private slots:
	void handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state);
	void play();
	void trackInfoChanged();

private:
	QString getTimeString(const QVariant &value) const;

	MultiMediaPlayer *media_player;
	bool user_track_change_request;
	double percentage;
	QVariant current_time_s, total_time_s;
};

#endif // PLAYLISTPLAYER_H
