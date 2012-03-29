#ifndef HARDWARE_H
#define HARDWARE_H

#include "objectinterface.h"

#include <QObject>


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

	Q_PROPERTY(int brightness READ getBrightness WRITE setBrightness NOTIFY brightnessChanged)
	Q_PROPERTY(int contrast READ getContrast WRITE setContrast NOTIFY contrastChanged)

public:
	HardwareSettings();

	virtual int getObjectId() const
	{
		return ObjectInterface::IdHardwareSettings;
	}

	virtual QString getObjectKey() const { return QString(); }

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Settings;
	}

	virtual QString getName() const { return QString(); }

	// brightness must be [1, 100]
	int getBrightness() const;
	void setBrightness(int b);
	// contrast must be [1, 100]
	int getContrast() const;
	void setContrast(int c);

signals:
	void brightnessChanged();
	void contrastChanged();

protected:
	int brightness;
	int contrast;

private:
	void sendCommand(const QString &cmd);

};

#endif // HARDWARE_H
