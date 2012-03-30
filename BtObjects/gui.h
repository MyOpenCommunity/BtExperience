#ifndef GUI_H
#define GUI_H

#include "objectinterface.h"

#include <QObject>


/*!
	\ingroup Settings
	\brief Manages GUI settings for application

	Class to provide services to read and write settings indepent from hardware.

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
		\brief Sets or gets the type of screen saver in use
	*/
	Q_PROPERTY(QString screensaverText READ getScreensaverText WRITE setScreensaverText NOTIFY screensaverTextChanged)

	/*!
		\brief Sets or gets the type of screen saver in use
	*/
	Q_PROPERTY(ScreensaverType screensaverType READ getScreensaverType WRITE setScreensaverType NOTIFY screensaverTypeChanged)

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
	Q_ENUMS(DaylightSavingTime)
	Q_ENUMS(ScreensaverType)
	Q_ENUMS(TimeChoice)
	Q_ENUMS(TimeFormat)

public:
	GuiSettings();

	enum AutoUpdate
	{
		AutoUpdate_disabled,
		AutoUpdate_enabled
	};

	enum DaylightSavingTime
	{
		Dst_disabled,
		Dst_enabled
	};

	enum ScreensaverType
	{
		None,
		DateTime,
		Text,
		Image
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
	QString getDate() const;
	void setDate(QString d);
	DaylightSavingTime getDst() const;
	void setDst(DaylightSavingTime d);
	TimeFormat getFormat() const;
	void setFormat(TimeFormat f);
	QString getScreensaverText() const;
	void setScreensaverText(QString t);
	ScreensaverType getScreensaverType() const;
	void setScreensaverType(ScreensaverType st);
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
	void dateChanged();
	void dstChanged();
	void formatChanged();
	void screensaverTextChanged();
	void screensaverTypeChanged();
	void timeChanged();
	void timeOutChanged();
	void timezoneChanged();
	void turnOffTimeChanged();

protected:
	AutoUpdate autoUpdate;
	QString date;
	DaylightSavingTime dst;
	QString screensaverText;
	ScreensaverType screensaverType;
	QString time;
	TimeFormat timeFormat;
	TimeChoice timeOut;
	int timezone;
	TimeChoice turnOffTime;
};

#endif // GUI_H
