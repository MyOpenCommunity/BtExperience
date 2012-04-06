#include "hardware.h"

#include <QDebug>
#include <QDateTime>


HardwareSettings::HardwareSettings()
{
	// TODO read values from somewhere or implement something valueReceived-like
	autoUpdate = true;
	date = QDateTime::currentDateTime().toString("dd/MM/yyyy");
	summerTime = false;
	time = QDateTime::currentDateTime().toString("hh:mm");
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

QString HardwareSettings::getDate() const
{
	return date;
}

void HardwareSettings::setDate(QString d)
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

QString HardwareSettings::getTime() const
{
	return time;
}

void HardwareSettings::setTime(QString t)
{
	// TODO save value somewhere
	time = t;
	emit timeChanged();
}
