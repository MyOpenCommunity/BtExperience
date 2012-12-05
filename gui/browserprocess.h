#ifndef BROWSERPROCESS_H
#define BROWSERPROCESS_H

#include <QObject>

class QProcess;


class BrowserProcess : public QObject
{
	Q_OBJECT

public:
	BrowserProcess(QObject *parent = 0);

	Q_INVOKABLE void displayUrl(QString url);

signals:
	void clicked();

private slots:
	void readStatusUpdate();

private:
	void startProcess();
	void sendCommand(QString command);
	void updateVisible(bool visible);

	bool visible;
	QProcess *browser;
};

#endif // BROWSERPROCESS_H
