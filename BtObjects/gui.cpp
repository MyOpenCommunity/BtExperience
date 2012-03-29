#include "gui.h"

#include <QDebug>


GuiSettings::GuiSettings()
{
	// TODO read values from somewhere or implement something valueReceived-like
	screensaverText = QString(tr("change text"));
	screensaverType = None;
	timeOut = Minutes_10;
	turnOffTime = Minutes_10;
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
