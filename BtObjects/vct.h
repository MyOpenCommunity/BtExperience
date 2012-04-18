#ifndef VCT_H
#define VCT_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>

class VideoDoorEntryDevice;


/*!
	\ingroup VideoDoorEntry
	\brief Class to manage a CCTV spot.

	The object id is \a ObjectInterface::IdCCTV.
*/
class CCTV : public ObjectInterface
{
	friend class TestVideoDoorEntry;

	Q_OBJECT

	/*!
		\brief Sets or gets the brightness level of the display. Brightness
		must be a value between 0 and 100.
	*/
	Q_PROPERTY(int brightness READ getBrightness WRITE setBrightness NOTIFY brightnessChanged)

	/*!
		\brief Sets or gets the contrast level of the display. Contrast must
		be a value between 0 and 100.
	*/
	Q_PROPERTY(int contrast READ getContrast WRITE setContrast NOTIFY contrastChanged)

public:
	explicit CCTV(QString name,
				  QString key,
				  VideoDoorEntryDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdCCTV;
	}

	virtual QString getObjectKey() const
	{
		return key;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::VideoEntry;
	}

	virtual QString getName() const
	{
		return name;
	}

	int getBrightness() const;
	void setBrightness(int value);
	int getContrast() const;
	void setContrast(int value);

signals:
	void brightnessChanged();
	void contrastChanged();
	void openLock();
	void releaseLock();
	void stairLightActivate();
	void stairLightRelease();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;
	QString name;
	int brightness;
	int contrast;

private:
	VideoDoorEntryDevice *dev;
};

/*!
	\ingroup VideoDoorEntry
	\brief Class to manage an intercom call.

	The object id is \a ObjectInterface::IdIntercom.
*/
class Intercom : public ObjectInterface
{
	friend class TestVideoDoorEntry;

	Q_OBJECT

	/*!
		\brief Sets or gets the volume level for the call. Volume must be a
		value between 0 and 100.
	*/
	Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)

	/*!
		\brief Mute or unmute an active intercom call.
	*/
	Q_PROPERTY(bool mute READ getMute WRITE setMute NOTIFY muteChanged)

public:
	explicit Intercom(QString name,
					  QString key,
					  VideoDoorEntryDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdIntercom;
	}

	virtual QString getObjectKey() const
	{
		return key;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::VideoEntry;
	}

	virtual QString getName() const
	{
		return name;
	}

	int getVolume() const;
	void setVolume(int value);
	bool getMute() const;
	void setMute(bool value);

signals:
	void volumeChanged();
	void muteChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;
	QString name;
	int volume;
	bool mute;

private:
	VideoDoorEntryDevice *dev;
};

#endif // VCT_H
