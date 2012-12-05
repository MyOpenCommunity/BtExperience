#ifndef GLOBALPROPERTIES_H
#define GLOBALPROPERTIES_H

#include "globalpropertiescommon.h"

#include <QRect>
#include <QImage>
#include <QHash>
#include <QVariantList>

class AudioVideoPlayer;
class PhotoPlayer;
class AudioState;
class ScreenState;
class MultiMediaPlayer;
class SoundPlayer;
class RingtoneManager;
class HwKeys;
class Calibration;
class ExternalPlace;
class BrowserProcess;


// This class is designed to be used as a sigle object that contains all the
// global properties.
class GlobalProperties : public GlobalPropertiesCommon
{
	Q_OBJECT

	// The object to manage MPlayer from QML
	Q_PROPERTY(AudioVideoPlayer *audioVideoPlayer READ getAudioVideoPlayer NOTIFY audioVideoPlayerChanged)
	// The object to manage image lists
	Q_PROPERTY(PhotoPlayer *photoPlayer READ getPhotoPlayer CONSTANT)
	// The object to manage audio/video playback state from QML
	Q_PROPERTY(QObject *audioState READ getAudioState CONSTANT)
	// The object to manage screen state from QML
	Q_PROPERTY(QObject *screenState READ getScreenState CONSTANT)
	// The object to play ringtones from QML
	Q_PROPERTY(QObject *ringtoneManager READ getRingtoneManager CONSTANT)

	Q_PROPERTY(QObject *browser READ getBrowser CONSTANT)

	// Hardware key handler
	Q_PROPERTY(QObject *hardwareKeys READ getHardwareKeys CONSTANT)

	// default external place
	Q_PROPERTY(QObject *defaultExternalPlace READ getDefaultExternalPlace CONSTANT)

	// current password and whether password is enabled or not
	Q_PROPERTY(QString password READ getPassword WRITE setPassword NOTIFY passwordChanged)
	Q_PROPERTY(bool passwordEnabled READ isPasswordEnabled WRITE setPasswordEnabled NOTIFY passwordEnabledChanged)

	// Folder containing stock images
	Q_PROPERTY(QVariantList stockImagesFolder READ getStockImagesFolder CONSTANT)

	// Screen calibration object
	Q_PROPERTY(QObject *calibration READ getCalibration CONSTANT)

public:
	GlobalProperties(logger *log);

	AudioVideoPlayer *getAudioVideoPlayer() const;
	PhotoPlayer *getPhotoPlayer() const;
	QObject *getAudioState() const;
	QObject *getScreenState() const;
	QObject *getRingtoneManager() const;
	QObject *getHardwareKeys() const;
	QObject *getCalibration() const;
	QObject *getBrowser() const;
	QVariantList getStockImagesFolder() const;

	QObject *getDefaultExternalPlace() const;

	Q_INVOKABLE QString takeScreenshot(QRect rect, QString filename);
	Q_INVOKABLE QString saveInCustomDirIfNeeded(QString filename, QString new_filename, QSize size = QSize());

	Q_INVOKABLE void beep();

	Q_INVOKABLE QPoint maxTravelledDistanceOnLastMove() const;

	// this is a separate method because it needs to happen only after
	// configuration file parsing
	Q_INVOKABLE void initAudio();

	void setPassword(QString password);
	QString getPassword() const;

	void setPasswordEnabled(bool enabled);
	bool isPasswordEnabled() const;

public slots:
	void setMaxTravelledDistanceOnLastMove(QPoint pos);

signals:
	void systemTimeChanged();
	void passwordChanged();
	void passwordEnabledChanged();
	void audioVideoPlayerChanged();

private slots:
	void beepChanged();
	void ringtoneChanged(int ringtone, int index);
	void volumeChanged(int state, int volume);
	void screenStateChangedManagement();
	void sendDelayedFrames();

private:
	void parseSettings(logger *log);

	AudioVideoPlayer *video_player;
	PhotoPlayer *photo_player;
	AudioState *audio_state;
	ScreenState *screen_state;
	SoundPlayer *sound_player;
	RingtoneManager *ringtone_manager;
	ExternalPlace *default_external_place;
	BrowserProcess *browser;
	QTimer *delayed_frame_timer;
	HwKeys *hardware_keys;
	Calibration *calibration;
	QPoint max_travelled_distance;
	QString password;
	bool password_enabled;
};

#endif // GLOBALPROPERTIES_H
