#include "settings.h"

#include <QDebug>


void HardwareSettings::setBrightness(int level)
{
    qDebug() << "HardwareSettings::setBrightness";
    // TODO: perform the proper conversion
    sendCommand(QString("i2cset -y 1 0x4a 0xf0 0x") + QString::number(level));
    sendCommand(QString("i2cset -y 1 0x4a 0xf9 0x") + QString::number(level));
}

int HardwareSettings::getBrightness() const
{
    // TODO: read the real value
    return 1;
}

void HardwareSettings::sendCommand(const QString &cmd)
{
    // TODO: add error check
    qDebug() << "HardwareSettings::sendCommand" << cmd;
    system(qPrintable(cmd));
}


