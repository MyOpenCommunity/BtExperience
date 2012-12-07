#ifndef BROWSERPROCESS_H
#define BROWSERPROCESS_H

#include <QObject>

class QProcess;
class QTimer;


class BrowserProcess : public QObject
{
	Q_OBJECT

	Q_PROPERTY(bool visible READ getVisible WRITE setVisible NOTIFY visibleChanged)

	Q_PROPERTY(bool running READ getRunning NOTIFY runningChanged)

public:
	BrowserProcess(QObject *parent = 0);

	Q_INVOKABLE void displayUrl(QString url);

	void setVisible(bool visible);
	bool getVisible() const;

	bool getRunning() const;

signals:
	void visibleChanged();
	void runningChanged();
	void clicked();

private slots:
	void terminated();
	void readStatusUpdate();
	void processStateChanged();
	void sendKeepAlive();

private:
	void startProcess();
	void sendCommand(QString command);
	void updateVisible(bool visible);

	bool visible;
	int keep_alive_ticks;
	QProcess *browser;
	QTimer *keep_alive;
};

#endif // BROWSERPROCESS_H
