#ifndef LIGHTOBJECTS_H
#define LIGHTOBJECTS_H

#include <QObject>

#include "objectinterface.h"


class Light : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(int objectId READ getObjectId CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(bool status READ getStatus WRITE setStatus NOTIFY statusChanged)

public:
    Light(QString name, bool status);

    virtual int getObjectId() const
    {
        return ObjectInterface::Light;
    }

    virtual int getCategory() const
    {
        return LIGHTING;
    }

    virtual QString getName() const;
    virtual bool getStatus() const;
    virtual void setStatus(bool st);

signals:
    void statusChanged();

private:
    QString name;
    bool status;
};


class Dimmer : public Light
{
    Q_OBJECT
    Q_PROPERTY(int percentage READ getPercentage WRITE setPercentage NOTIFY percentageChanged)

public:
    Dimmer(QString name, bool status, int percentage);

    virtual int getObjectId() const
    {
        return ObjectInterface::Dimmer;
    }

    virtual int getPercentage() const;
    virtual void setPercentage(int val);

signals:
    void percentageChanged();

private:
    int percentage;
};


#endif // LIGHTOBJECTS_H

