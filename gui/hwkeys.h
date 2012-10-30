#ifndef HWKEYS_H
#define HWKEYS_H

#include <QObject>


class HwKeys : public QObject
{
	Q_OBJECT

public:
	HwKeys(QObject *parent = 0);
	~HwKeys();

signals:
	void pressed(int index);
	void released(int index);

private slots:
	void handleKeyEvent();

private:
	int handle;
};

#endif // HWKEYS_H
