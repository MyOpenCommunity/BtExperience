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

ObjectInterface *createIntercom(QList<ObjectPair> places)
{
	VideoDoorEntryDevice *d = bt_global::add_device_to_cache(new VideoDoorEntryDevice((*bt_global::config)[PI_ADDRESS], (*bt_global::config)[PI_MODE]));
	QList<ExternalPlace *> list;

	foreach (const ObjectPair &p, places)
	{
		ExternalPlace *place = qobject_cast<ExternalPlace *>(p.second);
		Q_ASSERT_X(place, "createCCTV", "Invalid external place type");
		list.append(place);
	}

	return new Intercom(list, d);
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

bool VDEBase::callActive()
{
	return call_active;
}

bool VDEBase::exitCall()
{
	return exit_call;
}


CCTV::CCTV(QList<ExternalPlace *> list, VideoDoorEntryDevice *d) : VDEBase(list, d)
{
	// initial values
	brightness = 50;
	contrast = 50;
	color = 50;
	call_stopped = false;
	prof_studio = false;
	hands_free = false;
	ringtone = ExternalPlace1;
	is_autoswitch = false;

	video_grabber.setStandardOutputFile("/dev/null");
	video_grabber.setStandardErrorFile("/dev/null");

	connect(&video_grabber, SIGNAL(started()), SIGNAL(incomingCall()));

	connect(this, SIGNAL(autoOpenChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(handsFreeChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(ringExclusionChanged()), this, SIGNAL(persistItem()));

	connect(this, SIGNAL(brightnessChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(colorChanged()), this, SIGNAL(persistItem()));
	connect(this, SIGNAL(contrastChanged()), this, SIGNAL(persistItem()));
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
	exit_call = true;
	emit exitCallChanged();
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
			if (hands_free)
			{
				dev->answerCall();
			}
		}
		case VideoDoorEntryDevice::AUTO_VCT_CALL:
			// if we arrived here directly is an autoswitch call, if we
			// fell here from the case before it is a normal call
			qDebug() << "Received VCT_(AUTO)_CALL";
			// TODO: many many other things...but this should be enough for now.
			if (call_stopped && it.key() == VideoDoorEntryDevice::VCT_CALL)
				resumeVideo();
			else
				startVideo();
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
			if (!callInProgress()) // ignore
				break;
			call_stopped = true;
			stopVideo();
			break;
		case VideoDoorEntryDevice::ANSWER_CALL:
			qDebug() << "Received ANSWER_CALL";
			if (!callInProgress()) // ignore
				break;
			// for the case when we received a STOP_VIDEO frame from the camera
			startVideo();
			if (!call_active)
			{
				call_active = true;
				emit callActiveChanged();
			}
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
	if (call_in_progress)
		return;
	call_in_progress = true;
	emit callInProgressChanged();
}

void CCTV::disactivateCall()
{
	if (call_active)
	{
		call_active = false;
		emit callActiveChanged();
	}

	if (call_in_progress)
	{
		call_in_progress = false;
		emit callInProgressChanged();
	}

	if (exit_call)
	{
		exit_call = false;
		emit exitCallChanged();
	}
}


Intercom::Intercom(QList<ExternalPlace *> l, VideoDoorEntryDevice *d) : VDEBase(l, d)
{
	// initial values
	ringtone = Internal;
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
	exit_call = true;
	emit exitCallChanged();
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
	exit_call = true;
	emit exitCallChanged();
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
		case VideoDoorEntryDevice::ANSWER_CALL:
			qDebug() << "Received VideoDoorEntryDevice::ANSWER_CALL: " << *it;
			if (!callInProgress()) // ignore
				break;
			if (!call_active)
			{
				call_active = true;
				emit callActiveChanged();
			}
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
	if (call_in_progress)
		return;
	call_in_progress = true;
	emit callInProgressChanged();
}

void Intercom::disactivateCall()
{
	if (call_active)
	{
		call_active = false;
		emit callActiveChanged();
	}
	if (pager_call)
	{
		pager_call = false;
		emit pagerCallChanged();
	}
	if (call_in_progress)
	{
		call_in_progress = false;
		emit callInProgressChanged();
	}
	if (exit_call)
	{
		exit_call = false;
		emit exitCallChanged();
	}
}
