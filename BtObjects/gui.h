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
		\brief Sets or gets the type of screen saver in use
	*/
	Q_PROPERTY(QString screensaverText READ getScreensaverText WRITE setScreensaverText NOTIFY screensaverTextChanged)

	/*!
		\brief Sets or gets the type of screen saver in use
	*/
	Q_PROPERTY(ScreensaverType screensaverType READ getScreensaverType WRITE setScreensaverType NOTIFY screensaverTypeChanged)

	/*!
		\brief Sets or gets the turn off time for the display.
	*/
	Q_PROPERTY(TimeChoice timeOut READ getTimeOut WRITE setTimeOut NOTIFY timeOutChanged)

	/*!
		\brief Sets or gets the turn off time for the display.
	*/
	Q_PROPERTY(TimeChoice turnOffTime READ getTurnOffTime WRITE setTurnOffTime NOTIFY turnOffTimeChanged)

	Q_ENUMS(ScreensaverType)
	Q_ENUMS(TimeChoice)

public:
	GuiSettings();

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

	QString getScreensaverText() const;
	void setScreensaverText(QString t);
	ScreensaverType getScreensaverType() const;
	void setScreensaverType(ScreensaverType st);
	TimeChoice getTimeOut() const;
	void setTimeOut(TimeChoice tc);
	TimeChoice getTurnOffTime() const;
	void setTurnOffTime(TimeChoice tc);

signals:
	void screensaverTextChanged();
	void screensaverTypeChanged();
	void timeOutChanged();
	void turnOffTimeChanged();

protected:
	QString screensaverText;
	ScreensaverType screensaverType;
	TimeChoice timeOut;
	TimeChoice turnOffTime;
};

#endif // GUI_H
