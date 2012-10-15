#ifndef GUISETTINGS_H
#define GUISETTINGS_H

#include <QObject>

class GuiSettings : public QObject
{
	Q_OBJECT

	/*!
		\brief Sets or gets the brightness level of the display.
	*/
	Q_PROPERTY(int brightness READ getBrightness WRITE setBrightness NOTIFY brightnessChanged)

	/*!
		\brief Sets or gets the contrast level of the display.
	*/
	Q_PROPERTY(int contrast READ getContrast WRITE setContrast NOTIFY contrastChanged)

	/*!
		\brief Sets or gets the currency.
	*/
	Q_PROPERTY(Currency currency READ getCurrency WRITE setCurrency NOTIFY currencyChanged)

	/*!
		\brief Sets or gets time format as 12h or 24h.
	*/
	Q_PROPERTY(TimeFormat format READ getFormat WRITE setFormat NOTIFY formatChanged)

	/*!
		\brief Sets or gets the keyboard layout.
	*/
	Q_PROPERTY(QString keyboardLayout READ getKeyboardLayout WRITE setKeyboardLayout NOTIFY keyboardLayoutChanged)

	/*!
		\brief Sets or gets the language for the interface.
	*/
	Q_PROPERTY(Language language READ getLanguage WRITE setLanguage NOTIFY languageChanged)

	/*!
		\brief Sets or gets the skin for the interface.
	*/
	Q_PROPERTY(Skin skin READ getSkin WRITE setSkin NOTIFY skinChanged)

	/*!
		\brief Sets or gets the system of measurement.
	*/
	Q_PROPERTY(MeasurementSystem measurementSystem READ getMeasurementSystem WRITE setMeasurementSystem NOTIFY measurementSystemChanged)

	/*!
		\brief Sets or gets the number separators for thousands and between
		integral and fractional part.
	*/
	Q_PROPERTY(NumberSeparators numberSeparators READ getNumberSeparators WRITE setNumberSeparators NOTIFY numberSeparatorsChanged)

	/*!
		\brief Sets or gets the unit used for temperature in Celsius or Fahrenheit.
	*/
	Q_PROPERTY(TemperatureUnit temperatureUnit READ getTemperatureUnit WRITE setTemperatureUnit NOTIFY temperatureUnitChanged)

	/*!
		\brief Sets or gets the timezone.
	*/
	Q_PROPERTY(int timezone READ getTimezone WRITE setTimezone NOTIFY timezoneChanged)
	// TODO use an enum for all managed timezones

	/*!
		\brief Sets or gets the turn off time for the display.
	*/
	Q_PROPERTY(TimeChoice turnOffTime READ getTurnOffTime WRITE setTurnOffTime NOTIFY turnOffTimeChanged)

	/*!
		\brief Sets or gets the beep status.
	*/
	Q_PROPERTY(bool beep READ getBeep WRITE setBeep NOTIFY beepChanged)

	Q_ENUMS(Currency)
	Q_ENUMS(Language)
	Q_ENUMS(MeasurementSystem)
	Q_ENUMS(NumberSeparators)
	Q_ENUMS(TemperatureUnit)
	Q_ENUMS(TimeChoice)
	Q_ENUMS(TimeFormat)
	Q_ENUMS(Skin)

public:
	explicit GuiSettings(QObject *parent = 0);

	enum Currency
	{
		CHF,
		EUR,
		GBP,
		JPY,
		USD
	};

	enum Language
	{
		English,
		Italian
	};

	enum Skin
	{
		Clear,
		Dark
	};

	enum MeasurementSystem
	{
		Metric,
		Imperial
	};

	enum NumberSeparators
	{
		// TODO define meaningful values
		Dot_Comma,
		Comma_Dot
	};

	enum TemperatureUnit
	{
		Celsius,
		Fahrenheit
	};

	enum TimeChoice
	{
		Seconds_15,
		Seconds_30,
		Minutes_1,
		Minutes_2,
		Minutes_5,
		Minutes_10,
		Minutes_30,
		Hours_1,
		Never
	};

	enum TimeFormat
	{
		TimeFormat_12h,
		TimeFormat_24h
	};

	// brightness must be [1, 100]
	int getBrightness() const;
	void setBrightness(int b);
	// contrast must be [1, 100]
	int getContrast() const;
	void setContrast(int c);
	Currency getCurrency() const;
	void setCurrency(Currency c);
	TimeFormat getFormat() const;
	void setFormat(TimeFormat f);
	QString getKeyboardLayout() const;
	void setKeyboardLayout(QString l);
	Language getLanguage() const;
	void setLanguage(Language l);
	MeasurementSystem getMeasurementSystem() const;
	void setMeasurementSystem(MeasurementSystem m);
	NumberSeparators getNumberSeparators() const;
	void setNumberSeparators(NumberSeparators s);
	TemperatureUnit getTemperatureUnit() const;
	void setTemperatureUnit(TemperatureUnit u);
	int getTimezone() const;
	void setTimezone(int z);
	TimeChoice getTurnOffTime() const;
	void setTurnOffTime(TimeChoice tc);
	Skin getSkin() const;
	void setSkin(Skin s);
	bool getBeep() const;
	void setBeep(bool beep);

	QString getLanguageString() const;
	QString getSkinString() const;

signals:
	void brightnessChanged();
	void contrastChanged();
	void currencyChanged();
	void formatChanged();
	void keyboardLayoutChanged();
	void languageChanged();
	void measurementSystemChanged();
	void numberSeparatorsChanged();
	void temperatureUnitChanged();
	void timezoneChanged();
	void turnOffTimeChanged();
	void skinChanged();
	void beepChanged();

private:
	int brightness;
	int contrast;
	Currency currency;
	QString keyboardLayout;
	Language language;
	MeasurementSystem measurementSystem;
	NumberSeparators numberSeparators;
	TemperatureUnit temperatureUnit;
	TimeFormat timeFormat;
	int timezone;
	TimeChoice turnOffTime;
	Skin skin;
	bool beep;

private:
	void sendCommand(const QString &cmd);

};

#endif // GUISETTINGS_H
