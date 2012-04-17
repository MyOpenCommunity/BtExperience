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
		\brief Sets or gets the system of measurement.
	*/
	Q_PROPERTY(MeasurementSystem measurementSystem READ getMeasurementSystem WRITE setMeasurementSystem NOTIFY measurementSystemChanged)

	/*!
		\brief Sets or gets the number separators for thousands and between
		integral and fractional part.
	*/
	Q_PROPERTY(NumberSeparators numberSeparators READ getNumberSeparators WRITE setNumberSeparators NOTIFY numberSeparatorsChanged)

	/*!
		\brief Sets or gets the image of screensaver in use
	*/
	Q_PROPERTY(QString screensaverImage READ getScreensaverImage WRITE setScreensaverImage NOTIFY screensaverImageChanged)

	/*!
		\brief Sets or gets the text of screensaver in use
	*/
	Q_PROPERTY(QString screensaverText READ getScreensaverText WRITE setScreensaverText NOTIFY screensaverTextChanged)

	/*!
		\brief Sets or gets the type of screensaver in use
	*/
	Q_PROPERTY(ScreensaverType screensaverType READ getScreensaverType WRITE setScreensaverType NOTIFY screensaverTypeChanged)

	/*!
		\brief Sets or gets the unit used for temperature in Celsius or Fahrenheit.
	*/
	Q_PROPERTY(TemperatureUnit temperatureUnit READ getTemperatureUnit WRITE setTemperatureUnit NOTIFY temperatureUnitChanged)

	/*!
		\brief Sets or gets the time out for the screensaver.
	*/
	Q_PROPERTY(TimeChoice timeOut READ getTimeOut WRITE setTimeOut NOTIFY timeOutChanged)

	/*!
		\brief Gets the time out for the screensaver, but in seconds (for QML usage).
	*/
	Q_PROPERTY(int timeOutInSeconds READ getTimeOutInSeconds NOTIFY timeOutChanged)

	/*!
		\brief Sets or gets the timezone.
	*/
	Q_PROPERTY(int timezone READ getTimezone WRITE setTimezone NOTIFY timezoneChanged)
	// TODO use an enum for all managed timezones

	/*!
		\brief Sets or gets the turn off time for the display.
	*/
	Q_PROPERTY(TimeChoice turnOffTime READ getTurnOffTime WRITE setTurnOffTime NOTIFY turnOffTimeChanged)

	Q_ENUMS(Currency)
	Q_ENUMS(Language)
	Q_ENUMS(MeasurementSystem)
	Q_ENUMS(NumberSeparators)
	Q_ENUMS(ScreensaverType)
	Q_ENUMS(TemperatureUnit)
	Q_ENUMS(TimeChoice)
	Q_ENUMS(TimeFormat)

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

	enum ScreensaverType
	{
		None,
		DateTime,
		Text,
		Image
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
	QString getScreensaverImage() const;
	void setScreensaverImage(QString i);
	QString getScreensaverText() const;
	void setScreensaverText(QString t);
	ScreensaverType getScreensaverType() const;
	void setScreensaverType(ScreensaverType st);
	TemperatureUnit getTemperatureUnit() const;
	void setTemperatureUnit(TemperatureUnit u);
	TimeChoice getTimeOut() const;
	void setTimeOut(TimeChoice tc);
	int getTimeOutInSeconds() const;
	int getTimezone() const;
	void setTimezone(int z);
	TimeChoice getTurnOffTime() const;
	void setTurnOffTime(TimeChoice tc);

	QString getLanguageString() const;

signals:
	void brightnessChanged();
	void contrastChanged();
	void currencyChanged();
	void formatChanged();
	void keyboardLayoutChanged();
	void languageChanged();
	void measurementSystemChanged();
	void numberSeparatorsChanged();
	void screensaverImageChanged();
	void screensaverTextChanged();
	void screensaverTypeChanged();
	void temperatureUnitChanged();
	void timeOutChanged();
	void timezoneChanged();
	void turnOffTimeChanged();

protected:
	int brightness;
	int contrast;
	Currency currency;
	QString keyboardLayout;
	Language language;
	MeasurementSystem measurementSystem;
	NumberSeparators numberSeparators;
	QString screensaverImage;
	QString screensaverText;
	ScreensaverType screensaverType;
	TemperatureUnit temperatureUnit;
	TimeFormat timeFormat;
	TimeChoice timeOut;
	int timezone;
	TimeChoice turnOffTime;

private:
	void sendCommand(const QString &cmd);

};

#endif // GUISETTINGS_H
