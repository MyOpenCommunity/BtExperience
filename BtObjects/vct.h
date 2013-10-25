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
#include <QTimer>

class VideoDoorEntryDevice;
class ExternalPlace;
class QDomNode;

QList<ObjectPair> parseExternalPlace(const QDomNode &xml_node);
QList<ObjectPair> parseVdeCamera(const QDomNode &xml_node);
QList<ObjectPair> parseInternalIntercom(const QDomNode &xml_node);
QList<ObjectPair> parseExternalIntercom(const QDomNode &xml_node);
QList<ObjectPair> parseSwitchboard(const QDomNode &xml_node);
QList<ObjectPair> parsePager(const QDomNode &xml_node);

ObjectInterface *createCCTV(QList<ObjectPair> places);
ObjectInterface *createIntercom(QList<ObjectPair> places, bool pager);


// Almost empty class, we only need the id for the GUI, the rest is handled by
// Intercom class
class Pager: public ObjectInterface
{
	Q_OBJECT
public:
	Pager() { }
	virtual int getObjectId() const { return ObjectInterface::IdPager; }
};


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
		\brief Retrieves a description for the device on the other side of the call.
	*/
	Q_PROPERTY(QString talker READ getTalker NOTIFY talkerChanged)

	/*!
		\brief Whether the current call is SCS or IP
	*/
	Q_PROPERTY(bool isIpCall READ isIpCall NOTIFY isIpCallChanged)

	/*!
		\brief Whether there is an active call or not
	*/
	Q_PROPERTY(bool callInProgress READ callInProgress NOTIFY callInProgressChanged)

	/*!
		\brief Whether the active call has been answered or not
	*/
	Q_PROPERTY(bool callActive READ callActive NOTIFY callActiveChanged)

	/*!
		\brief Whether I made the call (exiting) or not
	*/
	Q_PROPERTY(bool exitingCall READ exitingCall NOTIFY exitingCallChanged)

	/*!
		\brief Gets if it is a teleloop call.
	*/
	Q_PROPERTY(bool teleloop READ getTeleloop NOTIFY teleloopChanged)

	/*!
		\brief Gets if this VDE device have a moving camera or not.
	*/
	Q_PROPERTY(bool movingCamera READ getMovingCamera NOTIFY movingCameraChanged)

public:
	ObjectDataModel *getExternalPlaces() const;

	bool isIpCall() const;

	int getVolume() const;
	void setVolume(int value);
	bool getMute() const;
	void setMute(bool value);
	bool getTeleloop() const;
	bool getMovingCamera() const;

	void setTalkerFromWhere(const QString &where);
	QString getTalker() const;

signals:
	void volumeChanged();
	void muteChanged();
	void isIpCallChanged();
	void callInProgressChanged();
	void callActiveChanged();
	void exitingCallChanged();
	void teleloopChanged();
	void movingCameraChanged();
	void talkerChanged(const QString &talker);

public slots:
	void moveUpPress();
	void moveDownPress();
	void moveLeftPress();
	void moveRightPress();
	void moveUpRelease();
	void moveDownRelease();
	void moveLeftRelease();
	void moveRightRelease();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list) = 0;

protected:
	explicit VDEBase(QList<ExternalPlace *> l, VideoDoorEntryDevice *d);

	bool callInProgress();
	void setCallInProgress(bool in_progress);
	bool callActive();
	void setCallActive(bool active);
	bool exitingCall();
	void setExitingCall(bool exiting);
	void setTeleloop(bool teleloop);

	int volume;
	bool mute;
	bool ip_mode;
	bool is_teleloop;
	bool moving_camera;
	bool call_in_progress, call_active, exit_call;
	QString talker;
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

	/*!
		\brief Gets the id of the associated teleloop

		Returns 0 if the teleloop is not enabled, a number in range [1-9] inclusive
		otherwise.
	*/
	Q_PROPERTY(int associatedTeleloopId READ getAssociatedTeleloopId NOTIFY associatedTeleloopIdChanged)

	/*!
		\brief Gets whether a teleloop association is in progress
	*/
	Q_PROPERTY(bool teleloopAssociating READ getTeleloopAssociating NOTIFY teleloopAssociatingChanged)

	Q_ENUMS(Ringtone GrabberState)

public:
	enum Ringtone
	{
		ExternalPlace1 = 10,
		ExternalPlace2,
		ExternalPlace3,
		ExternalPlace4
	};

	enum GrabberState
	{
		GrabberRunning,
		GrabberNotRunning
	};

	explicit CCTV(QList<ExternalPlace *> l, VideoDoorEntryDevice *d, QString pe_address);

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
	int getAssociatedTeleloopId() const;
	// should only be used during initial configuration parsing
	void setAssociatedTeleloopId(int id);
	bool getTeleloopAssociating() const;

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
	void startTeleloopAssociation();

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
	void associatedTeleloopIdChanged();
	void teleloopAssociationStarted();
	void teleloopAssociationComplete();
	void teleloopAssociationTimeout();
	void teleloopAssociatingChanged();
	void grabberStateChanged(int newState);

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);
	void grabberStateReceived(QProcess::ProcessState state);

protected:
	int brightness;
	int contrast;
	int color;

private slots:
	void associationTimeout();
	void startVideo();
	void delayedAnswerCall();

private:
	void setRingtone(int vde_ringtone);
	void stopVideo();
	void resumeVideo();
	void activateCall();
	void disactivateCall();

	bool video_enabled;
	bool call_stopped;
	bool prof_studio;
	bool hands_free;
	bool is_autoswitch;
	Ringtone ringtone;
	QProcess video_grabber;
	QTimer association_timeout;
	QTimer grabber_delay;
	QTimer hands_free_delay;
	QString pe_address;
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
		\brief Logical event (as reported by the device) for which a ringtone should be played
	*/
	Q_PROPERTY(Ringtone ringtone READ getRingtone NOTIFY ringtoneChanged)

	/*!
		\brief Is a pager call ringing?
	*/
	Q_PROPERTY(bool pagerCall READ isPagerCall NOTIFY pagerCallChanged)

	/*!
		\brief Is a pager configured?
	*/
	Q_PROPERTY(bool pagerConfigured READ isPagerConfigured CONSTANT)

	Q_ENUMS(Ringtone)

public:
	enum Ringtone
	{
		Internal = 20,
		External,
		Floorcall
	};

	explicit Intercom(QList<ExternalPlace *> l, VideoDoorEntryDevice *d, bool pager);

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
	bool isPagerConfigured() const { return pager_configured; }

signals:
	void incomingCall();
	void callEnded();
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
	void activateCall();
	void disactivateCall();

	bool pager_call, pager_configured;
	Ringtone ringtone;
};

#endif // VCT_H
