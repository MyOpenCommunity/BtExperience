#ifndef VCT_H
#define VCT_H

/*!
	\defgroup VideoDoorEntry Video door entry
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
QList<ObjectPair> parseVdeCamera(const QDomNode &xml_node);


/*!
	\ingroup VideoDoorEntry
	\brief Contains address and description for a single external place/surveillance camera
*/
class ExternalPlace : public ObjectInterface
{
	Q_OBJECT

	Q_PROPERTY(QString where READ getWhere() CONSTANT)

public:
	ExternalPlace(const QString &name, int object_id, const QString &where);

	virtual int getObjectId() const { return object_id; }

	QString getWhere() const
	{
		return where;
	}

private:
	QString where;
	int object_id;
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

	/*!
		\brief Sets or gets the saturation level of the display. Saturation must
		be a value between 0 and 100.
	*/
	Q_PROPERTY(int saturation READ getSaturation WRITE setSaturation NOTIFY saturationChanged)

	/*!
		\brief Sets or gets the if door must automatically open when a call arrives.
	*/
	Q_PROPERTY(bool autoOpen READ getAutoOpen WRITE setAutoOpen NOTIFY autoOpenChanged)

	Q_PROPERTY(ObjectDataModel *externalPlaces READ getExternalPlaces CONSTANT)

	/*!
		\brief Whether the current call is SCS or IP
	*/
	Q_PROPERTY(bool isIpCall READ isIpCall NOTIFY isIpCallChanged)

	/*!
		\brief Logical event (as reported by the device) for which a ringtone should be played
	*/
	Q_PROPERTY(Ringtone ringtone READ getRingtone NOTIFY ringtoneChanged)

	Q_ENUMS(Ringtone)

public:
	enum Ringtone
	{
		ExternalPlace1 = 10,
		ExternalPlace2,
		ExternalPlace3,
		ExternalPlace4
	};

	explicit CCTV(QList<ExternalPlace *> l, VideoDoorEntryDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdCCTV;
	}

	int getBrightness() const;
	void setBrightness(int value);
	int getContrast() const;
	void setContrast(int value);
	int getSaturation() const;
	void setSaturation(int value);
	ObjectDataModel *getExternalPlaces() const;
	bool getAutoOpen() const { return prof_studio; }
	void setAutoOpen(bool newValue);
	bool isIpCall() const;
	Ringtone getRingtone() const;

	Q_INVOKABLE void answerCall();
	Q_INVOKABLE void endCall();

public slots:
	void cameraOn(QString where);
	void openLock();
	void releaseLock();
	void stairLightActivate();
	void stairLightRelease();
	void nextCamera();
	void callerAddress(QString address);

signals:
	void brightnessChanged();
	void contrastChanged();
	void saturationChanged();
	void incomingCall();
	void callEnded();
	void autoOpenChanged();
	void callAnswered();
	void isIpCallChanged();
	void ringtoneChanged();


protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	int brightness;
	int contrast;
	int saturation;

private:
	void setRingtone(int vde_ringtone);
	void startVideo();
	void stopVideo();
	void resumeVideo();
	void activateCall();
	void disactivateCall();
	bool callActive();

	bool call_stopped;
	bool call_active;
	bool prof_studio;
	bool ip_mode;
	Ringtone ringtone;
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

	/*!
		\brief Whether the current call is SCS or IP
	*/
	Q_PROPERTY(bool isIpCall READ isIpCall NOTIFY isIpCallChanged)

	/*!
		\brief Logical event (as reported by the device) for which a ringtone should be played
	*/
	Q_PROPERTY(Ringtone ringtone READ getRingtone NOTIFY ringtoneChanged)

	Q_ENUMS(Ringtone)

public:
	enum Ringtone
	{
		Internal = 20,
		External,
		Floorcall
	};

	explicit Intercom(QList<ExternalPlace *> l, VideoDoorEntryDevice *d);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdIntercom;
	}

	virtual QString getObjectKey() const
	{
		return key;
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
	bool isIpCall() const;
	Ringtone getRingtone() const;

signals:
	void volumeChanged();
	void muteChanged();
	void incomingCall();
	void incomingFloorCall();
	void callEnded();
	void talkerChanged();
	void callAnswered();
	void isIpCallChanged();
	void ringtoneChanged();


protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;
	int volume;
	bool mute;

private:
	void setRingtone(int vde_ringtone);
	void setTalkerFromWhere(QString where);
	void activateCall();
	void disactivateCall();
	bool callActive();

	bool call_active;
	bool ip_mode;
	Ringtone ringtone;
	VideoDoorEntryDevice *dev;
	ObjectDataModel external_places;
	QString talker;
};

#endif // VCT_H
