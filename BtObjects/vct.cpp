#include "vct.h"
#include "videodoorentry_device.h"
#include "xml_functions.h"
#include "devices_cache.h"

#include <QDebug>

QString video_grabber_path = "/usr/share/ti/linux-driver-examples/video/saUserPtrLoopback";
QString video_grabber_args = "-i 0 -s 2";

ObjectInterface *parseCCTV(const QDomNode &n)
{
	QString where = getTextChild(n, "where");
	QList<ExternalPlace *> list;
	foreach (const QDomNode &obj, getChildren(n, "obj"))
	{
		list.append(new ExternalPlace(getTextChild(obj, "descr"), getTextChild(obj, "where")));
	}

	return new CCTV(list, bt_global::add_device_to_cache(new VideoDoorEntryDevice("11", "0")));
}

ObjectInterface *parseIntercom(const QDomNode &n)
{
	// TODO add parse code
	Q_UNUSED(n);

	QList<ExternalPlace *> list;
	list.append(new ExternalPlace("Portone", "14"));
	list.append(new ExternalPlace("Garage", "14#2"));

	return new Intercom(list, bt_global::add_device_to_cache(new VideoDoorEntryDevice("11", "0")));
}


ExternalPlace::ExternalPlace(const QString &_name, const QString &_where)
{
	name = _name;
	where = _where;
}


CCTV::CCTV(QList<ExternalPlace *> list, VideoDoorEntryDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	connect(this, SIGNAL(stairLightActivate()), dev, SLOT(stairLightActivate()));
	connect(this, SIGNAL(stairLightRelease()), dev, SLOT(stairLightRelease()));
	connect(this, SIGNAL(openLock()), dev, SLOT(openLock()));
	connect(this, SIGNAL(releaseLock()), dev, SLOT(releaseLock()));

	// initial values
	brightness = 50;
	contrast = 50;
	call_stopped = false;

	foreach (ExternalPlace *ep, list)
		external_places.insertWithoutUii(ep);

	video_grabber.setStandardOutputFile("/dev/null");
	video_grabber.setStandardErrorFile("/dev/null");
}

int CCTV::getBrightness() const
{
	return brightness;
}

void CCTV::setBrightness(int value)
{
	// TODO set value on device
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
	contrast = value;
	emit contrastChanged();
}

ObjectListModel *CCTV::getExternalPlaces() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ObjectListModel*>(&external_places);
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

void CCTV::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case VideoDoorEntryDevice::VCT_CALL:
		case VideoDoorEntryDevice::AUTO_VCT_CALL:
			qDebug() << "Received VCT_(AUTO)_CALL";
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
			break;
		case VideoDoorEntryDevice::END_OF_CALL:
			qDebug() << "Received END_OF_CALL";
			call_stopped = false;
			stopVideo();
			emit callEnded();
			break;
		case VideoDoorEntryDevice::STOP_VIDEO:
			qDebug() << "Received STOP_VIDEO";
			call_stopped = true;
			stopVideo();
			break;
		case VideoDoorEntryDevice::CALLER_ADDRESS:
			qDebug() << "Received CALLER_ADDRESS: " << *it;
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
		qDebug() << "Starting grabber with args: " << (video_grabber_path + " " + video_grabber_args);
		video_grabber.start(video_grabber_path + " " + video_grabber_args);
	}
}

void CCTV::stopVideo()
{
	qDebug() << "CCTV::stopVideo";
	if (video_grabber.state() != QProcess::NotRunning)
	{
		qDebug() << "terminate grabber";
		video_grabber.terminate();
	}
}

void CCTV::resumeVideo()
{
	qDebug() << "CCTV::resumeVideo()";
	call_stopped = false;
	startVideo();
}


Intercom::Intercom(QList<ExternalPlace *> l, VideoDoorEntryDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	// initial values
	volume = 50;
	mute = false;

	foreach (ExternalPlace *ep, l) {
		external_places.insertWithoutUii(ep);
	}
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
}

int Intercom::getVolume() const
{
	return volume;
}

void Intercom::setVolume(int value)
{
	// TODO set value on device
	volume = value;
	emit volumeChanged();
}

bool Intercom::getMute() const
{
	return mute;
}

void Intercom::setMute(bool value)
{
	// TODO set value on device
	mute = value;
	emit muteChanged();
}

ObjectListModel *Intercom::getExternalPlaces() const
{
	// TODO: See the comment on ThermalControlUnit::getModalities
	return const_cast<ObjectListModel*>(&external_places);
}

QString Intercom::getTalker() const
{
	return talker;
}

void Intercom::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case VideoDoorEntryDevice::INTERCOM_CALL:
			qDebug() << "Received VideoDoorEntryDevice::INTERCOM_CALL";
			// TODO: many many other things...but this should be enough for now.
			emit incomingCall();
			break;
		case VideoDoorEntryDevice::END_OF_CALL:
			qDebug() << "Received VideoDoorEntryDevice::END_OF_CALL";
			talker = "";
			emit callEnded();
			emit talkerChanged();
			break;
		case VideoDoorEntryDevice::ANSWER_CALL:
			qDebug() << "Received VideoDoorEntryDevice::ANSWER_CALL: " << *it;
			emit callAnswered();
			break;
		case VideoDoorEntryDevice::CALLER_ADDRESS:
			qDebug() << "Received VideoDoorEntryDevice::CALLER_ADDRESS: " << *it;
			setTalkerFromWhere(it.value().toString());
			break;
		case VideoDoorEntryDevice::RINGTONE:
			// TODO gestire la suoneria?
			qDebug() << "Received VideoDoorEntryDevice::RINGTONE";
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
	for(int i = 0; i < external_places.getSize(); ++i)
	{
		ObjectInterface *obj = external_places.getObject(i);
		ExternalPlace *ep = static_cast<ExternalPlace *>(obj);
		if (ep->where == where)
		{
			talker = ep->name;
			emit talkerChanged();
			break;
		}
	}
}

