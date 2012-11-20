#ifndef GLOBALPROPERTIES_H
#define GLOBALPROPERTIES_H

#include <QObject>
#include <QDateTime>
#include <QRect>
#include <QImage>
#include <QHash>
#include <QStringList>
#include <QVariantList>

class QDeclarativeView;
class GuiSettings;
class InputContextWrapper;
class AudioVideoPlayer;
class PhotoPlayer;
class AudioState;
class MultiMediaPlayer;
class SoundPlayer;
class RingtoneManager;
class ConfigFile;
class DebugTiming;
class HwKeys;
class ExternalPlace;
class logger;

#ifdef BT_MALIIT
#include <QSharedPointer>

namespace Maliit
{
	class SettingsManager;
	class PluginSettings;
	class SettingsEntry;
}
#endif

#define MAIN_WIDTH 1024
#define MAIN_HEIGHT 600


// This class is designed to be used as a sigle object that contains all the
// global properties.
class GlobalProperties : public QObject
{
	Q_OBJECT
	// The width of the app (equal to the screen width on embedded)
	Q_PROPERTY(int mainWidth READ getMainWidth CONSTANT)
	// The height of the app (equal to the screen height on embedded)
	Q_PROPERTY(int mainHeight READ getMainHeight CONSTANT)
	// The number of seconds since last click
	Q_PROPERTY(int lastTimePress READ getLastTimePress NOTIFY lastTimePressChanged)
	// The input context wrapper, used to manage the virtual keyboard
	Q_PROPERTY(QObject *inputWrapper READ getInputWrapper CONSTANT)
	// The object to manage the GUI settings
	Q_PROPERTY(GuiSettings *guiSettings READ getGuiSettings CONSTANT)
	// The object to manage MPlayer from QML
	Q_PROPERTY(AudioVideoPlayer *audioVideoPlayer READ getAudioVideoPlayer NOTIFY audioVideoPlayerChanged)
	// The object to manage image lists
	Q_PROPERTY(PhotoPlayer *photoPlayer READ getPhotoPlayer CONSTANT)
	// The object to manage audio/video playback state from QML
	Q_PROPERTY(QObject *audioState READ getAudioState CONSTANT)
	// The object to play ringtones from QML
	Q_PROPERTY(QObject *ringtoneManager READ getRingtoneManager CONSTANT)
	// The base path for the QML application. It is used for import path, for example.
	Q_PROPERTY(QString basePath READ getBasePath CONSTANT)
	// The extra path for resources.
	Q_PROPERTY(QString extraPath READ getExtraPath CONSTANT)

	// The keyboard layout for Maliit (es. "en_gb", "fr", ...)
	Q_PROPERTY(QString keyboardLayout READ getKeyboardLayout WRITE setKeyboardLayout NOTIFY keyboardLayoutChanged)

	// The keyboard layout for Maliit (es. "en_gb", "fr", ...)
	Q_PROPERTY(QStringList keyboardLayouts READ getKeyboardLayouts NOTIFY keyboardLayoutsChanged)

	// A property to turn off/on the monitor from QML
	Q_PROPERTY(bool monitorOff READ isMonitorOff WRITE setMonitorOff NOTIFY monitorOffChanged)

	// Hardware key handler
	Q_PROPERTY(QObject *hardwareKeys READ getHardwareKeys CONSTANT)

	// default external place
	Q_PROPERTY(QObject *defaultExternalPlace READ getDefaultExternalPlace CONSTANT)

	// current password and whether password is enabled or not
	Q_PROPERTY(QString password READ getPassword WRITE setPassword NOTIFY passwordChanged)
	Q_PROPERTY(bool passwordEnabled READ isPasswordEnabled WRITE setPasswordEnabled NOTIFY passwordEnabledChanged)

	// Debug touchscreen events
	Q_PROPERTY(bool debugTs READ getDebugTs CONSTANT)

	// Debug timing between various GUI events
	Q_PROPERTY(DebugTiming *debugTiming READ getDebugTiming CONSTANT)

	// Folder containing stock images
	Q_PROPERTY(QVariantList stockImagesFolder READ getStockImagesFolder CONSTANT)

public:
	GlobalProperties(logger *log);
	int getMainWidth() const;
	int getMainHeight() const;
	int getLastTimePress() const;
	QObject *getInputWrapper() const;
	GuiSettings *getGuiSettings() const;
	AudioVideoPlayer *getAudioVideoPlayer() const;
	PhotoPlayer *getPhotoPlayer() const;
	QObject *getAudioState() const;
	QObject *getRingtoneManager() const;
	QString getBasePath() const;
	QString getExtraPath() const;
	bool isMonitorOff() const;
	void setMonitorOff(bool newValue);
	bool getDebugTs();
	DebugTiming *getDebugTiming();
	QObject *getHardwareKeys() const;
	QVariantList getStockImagesFolder() const;

	QObject *getDefaultExternalPlace() const;

	void setMainWidget(QDeclarativeView *main_widget);
	Q_INVOKABLE QString takeScreenshot(QRect rect, QString filename);
	Q_INVOKABLE QString saveInCustomDirIfNeeded(QString filename, QString new_filename, QSize size = QSize());

	Q_INVOKABLE void reboot()
	{
		emit requestReboot();
	}

	Q_INVOKABLE void beep();

	Q_INVOKABLE QPoint maxTravelledDistanceOnLastMove() const;

	// this is a separate method because it needs to happen only after
	// configuration file parsing
	Q_INVOKABLE void initAudio();

	QString getKeyboardLayout() const;
	void setKeyboardLayout(QString layout);

	QStringList getKeyboardLayouts() const;

	void setPassword(QString password);
	QString getPassword() const;

	void setPasswordEnabled(bool enabled);
	bool isPasswordEnabled() const;

public slots:
	void updateTime();
	void setMaxTravelledDistanceOnLastMove(QPoint pos);

signals:
	void lastTimePressChanged();
	void requestReboot();
	void keyboardLayoutChanged();
	void keyboardLayoutsChanged();
	void monitorOffChanged();
	void systemTimeChanged();
	void passwordChanged();
	void passwordEnabledChanged();
	void audioVideoPlayerChanged();

private slots:
#ifdef BT_MALIIT
	void pluginSettingsReceived(const QList<QSharedPointer<Maliit::PluginSettings> > &settings);
#endif
	void beepChanged();
	void ringtoneChanged(int ringtone, int index);
	void volumeChanged(int state, int volume);
	void audioStateChangedManagement();
	void sendDelayedFrames();

private:
	void parseSettings(logger *log);

	InputContextWrapper *wrapper;
	QDeclarativeView *main_widget;
	QDateTime last_press;
	GuiSettings *settings;
	AudioVideoPlayer *video_player;
	PhotoPlayer *photo_player;
	AudioState *audio_state;
	SoundPlayer *sound_player;
	RingtoneManager *ringtone_manager;
	ExternalPlace *default_external_place;
	QTimer *delayed_frame_timer;
	ConfigFile *configurations;
	bool monitor_off;
	bool debug_touchscreen;
	DebugTiming *debug_timing;
	HwKeys *hardware_keys;
	QPoint max_travelled_distance;
	QString password;
	bool password_enabled;

#ifdef BT_MALIIT
	void maliitFrameworkSettings(const QSharedPointer<Maliit::PluginSettings> &settings);
	void maliitKeyboardSettings(const QSharedPointer<Maliit::PluginSettings> &settings);

	Maliit::SettingsManager *maliit_settings;
	QSharedPointer<Maliit::SettingsEntry> keyboard_layout, allowed_layouts;
	QHash<QString, QString> language_map;
#endif
};

class DebugTiming : public QObject
{
	Q_OBJECT
public:
	DebugTiming(logger *log, bool enabled, QObject *parent);
	Q_INVOKABLE void logTiming(const QString &message);

private:
	QTime last_message;
	logger *app_logger;
	bool is_enabled;
};


#endif // GLOBALPROPERTIES_H
