#include "vct.h"
#include "videodoorentry_device.h"
#include "xml_functions.h"
#include "devices_cache.h"
#include "xmlobject.h"
#include "main.h" // bt_global::config

#include <QDebug>

#if defined(BT_HARDWARE_X11)
QString video_grabber_path = "/bin/cat";
#else
//QString video_grabber_path = "/usr/local/bin/Fw-A-LcdOpenGLRenderingQt.sh";
QString video_grabber_path = "/usr/local/bin/Fw-A-VideoInLoopback.sh 66051";
#endif

#define TELELOOP_TIMEOUT_CONNECTION 11
#define VIDEO_GRABBER_DELAY 1000
#define HANDS_FREE_DELAY 1000 * 5 // delay for automatic answer on hands free calls

namespace
{
	bool ring_exclusion = false;

	QList<ObjectPair> parseExternalPlace(const QDomNode &xml_node, int id)
	{
		QList<ObjectPair> obj_list;
		XmlObject v(xml_node);

		foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
		{
			v.setIst(ist);
			int uii = getIntAttribute(ist, "uii");
			QString where;

			if (id == ObjectInterface::IdSwitchboard)
				where = (*bt_global::config)[GUARD_UNIT_ADDRESS];
			else
				where = v.value("dev") + v.value("where");

			obj_list << ObjectPair(uii, new ExternalPlace(v.value("descr"), id, where));
		}
		return obj_list;
	}
}

ObjectInterface *createCCTV(QList<ObjectPair> places)
{
	VideoDoorEntryDevice *d = bt_global::add_device_to_cache(new VideoDoorEntryDevice((*bt_global::config)[PI_ADDRESS], (*bt_global::config)[PI_MODE]));
	QList<ExternalPlace *> list;

	foreach (const ObjectPair &p, places)
	{
		ExternalPlace *place = qobject_cast<ExternalPlace *>(p.second);
		Q_ASSERT_X(place, "createCCTV", "Invalid external place type");
		list.append(place);
	}

	return new CCTV(list, d);
}

ObjectInterface *createIntercom(QList<ObjectPair> places, bool pager)
{
	VideoDoorEntryDevice *d = bt_global::add_device_to_cache(new VideoDoorEntryDevice((*bt_global::config)[PI_ADDRESS], (*bt_global::config)[PI_MODE]));
	QList<ExternalPlace *> list;

	foreach (const ObjectPair &p, places)
	{
		ExternalPlace *place = qobject_cast<ExternalPlace *>(p.second);
		Q_ASSERT_X(place, "createCCTV", "Invalid external place type");
		list.append(place);
	}

	return new Intercom(list, d, pager);
}

QList<ObjectPair> parseExternalPlace(const QDomNode &xml_node)
{
	return parseExternalPlace(xml_node, ObjectInterface::IdExternalPlace);
}

QList<ObjectPair> parseVdeCamera(const QDomNode &xml_node)
{
	return parseExternalPlace(xml_node, ObjectInterface::IdSurveillanceCamera);
}

QList<ObjectPair> parseInternalIntercom(const QDomNode &xml_node)
{
	return parseExternalPlace(xml_node, ObjectInterface::IdInternalIntercom);
}

QList<ObjectPair> parseExternalIntercom(const QDomNode &xml_node)
{
	return parseExternalPlace(xml_node, ObjectInterface::IdExternalIntercom);
}

QList<ObjectPair> parseSwitchboard(const QDomNode &xml_node)
{
	return parseExternalPlace(xml_node, ObjectInterface::IdSwitchboard);
}


ExternalPlace::ExternalPlace(const QString &_name, int _object_id, const QString &_where)
{
	name = _name;
	object_id = _object_id;
	where = _where;
}


VDEBase::VDEBase(QList<ExternalPlace *> list, VideoDoorEntryDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	volume = 50;
	mute = false;
	call_in_progress = false;
	call_active = false;
	exit_call = false;
	ip_mode = dev->vctMode() == VideoDoorEntryDevice::IP_MODE;

	foreach (ExternalPlace *ep, list)
		external_places << ep;
}

int VDEBase::getVolume() const
{
	return volume;
}

void VDEBase::setVolume(int value)
{
	// TODO set value on device
	if (volume == value || value < 0 || value > 100)
		return;
	volume = value;
	emit volumeChanged();
}

bool VDEBase::getMute() const
{
	return mute;
}

void VDEBase::setMute(bool value)
{
	// TODO set value on device
	if (mute == value)
		return;
	mute = value;
	emit muteChanged();
}

ObjectDataModel *VDEBase::getExternalPlaces() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ObjectDataModel*>(&external_places);
}

bool VDEBase::isIpCall() const
{
	return ip_mode;
}

bool VDEBase::callInProgress()
{
	return call_in_progress;
}

void VDEBase::setCallInProgress(bool in_progress)
{
	if (call_in_progress == in_progress)
		return;
	call_in_progress = in_progress;
	emit callInProgressChanged();
}

void VDEBase::setCallActive(bool active)
{
	if (call_active == active)
		return;
	call_active = active;
	emit callActiveChanged();
}

bool VDEBase::callActive()
{
	return call_active;
}

void VDEBase::setExitingCall(bool exiting)
{
	if (exit_call == exiting)
		return;
	exit_call = exiting;
	emit exitingCallChanged();
}

bool VDEBase::exitingCall()
{
	return exit_call;
}

void VDEBase::setTeleloop(bool teleloop)
{
	if (is_teleloop == teleloop)
		return;
	is_teleloop = teleloop;
	emit teleloopChanged();
}

bool VDEBase::getTeleloop() const
{
	return is_teleloop;
}


CCTV::CCTV(QList<ExternalPlace *> list, VideoDoorEntryDevice *d) : VDEBase(list, d)
{
	// initial values
	brightness = 50;
	contrast = 50;
	color = 50;
	video_enabled = false;
	call_stopped = false;
	prof_studio = false;
	hands_free = false;
	ringtone = ExternalPlace1;
	is_autoswitch = false;
	is_teleloop = false;

	video_grabber.setStandardOutputFile("/dev/null");
	video_grabber.setStandardErrorFile("/dev/null");

	grabber_delay.setSingleShot(true);
	grabber_delay.setInterval(VIDEO_GRABBER_DELAY);
	connect(&grabber_delay, SIGNAL(timeout()), this, SLOT(startVideo()));

	association_timeout.setSingleShot(true);
	association_timeout.setInterval(TELELOOP_TIMEOUT_CONNECTION * 1000);
	connect(&association_timeout, SIGNAL(timeout()), this, SLOT(associationTimeout()));

	hands_free_delay.setSingleShot(true);
	hands_free_delay.setInterval(HANDS_FREE_DELAY);
	connect(&hands_free_delay, SIGNAL(timeout()), this, SLOT(delayedAnswerCall()));

	connect(this, SIGNAL(teleloopAssociationStarted()), this, SIGNAL(teleloopAssociatingChanged()));
	connect(this, SIGNAL(teleloopAssociationComplete()), this, SIGNAL(teleloopAssociatingChanged()));
	connect(this, SIGNAL(teleloopAssociationTimeout()), this, SIGNAL(teleloopAssociatingChanged()));

	connect(this, SIGNAL(autoOpenChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(handsFreeChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(ringExclusionChanged()), this, SIGNAL(persistItem()));

	connect(this, SIGNAL(brightnessChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(colorChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(contrastChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(associatedTeleloopIdChanged()), this, SIGNAL(persistItem()));
}

int CCTV::getBrightness() const
{
	return brightness;
}

void CCTV::setBrightness(int value)
{
	if (brightness == value || value < 0 || value > 100)
		return;

	//min 0 max 255 step 1 default 128
	QString scaled_volume = QString::number(value * 255 / 100);
	QString process = "/usr/local/bin/yavta -w \'0x00980900 " + scaled_volume + "\' /dev/v4l-subdev8";
	system(qPrintable(process));
	brightness = value;
	emit brightnessChanged();
}

int CCTV::getContrast() const
{
	return contrast;
}

void CCTV::setContrast(int value)
{
	if (contrast == value || value < 0 || value > 100)
		return;

	//min 0 max 255 step 1 default 128
	QString scaled_volume = QString::number(value * 255 / 100);
	QString process = "/usr/local/bin/yavta -w \'0x00980901 " + scaled_volume + "\' /dev/v4l-subdev8";
	system(qPrintable(process));
	contrast = value;
	emit contrastChanged();
}

int CCTV::getColor() const
{
	return color;
}

void CCTV::setColor(int value)
{
	if (color == value || value < 0 || value > 100)
		return;

	//min 0 max 255 step 1 default 128
	QString scaled_volume = QString::number(value * 255 / 100);
	QString process = "/usr/local/bin/yavta -w \'0x00980902 " + scaled_volume + "\' /dev/v4l-subdev8";
	system(qPrintable(process));
	color = value;
	emit colorChanged();
}

void CCTV::setHandsFree(bool newValue)
{
	if (newValue == hands_free)
		return;

	hands_free = newValue;
	emit handsFreeChanged();
}

bool CCTV::getRingExclusion() const
{
	return ring_exclusion;
}

void CCTV::setRingExclusion(bool newValue)
{
	if (ring_exclusion == newValue)
		return;

	ring_exclusion = newValue;
	emit ringExclusionChanged();
}

void CCTV::setAutoOpen(bool newValue)
{
	if (newValue == prof_studio)
		return;

	prof_studio = newValue;
	emit autoOpenChanged();
}

CCTV::Ringtone CCTV::getRingtone() const
{
	return ringtone;
}

int CCTV::getAssociatedTeleloopId() const
{
	return dev->getTeleloopId();
}

void CCTV::setAssociatedTeleloopId(int id)
{
	if (id == getAssociatedTeleloopId())
		return;
	dev->setTeleloopId(id);
	emit associatedTeleloopIdChanged();
}

bool CCTV::getTeleloopAssociating() const
{
	return association_timeout.isActive();
}

void CCTV::startTeleloopAssociation()
{
	association_timeout.start();
	dev->startTeleLoop((*bt_global::config)[PI_ADDRESS]);
	emit teleloopAssociationStarted();
}

void CCTV::associationTimeout()
{
	association_timeout.stop();
	emit teleloopAssociationTimeout();
}

void CCTV::answerCall()
{
	dev->answerCall();
}

void CCTV::endCall()
{
	if (dev->isCalling())
		dev->endCall();
	emit callEnded();
	disactivateCall();
	call_stopped = false;
	stopVideo();
}

void CCTV::cameraOn(ExternalPlace *place)
{
	setExitingCall(true);
	dev->cameraOn(place->getWhere());
}

void CCTV::openLock()
{
	dev->openLock();
}

void CCTV::releaseLock()
{
	dev->releaseLock();
}

void CCTV::stairLightActivate()
{
	dev->stairLightActivate();
}

void CCTV::stairLightRelease()
{
	dev->stairLightRelease();
}

void CCTV::nextCamera()
{
	dev->cycleExternalUnits();
	stopVideo();
}

void CCTV::callerAddress(QString address)
{
	QString addr = address;
	bool autoswitch = false;

	if (address.at(0) == '@')
	{
		addr = addr.mid(1);
		autoswitch = true;
	}

	if (autoswitch != is_autoswitch)
	{
		is_autoswitch = autoswitch;
		emit autoSwitchChanged();
	}

	if (getAutoSwitch())
		return;

	// normal call: manage professional studio
	if (prof_studio)
	{
		dev->openLock();
		dev->releaseLock();
	}
}

void CCTV::setRingtone(int vde_ringtone)
{
	Ringtone new_ringtone = ringtone;

	switch (vde_ringtone)
	{
	case VideoDoorEntryDevice::PE1:
		new_ringtone = ExternalPlace1;
		break;
	case VideoDoorEntryDevice::PE2:
		new_ringtone = ExternalPlace2;
		break;
	case VideoDoorEntryDevice::PE3:
		new_ringtone = ExternalPlace3;
		break;
	case VideoDoorEntryDevice::PE4:
		new_ringtone = ExternalPlace4;
		break;
	default:
		return;
	}

	if (new_ringtone != ringtone)
	{
		ringtone = new_ringtone;
		emit ringtoneChanged();
	}
	emit ringtoneReceived();
}

void CCTV::valueReceived(const DeviceValues &values_list)
{
	if (dev->ipCall() != ip_mode)
	{
		ip_mode = dev->ipCall();
		emit isIpCallChanged();
	}

	// if call is not active we have to ignore all frames except:
	//	VideoDoorEntryDevice::RINGTONE
	//	VideoDoorEntryDevice::VCT_CALL
	//	VideoDoorEntryDevice::AUTO_VCT_CALL
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case VideoDoorEntryDevice::VCT_CALL:
		{
			qDebug() << "Received VCT_CALL";
			// normal call: manage hands free
			// the timer is needed to introduce a little delay on the automatic
			// answer to hear the ringtone
			if (hands_free)
				hands_free_delay.start();
		}
		case VideoDoorEntryDevice::AUTO_VCT_CALL:
			// if we arrived here directly is an autoswitch call, if we
			// fell here from the case before it is a normal call
			qDebug() << "Received VCT_(AUTO)_CALL";
			// TODO: many many other things...but this should be enough for now.
			if (isIpCall())
				video_enabled = false;
			else
				video_enabled = (it.value().toInt() == VideoDoorEntryDevice::AUDIO_VIDEO);
			if (call_stopped && it.key() == VideoDoorEntryDevice::VCT_CALL)
				resumeVideo();
			else
				grabber_delay.start();
			activateCall();
			if (values_list.contains(VideoDoorEntryDevice::CALLER_ADDRESS))
				callerAddress(values_list[VideoDoorEntryDevice::CALLER_ADDRESS].toString());
			emit incomingCall();
			break;
		case VideoDoorEntryDevice::END_OF_CALL:
			qDebug() << "Received END_OF_CALL";
			call_stopped = false;
			stopVideo();
			emit callEnded();
			disactivateCall();
			break;
		case VideoDoorEntryDevice::STOP_VIDEO:
			qDebug() << "Received STOP_VIDEO";
			if (!callInProgress()) // ignore
				break;
			call_stopped = true;
			stopVideo();
			break;
		case VideoDoorEntryDevice::VCT_TYPE:
		{
			video_enabled = (it.value().toInt() == VideoDoorEntryDevice::AUDIO_VIDEO);
			if (isIpCall())
			{
				video_enabled = false; // Ip calls has always the video disabled.

				// If we have already answered, we need to resend the answer.
				if (callActive())
					dev->answerCall();
			}

			// Switch from a camera with video to a camera without video and vice-versa
			if (video_enabled)
				resumeVideo();
			else
				stopVideo();

			break;
		}
		case VideoDoorEntryDevice::TELE_SESSION:
			qDebug() << "Received TELE_SESSION";
			if (!callInProgress() || call_active) // ignore
				break;
			setTeleloop(true);
		case VideoDoorEntryDevice::ANSWER_CALL:
			qDebug() << "Received ANSWER_CALL/TELE_SESSION";
			if (!callInProgress()) // ignore
				break;
			// for the case when we received a STOP_VIDEO frame from the camera
			startVideo();
			setCallActive(true);
			emit callAnswered();
			break;
		case VideoDoorEntryDevice::CALLER_ADDRESS:
			qDebug() << "Received CALLER_ADDRESS: " << *it;
			if (!callInProgress()) // ignore
				break;
			if (!values_list.contains(VideoDoorEntryDevice::VCT_CALL) &&
				!values_list.contains(VideoDoorEntryDevice::AUTO_VCT_CALL))
				callerAddress(it.value().toString());
			break;
		case VideoDoorEntryDevice::RINGTONE:
			qDebug() << "Received VideoDoorEntryDevice::RINGTONE" << *it;
			setRingtone(it.value().toInt());
			break;
		case VideoDoorEntryDevice::TELE_ANSWER:
		{
			qDebug() << "Received VideoDoorEntryDevice::TELE_ANSWER" << *it;
			if (!getTeleloopAssociating())
				break;
			association_timeout.stop();
			setAssociatedTeleloopId(it.value().toInt());
			emit teleloopAssociationComplete();
			break;
		}
		case VideoDoorEntryDevice::TELE_TIMEOUT:
			qDebug() << "Received VideoDoorEntryDevice::TELE_TIMEOUT" << *it;
			if (!getTeleloopAssociating())
				return;
			associationTimeout();
			break;
		default:
			qDebug() << "CCTV::valueReceived, unhandled value" << it.key() << *it;
			break;
		}
		++it;
	}
}

void CCTV::startVideo()
{
	qDebug() << "CCTV::startVideo";
	grabber_delay.stop();
	if (video_enabled && video_grabber.state() == QProcess::NotRunning)
	{
		qDebug() << "Starting grabber" << (video_grabber_path);
		video_grabber.start(video_grabber_path);
	}
}

void CCTV::delayedAnswerCall()
{
	qDebug() << __PRETTY_FUNCTION__;
	hands_free_delay.stop();
	dev->answerCall();
}

void CCTV::stopVideo()
{
	qDebug() << "CCTV::stopVideo";
	grabber_delay.stop();
	if (video_grabber.state() != QProcess::NotRunning)
	{
		qDebug() << "terminate grabber";
		//TODO: fix correctly the kill of this process
		system ("killall loopback");
		video_grabber.terminate();
	}
}

void CCTV::resumeVideo()
{
	qDebug() << "CCTV::resumeVideo()";
	call_stopped = false;
	startVideo();
}

void CCTV::activateCall()
{
	setCallInProgress(true);
}

void CCTV::disactivateCall()
{
	setCallActive(false);
	setTeleloop(false);
	setCallInProgress(false);
	setExitingCall(false);
	setMute(false);
}


Intercom::Intercom(QList<ExternalPlace *> l, VideoDoorEntryDevice *d, bool _pager) : VDEBase(l, d)
{
	// initial values
	ringtone = Internal;
	pager_configured = _pager;
}

void Intercom::answerCall()
{
	dev->answerCall();
}

void Intercom::answerPagerCall()
{
	dev->answerPagerCall();
	setTalkerFromWhere(dev->callerAddress());
}

void Intercom::endCall()
{
	if (dev->isCalling())
		dev->endCall();
	setTalkerFromWhere(QString());
	emit callEnded();
	disactivateCall();
}

void Intercom::startCall(ExternalPlace *place)
{
	if (place->getObjectId() == ObjectInterface::IdInternalIntercom)
		dev->internalIntercomCall(place->getWhere());
	else
		dev->externalIntercomCall(place->getWhere());
	setTalkerFromWhere(place->getWhere());
	activateCall();
	setExitingCall(true);
}

Intercom::Ringtone Intercom::getRingtone() const
{
	return ringtone;
}

bool Intercom::getRingExclusion() const
{
	return ring_exclusion;
}

void Intercom::startPagerCall()
{
	dev->pagerCall();
	activateCall();
	setExitingCall(true);
	emit microphoneOnRequested();
}

QString Intercom::getTalker() const
{
	return talker;
}

void Intercom::setRingtone(int vde_ringtone)
{
	Ringtone new_ringtone = ringtone;

	switch (vde_ringtone)
	{
	case VideoDoorEntryDevice::PI_INTERCOM:
		new_ringtone = Internal;
		break;
	case VideoDoorEntryDevice::PE_INTERCOM:
		new_ringtone = External;
		break;
	case VideoDoorEntryDevice::FLOORCALL:
		new_ringtone = Floorcall;
		break;
	default:
		return;
	}

	if (new_ringtone != ringtone)
	{
		ringtone = new_ringtone;
		emit ringtoneChanged();
	}

	if (VideoDoorEntryDevice::FLOORCALL == vde_ringtone)
		emit floorRingtoneReceived();
	else
		emit ringtoneReceived();
}

void Intercom::valueReceived(const DeviceValues &values_list)
{
	if (dev->ipCall() != ip_mode)
	{
		ip_mode = dev->ipCall();
		emit isIpCallChanged();
	}

	// if call is not active we have to ignore all frames except:
	//	VideoDoorEntryDevice::RINGTONE
	//	VideoDoorEntryDevice::INTERCOM_CALL
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case VideoDoorEntryDevice::INTERCOM_CALL:
			qDebug() << "Received VideoDoorEntryDevice::INTERCOM_CALL";
			// TODO: many many other things...but this should be enough for now.
			emit incomingCall();
			activateCall();
			break;
		case VideoDoorEntryDevice::PAGER_CALL:
			qDebug() << "Received VideoDoorEntryDevice::PAGER_CALL";
			// TODO: many many other things...but this should be enough for now.
			emit incomingCall();
			activateCall();
			if (!pager_call)
			{
				pager_call = true;
				emit pagerCallChanged();
				emit speakersOnRequested();
			}
			break;
		case VideoDoorEntryDevice::END_OF_CALL:
			qDebug() << "Received VideoDoorEntryDevice::END_OF_CALL";
			if (!callInProgress()) // ignore
				break;
			setTalkerFromWhere(QString());
			emit callEnded();
			disactivateCall();
			break;
		case VideoDoorEntryDevice::TELE_SESSION:
			qDebug() << "Received TELE_SESSION";
			if (!callInProgress() || call_active) // ignore
				break;
			setTeleloop(true);
		case VideoDoorEntryDevice::ANSWER_CALL:
			qDebug() << "Received VideoDoorEntryDevice::ANSWER_CALL: " << *it;
			if (!callInProgress()) // ignore
				break;
			setCallActive(true);
			emit callAnswered();
			break;
		case VideoDoorEntryDevice::CALLER_ADDRESS:
			qDebug() << "Received VideoDoorEntryDevice::CALLER_ADDRESS: " << *it;
			if (!callInProgress()) // ignore
				break;
			setTalkerFromWhere(it.value().toString());
			break;
		case VideoDoorEntryDevice::RINGTONE:
		{
			qDebug() << "Received VideoDoorEntryDevice::RINGTONE" << *it;
			setRingtone(it.value().toInt());
			break;
		}
		default:
			qDebug() << "Intercom::valueReceived, unhandled value" << it.key() << *it;
			break;
		}
		++it;
	}
}

void Intercom::setTalkerFromWhere(QString where)
{
	if (where.isEmpty() && !talker.isEmpty())
	{
		talker = "";
		emit talkerChanged();
		return;
	}

	// helper function used in startCall, answerPagerCall and valueReceived to set the talker where
	// depending on if we are making or receiving a call we have to set the
	// talker where's field in 2 different ways, so this function refactor
	// common code for both cases
	// note: the where passed as CALLER_ADDRESS may be a boolean, it doesn't
	// matter, in that case, the where is set in startCall and we never enter
	// the if
	for (int i = 0; i < external_places.getCount(); ++i)
	{
		ObjectInterface *obj = external_places.getObject(i);
		ExternalPlace *ep = static_cast<ExternalPlace *>(obj);
		if (ep->getWhere() == where)
		{
			talker = ep->getName();
			emit talkerChanged();
			break;
		}
	}
}

void Intercom::activateCall()
{
	setCallInProgress(true);
}

void Intercom::disactivateCall()
{
	setCallActive(false);
	setTeleloop(false);
	if (pager_call)
	{
		pager_call = false;
		emit pagerCallChanged();
	}
	setCallInProgress(false);
	setExitingCall(false);
	setMute(false);
}
