#ifndef GUI_H
#define GUI_H

#include "objectinterface.h"

#include <QObject>


/*!
	\ingroup Settings
	\brief Manages GUI settings for application

	Class to provide services to read and write settings independent from
	hardware. Settings in this file don't need a device to be managed.

	The object id is \a ObjectInterface::IdGui.
*/
class GuiSettings : public ObjectInterface
{
	friend class TestGuiSettings;

	Q_OBJECT

	/*!
		\brief Sets or gets if date&time must be auto updated or not.
	*/
	Q_PROPERTY(AutoUpdate autoUpdate READ getAutoUpdate WRITE setAutoUpdate NOTIFY autoUpdateChanged)

	/*!
		\brief Sets or gets the currency.
	*/
	Q_PROPERTY(Currency currency READ getCurrency WRITE setCurrency NOTIFY currencyChanged)

	/*!
		\brief Sets or gets the date.
	*/
	Q_PROPERTY(QString date READ getDate WRITE setDate NOTIFY dateChanged)

	/*!
		\brief Sets or gets if daylight saving time must be taken into account.
	*/
	Q_PROPERTY(DaylightSavingTime dst READ getDst WRITE setDst NOTIFY dstChanged)

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
		\brief Sets or gets the type of screen saver in use
	*/
	Q_PROPERTY(QString screensaverImage READ getScreensaverImage WRITE setScreensaverImage NOTIFY screensaverImageChanged)

	/*!
		\brief Sets or gets the type of screen saver in use
	*/
	Q_PROPERTY(QString screensaverText READ getScreensaverText WRITE setScreensaverText NOTIFY screensaverTextChanged)

	/*!
		\brief Sets or gets the type of screen saver in use
	*/
	Q_PROPERTY(ScreensaverType screensaverType READ getScreensaverType WRITE setScreensaverType NOTIFY screensaverTypeChanged)

	/*!
		\brief Sets or gets the unit used for temperature in Celsius or Fahrenheit.
	*/
	Q_PROPERTY(TemperatureUnit temperatureUnit READ getTemperatureUnit WRITE setTemperatureUnit NOTIFY temperatureUnitChanged)

	/*!
		\brief Sets or gets the time.
	*/
	Q_PROPERTY(QString time READ getTime WRITE setTime NOTIFY timeChanged)

	/*!
		\brief Sets or gets the turn off time for the display.
	*/
	Q_PROPERTY(TimeChoice timeOut READ getTimeOut WRITE setTimeOut NOTIFY timeOutChanged)

	/*!
		\brief Sets or gets the timezone.
	*/
	Q_PROPERTY(int timezone READ getTimezone WRITE setTimezone NOTIFY timezoneChanged)
	// TODO use an enum for all managed timezones

	/*!
		\brief Sets or gets the turn off time for the display.
	*/
	Q_PROPERTY(TimeChoice turnOffTime READ getTurnOffTime WRITE setTurnOffTime NOTIFY turnOffTimeChanged)

	Q_ENUMS(AutoUpdate)
	Q_ENUMS(Currency)
	Q_ENUMS(DaylightSavingTime)
	Q_ENUMS(Language)
	Q_ENUMS(MeasurementSystem)
	Q_ENUMS(NumberSeparators)
	Q_ENUMS(ScreensaverType)
	Q_ENUMS(TemperatureUnit)
	Q_ENUMS(TimeChoice)
	Q_ENUMS(TimeFormat)

public:
	GuiSettings();

	enum AutoUpdate
	{
		AutoUpdate_disabled,
		AutoUpdate_enabled
	};

	enum Currency
	{
		CHF,
		EUR,
		GBP,
		JPY,
		USD
	};

	enum DaylightSavingTime
	{
		Dst_disabled,
		Dst_enabled
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

	virtual int getObjectId() const
	{
		return ObjectInterface::IdGuiSettings;
	}

	virtual QString getObjectKey() const { return QString(); }

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Settings;
	}

	virtual QString getName() const { return QString(); }

	AutoUpdate getAutoUpdate() const;
	void setAutoUpdate(AutoUpdate v);
	Currency getCurrency() const;
	void setCurrency(Currency c);
	QString getDate() const;
	void setDate(QString d);
	DaylightSavingTime getDst() const;
	void setDst(DaylightSavingTime d);
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
	QString getTime() const;
	void setTime(QString t);
	TimeChoice getTimeOut() const;
	void setTimeOut(TimeChoice tc);
	int getTimezone() const;
	void setTimezone(int z);
	TimeChoice getTurnOffTime() const;
	void setTurnOffTime(TimeChoice tc);

signals:
	void autoUpdateChanged();
	void currencyChanged();
	void dateChanged();
	void dstChanged();
	void formatChanged();
	void keyboardLayoutChanged();
	void languageChanged();
	void measurementSystemChanged();
	void numberSeparatorsChanged();
	void screensaverImageChanged();
	void screensaverTextChanged();
	void screensaverTypeChanged();
	void temperatureUnitChanged();
	void timeChanged();
	void timeOutChanged();
	void timezoneChanged();
	void turnOffTimeChanged();

protected:
	AutoUpdate autoUpdate;
	Currency currency;
	QString date;
	DaylightSavingTime dst;
	QString keyboardLayout;
	Language language;
	MeasurementSystem measurementSystem;
	NumberSeparators numberSeparators;
	QString screensaverImage;
	QString screensaverText;
	ScreensaverType screensaverType;
	TemperatureUnit temperatureUnit;
	QString time;
	TimeFormat timeFormat;
	TimeChoice timeOut;
	int timezone;
	TimeChoice turnOffTime;
};

#endif // GUI_H
