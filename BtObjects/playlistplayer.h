#ifndef PLAYLISTPLAYER_H
#define PLAYLISTPLAYER_H

#include "multimediaplayer.h"

#include <QTime>

class DirectoryListModel;
class FolderListModelMemento;
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
	Q_INVOKABLE void generatePlaylistWebRadio(QList<QObject *> items, int index, int total_files);

	Q_INVOKABLE bool matchesSavedState(bool is_upnp, QVariantList root_path) const;
	Q_INVOKABLE void restoreLocalState(DirectoryListModel *model);
	Q_INVOKABLE void restoreUpnpState(UPnPListModel *model);

	Q_INVOKABLE bool isWebRadio() const { return !local_state && !upnp_state; }

	// methods needed to restore state when coming back to player page
	Q_INVOKABLE bool isUpnp() const { return ((actual_list == upnp_list) ? true : false); }

	virtual bool isPlaying() const;

public slots:
	virtual void terminate() { }

protected:
	explicit PlayListPlayer(QObject *parent = 0);
	~PlayListPlayer();

	QString getCurrent() const { return current; }
	QString getCurrentName() const { return current_name; }
	void previous();
	void next();
	void generate(DirectoryListModel *model, int index, int total_files);
	void generate(UPnPListModel *model, int index, int total_files);
	void generate(QList<QObject *> items, int index, int total_files);
	void reset();

signals:
	void currentChanged();
	void playingChanged();
	void loopDetected();

	/// emitted when player is active and the device for current file gets unmounted
	void deviceUnmounted();

protected slots:
	virtual void updateCurrent();
	virtual void updateCurrentLocal();
	virtual void updateCurrentUpnp();

protected:
	bool checkLoop();
	void resetLoopCheck();

private slots:
	void directoryUnmounted(QString dir);

private:
	void clearListState();

	ListManager *local_list, *upnp_list, *actual_list;
	FolderListModelMemento *local_state, *upnp_state;
	QString current, current_name;
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

public slots:
	virtual void terminate();

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
		\brief Set and get bounding box for video playback
	*/
	Q_PROPERTY(QRect videoRect READ getVideoRect WRITE setVideoRect NOTIFY videoRectChanged)

	/*!
		\brief True if the player is stopped, false if playing or paused.
	*/
	Q_PROPERTY(bool stopped READ isStopped NOTIFY stoppedChanged)

	Q_PROPERTY(QVariantMap trackInformation READ getTrackInformation NOTIFY trackInformationChanged)

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
	QRect getVideoRect() const;
	void setVideoRect(QRect newValue);
	virtual bool isPlaying() const;
	bool isStopped() const;
	QVariantMap getTrackInformation() const;
	Q_INVOKABLE void seek(int seconds);

public slots:
	void prevTrack();
	void nextTrack();
	void pause();
	void resume();
	void restart();
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
	void videoRectChanged();
	void stoppedChanged();
	void trackInformationChanged();

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
