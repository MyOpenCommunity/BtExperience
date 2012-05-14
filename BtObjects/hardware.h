#ifndef HARDWARE_H
#define HARDWARE_H

#include "objectinterface.h"

#include <QObject>
#include <QDateTime>


/*!
	\ingroup Settings
	\brief Manages hardware settings for application

	Class to provide services to read and write settings dependent on hardware.

	The object id is \a ObjectInterface::IdHardwareSettings.
*/
class HardwareSettings : public ObjectInterface
{
	friend class TestHardwareSettings;

	Q_OBJECT

	/*!
		\brief Sets or gets if date&time must be auto updated or not.
	*/
	Q_PROPERTY(bool autoUpdate READ getAutoUpdate WRITE setAutoUpdate NOTIFY autoUpdateChanged)

	/*!
		\brief Sets or gets the date.
	*/
	Q_PROPERTY(QDate date READ getDate WRITE setDate NOTIFY dateChanged)

	/*!
		\brief Sets or gets if daylight saving time must be taken into account.
	*/
	Q_PROPERTY(bool summerTime READ getSummerTime WRITE setSummerTime NOTIFY summerTimeChanged)

	/*!
		\brief Sets or gets the time.
	*/
	Q_PROPERTY(QTime time READ getTime WRITE setTime NOTIFY timeChanged)

public:
	HardwareSettings();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdHardwareSettings;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Settings;
	}

	bool getAutoUpdate() const;
	void setAutoUpdate(bool v);
	QDate getDate() const;
	void setDate(QDate d);
	bool getSummerTime() const;
	void setSummerTime(bool d);
	QTime getTime() const;
	void setTime(QTime t);

signals:
	void autoUpdateChanged();
	void dateChanged();
	void summerTimeChanged();
	void timeChanged();

protected:
	bool autoUpdate;
	QDate date;
	bool summerTime;
	QTime time;

private:
	void sendCommand(const QString &cmd);

};

#endif // HARDWARE_H
