#include "vct.h"
#include "videodoorentry_device.h"

#include <QDebug>

QString video_grabber_path = "/usr/share/ti/linux-driver-examples/video/saUserPtrLoopback";
QString video_grabber_args = "-i 0 -s 2";


CCTV::CCTV(QString name,
		   QString key,
		   VideoDoorEntryDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

	connect(this, SIGNAL(stairLightActivate()), dev, SLOT(stairLightActivate()));
	connect(this, SIGNAL(stairLightRelease()), dev, SLOT(stairLightRelease()));
	connect(this, SIGNAL(openLock()), dev, SLOT(openLock()));
	connect(this, SIGNAL(releaseLock()), dev, SLOT(releaseLock()));

	connect(&video_grabber, SIGNAL(finished(int,QProcess::ExitStatus)), SIGNAL(videoIsStopped()));
	connect(&video_grabber, SIGNAL(started), SIGNAL(videoIsRunning()));

	this->key = key;
	this->name = name;

	// initial values
	brightness = 50;
	contrast = 50;
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

void CCTV::answerCall()
{
	dev->answerCall();
}

void CCTV::endCall()
{
	dev->endCall();
	stopVideo();
}

void CCTV::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case VideoDoorEntryDevice::VCT_CALL:
			qDebug() << "Received VCT_CALL";
			// TODO: many many other things...but this should be enough for now.
			emit incomingCall();
			startVideo();
			break;
		case VideoDoorEntryDevice::END_OF_CALL:
			qDebug() << "Received END_OF_CALL";
			emit callEndRequested();
			stopVideo();
			break;
		case VideoDoorEntryDevice::STOP_VIDEO:
			qDebug() << "Received STOP_VIDEO";
			stopVideo();
//			emit stopVideoRequested();
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
