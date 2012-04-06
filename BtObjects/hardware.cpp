#include "hardware.h"

#include <QDebug>


HardwareSettings::HardwareSettings()
{
	// TODO read values from somewhere or implement something valueReceived-like
	autoUpdate = true;
	date = QDate::currentDate();
	summerTime = false;
	time = QTime::currentTime();
}

void HardwareSettings::sendCommand(const QString &cmd)
{
	// TODO: add error check
	qDebug() << QString("HardwareSettings::sendCommand(%1)").arg(cmd);
	system(qPrintable(cmd));
}

bool HardwareSettings::getAutoUpdate() const
{
	return autoUpdate;
}

void HardwareSettings::setAutoUpdate(bool v)
{
	// TODO save value somewhere
	autoUpdate = v;
	emit autoUpdateChanged();
}

QDate HardwareSettings::getDate() const
{
	return date;
}

void HardwareSettings::setDate(QDate d)
{
	// TODO save value somewhere
	date = d;
	emit dateChanged();
}

bool HardwareSettings::getSummerTime() const
{
	return summerTime;
}

void HardwareSettings::setSummerTime(bool d)
{
	// TODO save value somewhere
	summerTime = d;
	emit summerTimeChanged();
}

QTime HardwareSettings::getTime() const
{
	return time;
}

void HardwareSettings::setTime(QTime t)
{
	// TODO save value somewhere
	time = t;
	emit timeChanged();
}
