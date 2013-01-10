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
class ExternalPlace;
class QDomNode;

QList<ObjectPair> parseExternalPlace(const QDomNode &xml_node);
QList<ObjectPair> parseVdeCamera(const QDomNode &xml_node);
QList<ObjectPair> parseInternalIntercom(const QDomNode &xml_node);
QList<ObjectPair> parseExternalIntercom(const QDomNode &xml_node);
QList<ObjectPair> parseSwitchboard(const QDomNode &xml_node);

ObjectInterface *createCCTV(QList<ObjectPair> places);
ObjectInterface *createIntercom(QList<ObjectPair> places);


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
	\brief Common base ofr CCTV and Intercom

	The object id is \a ObjectInterface::IdCCTV.
*/
class VDEBase : public ObjectInterface
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

	/*!
		\brief The list of external places associated with this object
	*/
	Q_PROPERTY(ObjectDataModel *externalPlaces READ getExternalPlaces CONSTANT)

	/*!
		\brief Whether the current call is SCS or IP
	*/
	Q_PROPERTY(bool isIpCall READ isIpCall NOTIFY isIpCallChanged)

	/*!
		\brief Whether there is an active call or not
	*/
	Q_PROPERTY(bool callInProgress READ callInProgress NOTIFY callInProgressChanged)

public:
	ObjectDataModel *getExternalPlaces() const;

	bool isIpCall() const;

	int getVolume() const;
	void setVolume(int value);
	bool getMute() const;
	void setMute(bool value);

signals:
	void volumeChanged();
	void muteChanged();
	void isIpCallChanged();
	void callInProgressChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list) = 0;

protected:
	explicit VDEBase(QList<ExternalPlace *> l, VideoDoorEntryDevice *d);

	bool callInProgress();

	int volume;
	bool mute;
	bool ip_mode;
	bool call_in_progress;
	ObjectDataModel external_places;
	VideoDoorEntryDevice *dev;
};


/*!
	\ingroup VideoDoorEntry
	\brief Class to manage a CCTV spot.

	The object id is \a ObjectInterface::IdCCTV.
*/
class CCTV : public VDEBase
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
		\brief Sets or gets the Color level of the display. Color must
		be a value between 0 and 100.
	*/
	Q_PROPERTY(int color READ getColor WRITE setColor NOTIFY colorChanged)

	/*!
		\brief Sets or gets the if door must automatically open when a call arrives.
	*/
	Q_PROPERTY(bool autoOpen READ getAutoOpen WRITE setAutoOpen NOTIFY autoOpenChanged)

	/*!
		\brief Sets or gets the if device must automatically answer when a call arrives.
	*/
	Q_PROPERTY(bool handsFree READ getHandsFree WRITE setHandsFree NOTIFY handsFreeChanged)

	/*!
		\brief Logical event (as reported by the device) for which a ringtone should be played
	*/
	Q_PROPERTY(Ringtone ringtone READ getRingtone NOTIFY ringtoneChanged)

	/*!
		\brief Gets if it is an autoswitch call.
	*/
	Q_PROPERTY(bool autoSwitch READ getAutoSwitch NOTIFY autoSwitchChanged)

	/*!
		\brief Sets or gets ring exclusion status
	*/
	Q_PROPERTY(bool ringExclusion READ getRingExclusion WRITE setRingExclusion NOTIFY ringExclusionChanged)

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
	int getColor() const;
	void setColor(int value);
	bool getAutoOpen() const { return prof_studio; }
	void setAutoOpen(bool newValue);
	Ringtone getRingtone() const;
	bool getAutoSwitch() const { return is_autoswitch; }
	bool getHandsFree() const { return hands_free; }
	void setHandsFree(bool newValue);
	bool getRingExclusion() const;
	void setRingExclusion(bool newValue);

	Q_INVOKABLE void answerCall();
	Q_INVOKABLE void endCall();
	Q_INVOKABLE void cameraOn(ExternalPlace *place);

public slots:
	void openLock();
	void releaseLock();
	void stairLightActivate();
	void stairLightRelease();
	void nextCamera();
	void callerAddress(QString address);

signals:
	void brightnessChanged();
	void contrastChanged();
	void colorChanged();
	void incomingCall();
	void callEnded();
	void autoOpenChanged();
	void callAnswered();
	void isIpCallChanged();
	void ringtoneChanged();
	void ringtoneReceived();
	void autoSwitchChanged();
	void handsFreeChanged();
	void ringExclusionChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	int brightness;
	int contrast;
	int color;

private:
	void setRingtone(int vde_ringtone);
	void startVideo();
	void stopVideo();
	void resumeVideo();
	void activateCall();
	void disactivateCall();

	bool call_stopped;
	bool prof_studio;
	bool hands_free;
	bool is_autoswitch;
	Ringtone ringtone;
	QProcess video_grabber;
};


/*!
	\ingroup VideoDoorEntry
	\brief Class to manage an intercom call.

	The object id is \a ObjectInterface::IdIntercom.
*/
class Intercom : public VDEBase
{
	friend class TestVideoDoorEntry;

	Q_OBJECT

	/*!
		\brief Retrieves a description for the device on the other side of the call.
	*/
	Q_PROPERTY(QString talker READ getTalker NOTIFY talkerChanged)

	/*!
		\brief Logical event (as reported by the device) for which a ringtone should be played
	*/
	Q_PROPERTY(Ringtone ringtone READ getRingtone NOTIFY ringtoneChanged)

	/*!
		\brief Is a pager call ringing?
	*/
	Q_PROPERTY(bool pagerCall READ isPagerCall NOTIFY pagerCallChanged)

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
	Q_INVOKABLE void answerPagerCall();
	Q_INVOKABLE void endCall();
	Q_INVOKABLE void startCall(ExternalPlace *place);
	Q_INVOKABLE bool getRingExclusion() const;
	Q_INVOKABLE void startPagerCall();

	QString getTalker() const;
	Ringtone getRingtone() const;
	bool isPagerCall() const { return pager_call; }

signals:
	void incomingCall();
	void callEnded();
	void talkerChanged();
	void callAnswered();
	void ringtoneChanged();
	void ringtoneReceived();
	void floorRingtoneReceived();
	void pagerCallChanged();
	void microphoneOnRequested();
	void speakersOnRequested();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	QString key;

private:
	void setRingtone(int vde_ringtone);
	void setTalkerFromWhere(QString where);
	void activateCall();
	void disactivateCall();

	bool pager_call;
	Ringtone ringtone;
	QString talker;
};

#endif // VCT_H
