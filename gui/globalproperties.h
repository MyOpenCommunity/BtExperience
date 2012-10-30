#ifndef GLOBALPROPERTIES_H
#define GLOBALPROPERTIES_H

#include <QObject>
#include <QDateTime>
#include <QRect>
#include <QImage>
#include <QHash>

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
	Q_PROPERTY(AudioVideoPlayer *videoPlayer READ getVideoPlayer CONSTANT)
	// The object to manage MPlayer from QML
	Q_PROPERTY(AudioVideoPlayer *audioPlayer READ getAudioPlayer NOTIFY audioPlayerChanged)
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
	// A property to turn off/on the monitor from QML
	Q_PROPERTY(bool monitorOff READ isMonitorOff WRITE setMonitorOff NOTIFY monitorOffChanged)

	// Hardware key handler
	Q_PROPERTY(HwKeys *hardwareKeys READ getHardwareKeys CONSTANT)

	// Debug touchscreen events
	Q_PROPERTY(bool debugTs READ getDebugTs CONSTANT)

	// Debug timing between various GUI events
	Q_PROPERTY(DebugTiming *debugTiming READ getDebugTiming CONSTANT)


public:
	GlobalProperties(logger *log);
	int getMainWidth() const;
	int getMainHeight() const;
	int getLastTimePress() const;
	QObject *getInputWrapper() const;
	GuiSettings *getGuiSettings() const;
	AudioVideoPlayer *getVideoPlayer() const;
	AudioVideoPlayer *getAudioPlayer() const;
	PhotoPlayer *getPhotoPlayer() const;
	QObject *getAudioState() const;
	QObject *getRingtoneManager() const;
	QString getBasePath() const;
	QString getExtraPath() const;
	bool isMonitorOff() const;
	void setMonitorOff(bool newValue);
	bool getDebugTs();
	DebugTiming *getDebugTiming();
	HwKeys *getHardwareKeys() const;

	void setMainWidget(QDeclarativeView *main_widget);
	Q_INVOKABLE void takeScreenshot(QRect rect, QString filename);

	Q_INVOKABLE void reboot()
	{
		emit requestReboot();
	}

	Q_INVOKABLE void beep();

	Q_INVOKABLE QPoint mouseReleasePosition() const;

	// this is a separate method because it needs to happen only after
	// configuration file parsing
	Q_INVOKABLE void initAudio();

	QString getKeyboardLayout() const;
	void setKeyboardLayout(QString layout);

public slots:
	void updateTime();
	void mouseReleased(QPoint pos);

signals:
	void lastTimePressChanged();
	void requestReboot();
	void keyboardLayoutChanged();
	void audioPlayerChanged();
	void monitorOffChanged();

private slots:
#ifdef BT_MALIIT
	void pluginSettingsReceived(const QList<QSharedPointer<Maliit::PluginSettings> > &settings);
#endif
	void beepChanged();
	void audioStateChangedManagement();
	void sendDelayedFrames();

private:
	void parseSettings(logger *log);

	InputContextWrapper *wrapper;
	QDeclarativeView *main_widget;
	QDateTime last_press;
	GuiSettings *settings;
	AudioVideoPlayer *video_player;
	AudioVideoPlayer *audio_player;
	PhotoPlayer *photo_player;
	AudioState *audio_state;
	SoundPlayer *sound_player;
	RingtoneManager *ringtone_manager;
	QTimer *delayed_frame_timer;
	ConfigFile *configurations;
	bool monitor_off;
	bool debug_touchscreen;
	DebugTiming *debug_timing;
	HwKeys *hardware_keys;
	QPoint mouse_position;

#ifdef BT_MALIIT
	void maliitFrameworkSettings(const QSharedPointer<Maliit::PluginSettings> &settings);
	void maliitKeyboardSettings(const QSharedPointer<Maliit::PluginSettings> &settings);

	Maliit::SettingsManager *maliit_settings;
	QSharedPointer<Maliit::SettingsEntry> keyboard_layout;
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
