#include "guisettings.h"

#include <QDebug>
#include <QDateTime>
#include <QDate>
#include <QTime>

#include <limits>

GuiSettings::GuiSettings(QObject *parent) :
	QObject(parent)
{
	// TODO read values from somewhere or implement something valueReceived-like
	brightness = 50;
	contrast = 50;
	currency = EUR;
	keyboardLayout = "";
	language = Italian;
	measurementSystem = Metric;
	numberSeparators = Dot_Comma;
	temperatureUnit = Celsius;
	timeFormat = TimeFormat_24h;
	timezone = 0;
	turnOffTime = Minutes_10;
	skin = Clear;
	beep = false;
}

void GuiSettings::sendCommand(const QString &cmd)
{
	// TODO: add error check
	qDebug() << QString("GuiSettings::sendCommand(%1)").arg(cmd);
	system(qPrintable(cmd));
}

QString GuiSettings::getLanguageString() const
{
	switch(language)
	{
	case English:
		return QString("en");
	case Italian:
		return QString("it");
	default:
		return QString("it");
	}
}

QString GuiSettings::getSkinString() const
{
	switch(skin)
	{
	case Clear:
		return QString("clear");
	case Dark:
		return QString("dark");
	default:
		return QString("clear");
	}
}

int GuiSettings::getBrightness() const
{
	return brightness;
}

void GuiSettings::setBrightness(int b)
{
	if (brightness == b)
		return;

	qDebug() << QString("GuiSettings::setBrightness(%1)").arg(b);
	// TODO: perform the proper conversion
	sendCommand(QString("i2cset -y 1 0x4a 0xf0 0x") + QString::number(b, 16));
	sendCommand(QString("i2cset -y 1 0x4a 0xf9 0x") + QString::number(b, 16));
	// TODO save value somewhere
	brightness = b;
	emit brightnessChanged();
}

int GuiSettings::getContrast() const
{
	return contrast;
}

void GuiSettings::setContrast(int c)
{
	if (contrast == c)
		return;

	qDebug() << QString("GuiSettings::setContrast(%1)").arg(c);
	// TODO save value somewhere
	contrast = c;
	emit contrastChanged();
}

GuiSettings::Currency GuiSettings::getCurrency() const
{
	return currency;
}

void GuiSettings::setCurrency(Currency c)
{
	if (currency == c)
		return;

	// TODO save value somewhere
	currency = c;
	emit currencyChanged();
}

GuiSettings::TimeFormat GuiSettings::getFormat() const
{
	return timeFormat;
}

void GuiSettings::setFormat(TimeFormat f)
{
	if (timeFormat == f)
		return;

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
	if (keyboardLayout == l)
		return;

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
	if (language == l)
		return;

	// TODO save value somewhere
	language = l;
	emit languageChanged();
}

GuiSettings::Skin GuiSettings::getSkin() const
{
	return skin;
}

void GuiSettings::setSkin(Skin s)
{
	if (skin == s)
		return;

	// TODO save value somewhere
	skin = s;
	emit skinChanged();
}

bool GuiSettings::getBeep() const
{
	return beep;
}

void GuiSettings::setBeep(bool b)
{
	if (beep == b)
		return;

	beep = b;
	emit beepChanged();
}

GuiSettings::MeasurementSystem GuiSettings::getMeasurementSystem() const
{
	return measurementSystem;
}

void GuiSettings::setMeasurementSystem(MeasurementSystem m)
{
	if (measurementSystem == m)
		return;

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
	if (numberSeparators == s)
		return;

	// TODO save value somewhere
	numberSeparators = s;
	emit numberSeparatorsChanged();
}

GuiSettings::TemperatureUnit GuiSettings::getTemperatureUnit() const
{
	return temperatureUnit;
}

void GuiSettings::setTemperatureUnit(TemperatureUnit u)
{
	if (temperatureUnit == u)
		return;

	// TODO save value somewhere
	temperatureUnit = u;
	emit temperatureUnitChanged();
}

int GuiSettings::getTimezone() const
{
	return timezone;
}

void GuiSettings::setTimezone(int z)
{
	if (timezone == z)
		return;

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
	if (turnOffTime == tc)
		return;

	// TODO save value somewhere
	turnOffTime = tc;
	emit turnOffTimeChanged();
}
