#ifndef GLOBALPROPERTIES_H
#define GLOBALPROPERTIES_H

#include <QObject>
#include <QDateTime>
#include <QRect>
#include <QImage>

class QDeclarativeView;
class GuiSettings;
class InputContextWrapper;
class NoteListModel;

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

	// TODO waiting for better implementation
	Q_PROPERTY(NoteListModel *noteListModel READ getNoteListModel CONSTANT)

public:
	GlobalProperties();
	int getMainWidth() const;
	int getMainHeight() const;
	int getLastTimePress() const;
	QObject *getInputWrapper() const;
	GuiSettings *getGuiSettings() const;
	QString getBasePath() const;

	// TODO waiting for better implementation
	NoteListModel *getNoteListModel() const;

	void setMainWidget(QDeclarativeView *main_widget);
	Q_INVOKABLE QImage takeScreenshot(QRect rect = QRect());

	Q_INVOKABLE void reboot()
	{
		emit requestReboot();
	}

public slots:
	void updateTime();

signals:
	void lastTimePressChanged();
	void requestReboot();

private:
	InputContextWrapper *wrapper;
	QDeclarativeView *main_widget;
	QDateTime last_press;
	GuiSettings *settings;

	// TODO waiting for better implementation
	NoteListModel *noteListModel;
};


#endif // GLOBALPROPERTIES_H
