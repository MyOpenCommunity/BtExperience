#include "vct.h"
#include "videodoorentry_device.h"

#include <QDebug>


CCTV::CCTV(QString name,
		   QString key,
		   VideoDoorEntryDevice *d)
{
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

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
