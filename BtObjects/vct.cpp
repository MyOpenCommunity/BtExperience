#include "vct.h"
#include "videodoorentry_device.h"

#include <QDebug>


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

void CCTV::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
//		case VideoDoorEntryDevice::DIM_IP:
//			if (it.value().toString() != address)
//			{
//				address = it.value().toString();
//				emit addressChanged();
//			}
//			break;
		}
		++it;
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
