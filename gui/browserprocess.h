#ifndef BROWSERPROCESS_H
#define BROWSERPROCESS_H

#include <QObject>

class QProcess;


class BrowserProcess : public QObject
{
	Q_OBJECT

	Q_PROPERTY(bool visible READ getVisible WRITE setVisible NOTIFY visibleChanged)

public:
	BrowserProcess(QObject *parent = 0);

	Q_INVOKABLE void displayUrl(QString url);

	void setVisible(bool visible);
	bool getVisible() const;

signals:
	void visibleChanged();
	void clicked();

private slots:
	void terminated();
	void readStatusUpdate();

private:
	void startProcess();
	void sendCommand(QString command);
	void updateVisible(bool visible);

	bool visible;
	QProcess *browser;
};

#endif // BROWSERPROCESS_H
