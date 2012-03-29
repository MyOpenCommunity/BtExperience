#include "hardware.h"

#include <QDebug>


HardwareSettings::HardwareSettings()
{
	// TODO read values from somewhere or implement something valueReceived-like
	brightness = 50;
	contrast = 50;
}

void HardwareSettings::sendCommand(const QString &cmd)
{
	// TODO: add error check
	qDebug() << QString("HardwareSettings::sendCommand(%1)").arg(cmd);
	system(qPrintable(cmd));
}

int HardwareSettings::getBrightness() const
{
	return brightness;
}

void HardwareSettings::setBrightness(int b)
{
	qDebug() << QString("HardwareSettings::setBrightness(%1)").arg(b);
	// TODO: perform the proper conversion
	sendCommand(QString("i2cset -y 1 0x4a 0xf0 0x") + QString::number(b, 16));
	sendCommand(QString("i2cset -y 1 0x4a 0xf9 0x") + QString::number(b, 16));
	// TODO save value somewhere
	brightness = b;
	emit brightnessChanged();
}

int HardwareSettings::getContrast() const
{
	return contrast;
}

void HardwareSettings::setContrast(int c)
{
	qDebug() << QString("HardwareSettings::setContrast(%1)").arg(c);
	// TODO save value somewhere
	contrast = c;
	emit contrastChanged();
}
