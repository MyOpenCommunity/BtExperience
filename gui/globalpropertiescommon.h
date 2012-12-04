#ifndef GLOBALPROPERTIESCOMMON_H
#define GLOBALPROPERTIESCOMMON_H

#include <QObject>
#include <QDateTime>
#include <QStringList>

#ifdef BT_MALIIT
#include <maliit/settingsentry.h>
#endif

class QDeclarativeView;
class ConfigFile;
class DebugTiming;
class GuiSettings;
class InputContextWrapper;
class logger;

#define MAIN_WIDTH 1024
#define MAIN_HEIGHT 600

#ifdef BT_MALIIT
#include <QSharedPointer>

namespace Maliit
{
	class SettingsManager;
	class PluginSettings;
	class SettingsEntry;
}
#endif


class GlobalPropertiesCommon : public QObject
{
	Q_OBJECT

	// The width of the app (equal to the screen width on embedded)
	Q_PROPERTY(int mainWidth READ getMainWidth CONSTANT)

	// The height of the app (equal to the screen height on embedded)
	Q_PROPERTY(int mainHeight READ getMainHeight CONSTANT)

	// The input context wrapper, used to manage the virtual keyboard
	Q_PROPERTY(QObject *inputWrapper READ getInputWrapper CONSTANT)

	// The object to manage the GUI settings
	Q_PROPERTY(GuiSettings *guiSettings READ getGuiSettings CONSTANT)

	// The base path for the QML application. It is used for import path, for example.
	Q_PROPERTY(QString basePath READ getBasePath CONSTANT)

	// The extra path for resources.
	Q_PROPERTY(QString extraPath READ getExtraPath CONSTANT)

	// The keyboard layout for Maliit (es. "en_gb", "fr", ...)
	Q_PROPERTY(QString keyboardLayout READ getKeyboardLayout WRITE setKeyboardLayout NOTIFY keyboardLayoutChanged)

	// The keyboard layout for Maliit (es. "en_gb", "fr", ...)
	Q_PROPERTY(QStringList keyboardLayouts READ getKeyboardLayouts NOTIFY keyboardLayoutsChanged)

	// Debug touchscreen events
	Q_PROPERTY(bool debugTs READ getDebugTs CONSTANT)

	// Debug timing between various GUI events
	Q_PROPERTY(DebugTiming *debugTiming READ getDebugTiming CONSTANT)

public:
	GlobalPropertiesCommon(logger *log);

	int getMainWidth() const;
	int getMainHeight() const;
	QObject *getInputWrapper() const;
	GuiSettings *getGuiSettings() const;
	QString getBasePath() const;
	QString getExtraPath() const;
	bool getDebugTs();
	DebugTiming *getDebugTiming();

	QString getKeyboardLayout() const;
	void setKeyboardLayout(QString layout);

	QStringList getKeyboardLayouts() const;

	void setMainWidget(QDeclarativeView *main_widget);

signals:
	void keyboardLayoutChanged();
	void keyboardLayoutsChanged();

private slots:
#ifdef BT_MALIIT
	void pluginSettingsReceived(const QList<QSharedPointer<Maliit::PluginSettings> > &settings);
#endif

protected:
	ConfigFile *configurations;
	GuiSettings *settings;
	bool debug_touchscreen;
	DebugTiming *debug_timing;
	QDeclarativeView *main_widget;

private:
	InputContextWrapper *wrapper;
	QString keyboard_layout_name;

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

#endif // GLOBALPROPERTIESCOMMON_H
