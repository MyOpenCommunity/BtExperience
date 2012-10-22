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
	// The keyboard layout for Maliit (es. "en_gb", "fr", ...)
	Q_PROPERTY(QString keyboardLayout READ getKeyboardLayout WRITE setKeyboardLayout NOTIFY keyboardLayoutChanged)
	// A property to turn off/on the monitor from QML
	Q_PROPERTY(bool monitorOff READ isMonitorOff WRITE setMonitorOff NOTIFY monitorOffChanged)

public:
	GlobalProperties();
	~GlobalProperties();
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

	void setMainWidget(QDeclarativeView *main_widget);
	Q_INVOKABLE void takeScreenshot(QRect rect, QString filename);

	Q_INVOKABLE void reboot()
	{
		emit requestReboot();
	}

	Q_INVOKABLE void beep();

	// this is a separate method because it needs to happen only after
	// configuration file parsing
	Q_INVOKABLE void initAudio();

	QString getKeyboardLayout() const;
	void setKeyboardLayout(QString layout);

public slots:
	void updateTime();

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
	void parseSettings();

	InputContextWrapper *wrapper;
	QDeclarativeView *main_widget;
	QDateTime last_press;
	GuiSettings *settings;
	AudioVideoPlayer *videoPlayer;
	AudioVideoPlayer *audioPlayer;
	PhotoPlayer *photoPlayer;
	AudioState *audio_state;
	SoundPlayer *sound_player;
	RingtoneManager *ringtone_manager;
	QTimer *delayed_frame_timer;
	ConfigFile *configurations;
	bool monitor_off;

#ifdef BT_MALIIT
	void maliitFrameworkSettings(const QSharedPointer<Maliit::PluginSettings> &settings);
	void maliitKeyboardSettings(const QSharedPointer<Maliit::PluginSettings> &settings);

	Maliit::SettingsManager *maliit_settings;
	QSharedPointer<Maliit::SettingsEntry> keyboard_layout;
	QHash<QString, QString> language_map;
#endif
};


#endif // GLOBALPROPERTIES_H
