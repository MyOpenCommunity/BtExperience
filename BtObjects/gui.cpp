#include "gui.h"

#include <QDebug>
#include <QDateTime>
#include <QDate>
#include <QTime>


GuiSettings::GuiSettings()
{
	// TODO read values from somewhere or implement something valueReceived-like
	autoUpdate = true;
	currency = EUR;
	date = QDate::currentDate().toString(QString("dd/MM/yyyy"));
	summerTime = true;
	keyboardLayout = "";
	language = Italian;
	measurementSystem = Metric;
	numberSeparators = Dot_Comma;
	screensaverImage = QString("");
	screensaverText = QString(tr("change text"));
	screensaverType = None;
	temperatureUnit = Celsius;
	time = QTime::currentTime().toString((QString("hh:mm")));
	timeFormat = TimeFormat_24h;
	timeOut = Minutes_10;
	timezone = 0;
	turnOffTime = Minutes_10;
}

bool GuiSettings::getAutoUpdate() const
{
	return autoUpdate;
}

void GuiSettings::setAutoUpdate(bool v)
{
	// TODO save value somewhere
	autoUpdate = v;
	emit autoUpdateChanged();
}

GuiSettings::Currency GuiSettings::getCurrency() const
{
	return currency;
}

void GuiSettings::setCurrency(Currency c)
{
	// TODO save value somewhere
	currency = c;
	emit currencyChanged();
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

bool GuiSettings::getSummerTime() const
{
	return summerTime;
}

void GuiSettings::setSummerTime(bool d)
{
	// TODO save value somewhere
	summerTime = d;
	emit summerTimeChanged();
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

QString GuiSettings::getKeyboardLayout() const
{
	return keyboardLayout;
}

void GuiSettings::setKeyboardLayout(QString l)
{
	// TODO save value somewhere
	keyboardLayout = l;
	emit keyboardLayoutChanged();
}

GuiSettings::Language GuiSettings::getLanguage() const
{
	return language;
}

void GuiSettings::setLanguage(Language l)
{
	// TODO save value somewhere
	language = l;
	emit languageChanged();
}

GuiSettings::MeasurementSystem GuiSettings::getMeasurementSystem() const
{
	return measurementSystem;
}

void GuiSettings::setMeasurementSystem(MeasurementSystem m)
{
	// TODO save value somewhere
	measurementSystem = m;
	emit measurementSystemChanged();
}

GuiSettings::NumberSeparators GuiSettings::getNumberSeparators() const
{
	return numberSeparators;
}

void GuiSettings::setNumberSeparators(NumberSeparators s)
{
	// TODO save value somewhere
	numberSeparators = s;
	emit numberSeparatorsChanged();
}

QString GuiSettings::getScreensaverImage() const
{
	return screensaverImage;
}

void GuiSettings::setScreensaverImage(QString i)
{
	// TODO save value somewhere
	screensaverImage = i;
	emit screensaverImageChanged();
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

GuiSettings::TemperatureUnit GuiSettings::getTemperatureUnit() const
{
	return temperatureUnit;
}

void GuiSettings::setTemperatureUnit(TemperatureUnit u)
{
	// TODO save value somewhere
	temperatureUnit = u;
	emit temperatureUnitChanged();
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
