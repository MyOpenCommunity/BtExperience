#ifndef LIGHTOBJECTS_H
#define LIGHTOBJECTS_H

#include <QObject>

#include "objectinterface.h"
#include "device.h" // DeviceValues

class LightingDevice;
class DimmerDevice;


class LightInterface : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(bool status READ getStatus WRITE setStatus NOTIFY statusChanged)

public:
    // the status of the object: on or off.
    virtual bool getStatus() const = 0;
    virtual void setStatus(bool st) = 0;

    virtual QVariant data(int role) const;
    virtual QHash<int, QByteArray> roleNames();

signals:
    void statusChanged();
};


class Light : public LightInterface
{
    Q_OBJECT

public:
    Light(QString name, QString key, LightingDevice *d);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdLight;
    }

    virtual QString getObjectKey() const;

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::Lighting;
    }

    virtual QString getName() const;
    virtual bool getStatus() const;
    virtual void setStatus(bool st);

protected slots:
    virtual void valueReceived(const DeviceValues &values_list);

protected:
    QString name;
    QString key;
    bool status;

private:
    LightingDevice *dev;
};


class Dimmer : public Light
{
    Q_OBJECT
    Q_PROPERTY(int percentage READ getPercentage WRITE setPercentage NOTIFY percentageChanged)

public:
    Dimmer(QString name, QString key, DimmerDevice *d);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdDimmer;
    }

    virtual int getPercentage() const;
    virtual void setPercentage(int val);

signals:
    void percentageChanged();

protected slots:
    virtual void valueReceived(const DeviceValues &values_list);

protected:
    int percentage;

private:
    DimmerDevice *dev;
};


#endif // LIGHTOBJECTS_H

