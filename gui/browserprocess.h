#ifndef BROWSERPROCESS_H
#define BROWSERPROCESS_H

#include <QObject>

class QProcess;


class BrowserProcess : public QObject
{
	Q_OBJECT

public:
	BrowserProcess(QObject *parent = 0);

	Q_INVOKABLE void start(QString url);

signals:
	void terminated();

private:
	QProcess *browser;
};

#endif // BROWSERPROCESS_H
