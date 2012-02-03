#ifndef SETTINGS_H
#define SETTINGS_H

#include "objectinterface.h"


class HardwareSettings : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(int brightness READ getBrightness WRITE setBrightness NOTIFY brightnessChanged)

public:
    // brightness must be [1, 100]
    void setBrightness(int);
    int getBrightness() const;

    virtual int getObjectId() const
    {
        return ObjectInterface::IdHardwareSettings;
    }

    virtual QString getObjectKey() const { return QString(); }

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::Settings;
    }

    virtual QString getName() const { return QString(); }

signals:
    void brightnessChanged();

private:
    void sendCommand(const QString &cmd);
};

#endif // SETTINGS_H
