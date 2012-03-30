#include "gui.h"

#include <QDebug>
#include <QDateTime>
#include <QDate>
#include <QTime>


GuiSettings::GuiSettings()
{
	// TODO read values from somewhere or implement something valueReceived-like
	autoUpdate = AutoUpdate_enabled;
	date = QDate::currentDate().toString(QString("dd/MM/yyyy"));
	dst = Dst_enabled;
	screensaverText = QString(tr("change text"));
	screensaverType = None;
	time = QTime::currentTime().toString((QString("hh:mm")));
	timeFormat = TimeFormat_24h;
	timeOut = Minutes_10;
	timezone = 0;
	turnOffTime = Minutes_10;
}

GuiSettings::AutoUpdate GuiSettings::getAutoUpdate() const
{
	return autoUpdate;
}

void GuiSettings::setAutoUpdate(AutoUpdate v)
{
	// TODO save value somewhere
	autoUpdate = v;
	emit autoUpdateChanged();
}

QString GuiSettings::getDate() const
{
	return date;
}

void GuiSettings::setDate(QString d)
{
	// TODO save value somewhere
	date = d;
	emit dateChanged();
}

GuiSettings::DaylightSavingTime GuiSettings::getDst() const
{
	return dst;
}

void GuiSettings::setDst(DaylightSavingTime d)
{
	// TODO save value somewhere
	dst = d;
	emit dstChanged();
}

GuiSettings::TimeFormat GuiSettings::getFormat() const
{
	return timeFormat;
}

void GuiSettings::setFormat(TimeFormat f)
{
	// TODO save value somewhere
	timeFormat = f;
	emit formatChanged();
}

QString GuiSettings::getScreensaverText() const
{
	return screensaverText;
}

void GuiSettings::setScreensaverText(QString t)
{
	// TODO save value somewhere
	screensaverText = t;
	emit screensaverTextChanged();
}

GuiSettings::ScreensaverType GuiSettings::getScreensaverType() const
{
	return screensaverType;
}

void GuiSettings::setScreensaverType(ScreensaverType st)
{
	// TODO save value somewhere
	screensaverType = st;
	emit screensaverTypeChanged();
}

QString GuiSettings::getTime() const
{
	return time;
}

void GuiSettings::setTime(QString t)
{
	// TODO save value somewhere
	time = t;
	emit timeChanged();
}

GuiSettings::TimeChoice GuiSettings::getTimeOut() const
{
	return timeOut;
}

void GuiSettings::setTimeOut(TimeChoice tc)
{
	// TODO save value somewhere
	timeOut = tc;
	emit timeOutChanged();
}

int GuiSettings::getTimezone() const
{
	return timezone;
}

void GuiSettings::setTimezone(int z)
{
	// TODO save value somewhere
	timezone = z;
	emit timezoneChanged();
}

GuiSettings::TimeChoice GuiSettings::getTurnOffTime() const
{
	return turnOffTime;
}

void GuiSettings::setTurnOffTime(TimeChoice tc)
{
	// TODO save value somewhere
	turnOffTime = tc;
	emit turnOffTimeChanged();
}
