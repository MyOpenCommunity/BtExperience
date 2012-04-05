#ifndef GLOBALPROPERTIES_H
#define GLOBALPROPERTIES_H

#include <QObject>
#include <QDateTime>
#include <QRect>
#include <QImage>

class QDeclarativeView;
class InputContextWrapper;

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
	// The base path for the QML application. It is used for import path, for example.
	Q_PROPERTY(QString basePath READ getBasePath CONSTANT)

public:
	GlobalProperties();
	int getMainWidth() const;
	int getMainHeight() const;
	int getLastTimePress() const;
	QObject *getInputWrapper() const;
	QString getBasePath() const;

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
};


#endif // GLOBALPROPERTIES_H
