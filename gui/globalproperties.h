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
	// The base path for the QML application. It is used for import path, for example.
	Q_PROPERTY(QString basePath READ getBasePath CONSTANT)
	Q_PROPERTY(QString keyboardLayout READ getKeyboardLayout WRITE setKeyboardLayout CONSTANT)

public:
	GlobalProperties();
	~GlobalProperties();
	int getMainWidth() const;
	int getMainHeight() const;
	int getLastTimePress() const;
	QObject *getInputWrapper() const;
	GuiSettings *getGuiSettings() const;
	QString getBasePath() const;

	void setMainWidget(QDeclarativeView *main_widget);
	Q_INVOKABLE void takeScreenshot(QRect rect, QString filename);

	Q_INVOKABLE void reboot()
	{
		emit requestReboot();
	}

	QString getKeyboardLayout() const;
	void setKeyboardLayout(QString layout);

public slots:
	void updateTime();

signals:
	void lastTimePressChanged();
	void requestReboot();

private slots:
#ifdef BT_MALIIT
	void pluginSettingsReceived(const QList<QSharedPointer<Maliit::PluginSettings> > &settings);
#endif

private:
	InputContextWrapper *wrapper;
	QDeclarativeView *main_widget;
	QDateTime last_press;
	GuiSettings *settings;
#ifdef BT_MALIIT
	Maliit::SettingsManager *maliit_settings;
	QSharedPointer<Maliit::SettingsEntry> keyboard_layout;
	QHash<QString, QString> language_map;
#endif
};


#endif // GLOBALPROPERTIES_H
