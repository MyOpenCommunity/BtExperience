#ifndef VCT_H
#define VCT_H

/*!
	\defgroup VideoDoorEntry
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues
#include "objectmodel.h"

#include <QObject>
#include <QProcess>

class VideoDoorEntryDevice;
class QDomNode;

ObjectInterface *parseCCTV(const QDomNode &n);
ObjectInterface *parseIntercom(const QDomNode &n);


/*!
	\ingroup VideoDoorEntry
	\brief Contains address and description for a single external place
*/
class ExternalPlace : public ObjectInterface
{
	friend class Intercom; // to access the where field

	Q_OBJECT

	Q_PROPERTY(QString where READ getWhere() CONSTANT)

public:
	ExternalPlace(const QString &_name, const QString &_where);

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Unassigned;
	}

	QString getWhere() const
	{
		return where;
	}

private:
	QString where;
};


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

	Q_PROPERTY(ObjectDataModel *externalPlaces READ getExternalPlaces CONSTANT)

public:
	explicit CCTV(QList<ExternalPlace *> l, VideoDoorEntryDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdCCTV;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::VideoEntry;
	}

	int getBrightness() const;
	void setBrightness(int value);
	int getContrast() const;
	void setContrast(int value);
	ObjectDataModel *getExternalPlaces() const;

	Q_INVOKABLE void answerCall();
	Q_INVOKABLE void endCall();

public slots:
	void cameraOn(QString where);

signals:
	void brightnessChanged();
	void contrastChanged();
	void openLock();
	void releaseLock();
	void stairLightActivate();
	void stairLightRelease();
	void incomingCall();
	void callEnded();


protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	int brightness;
	int contrast;

private:
	void startVideo();
	void stopVideo();
	void resumeVideo();
	bool call_stopped;
	QProcess video_grabber;
	VideoDoorEntryDevice *dev;
	ObjectDataModel external_places;
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

	Q_PROPERTY(ObjectDataModel *externalPlaces READ getExternalPlaces CONSTANT)

	/*!
		\brief Retrieves a description for the device on the other side of the call.
	*/
	Q_PROPERTY(QString talker READ getTalker NOTIFY talkerChanged)

public:
	explicit Intercom(QList<ExternalPlace *> l, VideoDoorEntryDevice *d);

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

	Q_INVOKABLE void answerCall();
	Q_INVOKABLE void endCall();
	Q_INVOKABLE void startCall(QString where);

	int getVolume() const;
	void setVolume(int value);
	bool getMute() const;
	void setMute(bool value);
	ObjectDataModel *getExternalPlaces() const;
	QString getTalker() const;

signals:
	void volumeChanged();
	void muteChanged();
	void incomingCall();
	void callEnded();
	void talkerChanged();
	void callAnswered();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;
	int volume;
	bool mute;

private:
	void setTalkerFromWhere(QString where);

	VideoDoorEntryDevice *dev;
	ObjectDataModel external_places;
	QString talker;
};

#endif // VCT_H
