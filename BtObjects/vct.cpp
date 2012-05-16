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
			emit incomingCall();
			startVideo();
			break;
		case VideoDoorEntryDevice::END_OF_CALL:
			qDebug() << "Received END_OF_CALL";
			stopVideo();
			emit callEnded();
			break;
		case VideoDoorEntryDevice::STOP_VIDEO:
			qDebug() << "Received STOP_VIDEO";
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


Intercom::Intercom(QString name,
				   QString key,
				   VideoDoorEntryDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	this->key = key;
	this->name = name;

	// initial values
	volume = 50;
	mute = false;
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

void Intercom::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		}
		++it;
	}
}

