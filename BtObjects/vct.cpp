#include "vct.h"
#include "videodoorentry_device.h"
#include "xml_functions.h"
#include "devices_cache.h"
#include "xmlobject.h"
#include "main.h" // bt_global::config

#include <QDebug>

QString video_grabber_path = "/usr/local/bin/Fw-A-LcdOpenGLRenderingQt.sh";

namespace
{
	bool ring_exclusion = false;
}

ObjectInterface *parseCCTV(const QDomNode &n)
{
	QString where = getTextChild(n, "where");
	QList<ExternalPlace *> list;
	foreach (const QDomNode &obj, getChildren(n, "obj"))
	{
		list.append(new ExternalPlace(getTextChild(obj, "descr"), ObjectInterface::IdExternalPlace, getTextChild(obj, "where")));
	}

	return new CCTV(list, bt_global::add_device_to_cache(new VideoDoorEntryDevice((*bt_global::config)[PI_ADDRESS], (*bt_global::config)[PI_MODE])));
}

ObjectInterface *parseIntercom(const QDomNode &n)
{
	// TODO add parse code
	Q_UNUSED(n);

	QList<ExternalPlace *> list;
	list.append(new ExternalPlace("Portone", ObjectInterface::IdExternalPlace, "14"));
	list.append(new ExternalPlace("Garage", ObjectInterface::IdExternalPlace, "14#2"));

	return new Intercom(list, bt_global::add_device_to_cache(new VideoDoorEntryDevice((*bt_global::config)[PI_ADDRESS], (*bt_global::config)[PI_MODE])));
}

QList<ObjectPair> parseVdeCamera(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		obj_list << ObjectPair(uii, new ExternalPlace(v.value("descr"), ObjectInterface::IdSurveillanceCamera, v.value("where")));
	}
	return obj_list;
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


CCTV::CCTV(QList<ExternalPlace *> list, VideoDoorEntryDevice *d) : VDEBase(list, d)
{
	// initial values
	brightness = 50;
	contrast = 50;
	saturation = 50;
	call_stopped = false;
	call_active = false;
	prof_studio = false;
	hands_free = false;
	ringtone = ExternalPlace1;
	is_autoswitch = false;

	video_grabber.setStandardOutputFile("/dev/null");
	video_grabber.setStandardErrorFile("/dev/null");

	connect(this, SIGNAL(incomingCall()), this, SLOT(manageHandsFree()));
}

int CCTV::getBrightness() const
{
	return brightness;
}

void CCTV::setBrightness(int value)
{
	// TODO set value on device
	if (brightness == value || value < 0 || value > 100)
		return;
	brightness = value;
	emit brightnessChanged();
}

int CCTV::getContrast() const
{
	return contrast;
}

void CCTV::setContrast(int value)
{
	// TODO set value on device
	if (contrast == value || value < 0 || value > 100)
		return;
	contrast = value;
	emit contrastChanged();
}

int CCTV::getSaturation() const
{
	return saturation;
}

void CCTV::setSaturation(int value)
{
	// TODO set value on device
	if (saturation == value || value < 0 || value > 100)
		return;
	saturation = value;
	emit saturationChanged();
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

void CCTV::answerCall()
{
	dev->answerCall();
}

void CCTV::endCall()
{
	dev->endCall();
	call_stopped = false;
	stopVideo();
	emit callEnded();
}

void CCTV::cameraOn(QString where)
{
	dev->cameraOn(where);
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

	// we want to open the door (only if the call does not come from an autoswitch)
	if (prof_studio && !is_autoswitch)
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
		break;
	}

	if (new_ringtone != ringtone)
	{
		ringtone = new_ringtone;
		emit ringtoneChanged();
	}
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
		case VideoDoorEntryDevice::AUTO_VCT_CALL:
			qDebug() << "Received VCT_(AUTO)_CALL";
			if (values_list.contains(VideoDoorEntryDevice::RINGTONE))
				setRingtone(values_list[VideoDoorEntryDevice::RINGTONE].toInt());
			// TODO: many many other things...but this should be enough for now.
			if (call_stopped && it.key() == VideoDoorEntryDevice::VCT_CALL)
			{
				resumeVideo();
			}
			else
			{
				emit incomingCall();
				startVideo();
			}
			activateCall();
			if (values_list.contains(VideoDoorEntryDevice::CALLER_ADDRESS))
				callerAddress(values_list[VideoDoorEntryDevice::CALLER_ADDRESS].toString());
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
			if (!callActive()) // ignore
				break;
			call_stopped = true;
			stopVideo();
			break;
		case VideoDoorEntryDevice::ANSWER_CALL:
			qDebug() << "Received ANSWER_CALL";
			if (!callActive()) // ignore
				break;
			emit callAnswered();
			break;
		case VideoDoorEntryDevice::CALLER_ADDRESS:
			qDebug() << "Received CALLER_ADDRESS: " << *it;
			if (!callActive()) // ignore
				break;
			if (!values_list.contains(VideoDoorEntryDevice::VCT_CALL) &&
				!values_list.contains(VideoDoorEntryDevice::AUTO_VCT_CALL))
				callerAddress(it.value().toString());
			break;
		case VideoDoorEntryDevice::RINGTONE:
			qDebug() << "Received VideoDoorEntryDevice::RINGTONE" << *it;
			setRingtone(it.value().toInt());
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
	if (video_grabber.state() == QProcess::NotRunning)
	{
		qDebug() << "Starting grabber" << (video_grabber_path);
		video_grabber.start(video_grabber_path);
	}
}

void CCTV::stopVideo()
{
	qDebug() << "CCTV::stopVideo";
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
	call_active = true;
}

void CCTV::disactivateCall()
{
	call_active = false;
}

bool CCTV::callActive()
{
	return call_active;
}

void CCTV::manageHandsFree()
{
	if (callActive()) // call already in progress
		return;

	if (hands_free) // auto answer?
		dev->answerCall();
}


Intercom::Intercom(QList<ExternalPlace *> l, VideoDoorEntryDevice *d) : VDEBase(l, d)
{
	// initial values
	call_active = false;
	ringtone = Internal;
}

void Intercom::answerCall()
{
	dev->answerCall();
}

void Intercom::endCall()
{
	dev->endCall();
	talker = "";
	emit talkerChanged();
	emit callEnded();
}

void Intercom::startCall(QString where)
{
	dev->internalIntercomCall(where);
	setTalkerFromWhere(where);
	activateCall();
}

Intercom::Ringtone Intercom::getRingtone() const
{
	return ringtone;
}

bool Intercom::getRingExclusion() const
{
	return ring_exclusion;
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
		break;
	}

	if (new_ringtone != ringtone)
	{
		ringtone = new_ringtone;
		emit ringtoneChanged();
	}
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
			if (values_list.contains(VideoDoorEntryDevice::RINGTONE))
				setRingtone(values_list[VideoDoorEntryDevice::RINGTONE].toInt());
			// TODO: many many other things...but this should be enough for now.
			emit incomingCall();
			activateCall();
			break;
		case VideoDoorEntryDevice::END_OF_CALL:
			qDebug() << "Received VideoDoorEntryDevice::END_OF_CALL";
			if (!callActive()) // ignore
				break;
			talker = "";
			emit callEnded();
			emit talkerChanged();
			disactivateCall();
			break;
		case VideoDoorEntryDevice::ANSWER_CALL:
			qDebug() << "Received VideoDoorEntryDevice::ANSWER_CALL: " << *it;
			if (!callActive()) // ignore
				break;
			emit callAnswered();
			break;
		case VideoDoorEntryDevice::CALLER_ADDRESS:
			qDebug() << "Received VideoDoorEntryDevice::CALLER_ADDRESS: " << *it;
			if (!callActive()) // ignore
				break;
			setTalkerFromWhere(it.value().toString());
			break;
		case VideoDoorEntryDevice::RINGTONE:
			qDebug() << "Received VideoDoorEntryDevice::RINGTONE" << *it;
			setRingtone(it.value().toInt());

			if (it.value().toInt() == VideoDoorEntryDevice::FLOORCALL)
				emit incomingFloorCall();
			break;
		default:
			qDebug() << "Intercom::valueReceived, unhandled value" << it.key() << *it;
			break;
		}
		++it;
	}
}

void Intercom::setTalkerFromWhere(QString where)
{
	// helper function used in startCall and valueReceived to set the talker where
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
	call_active = true;
}

void Intercom::disactivateCall()
{
	call_active = false;
}

bool Intercom::callActive()
{
	return call_active;
}
