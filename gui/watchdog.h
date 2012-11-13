#ifndef WATCHDOG_H
#define WATCHDOG_H

#include <QObject>
#include <QTimer>


class Watchdog : public QObject
{
	Q_OBJECT

public:
	Watchdog(QObject *parent = 0);

public slots:
	void start(int interval);
	void stop();
	void rearm();

private:
	QTimer timer;
};

#endif // WATCHDOG_H
