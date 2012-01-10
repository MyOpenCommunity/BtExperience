#ifndef ANTINTRUSIONSYSTEM_H
#define ANTINTRUSIONSYSTEM_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QString>


class AntintrusionDevice;
class ObjectListModel;


class AntintrusionZone : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(bool partialization READ getPartialization WRITE setPartialization NOTIFY partializationChanged)

public:
    AntintrusionZone(int id, QString name);
    virtual int getObjectId() const
    {
        return object_id;
    }

    virtual QString getObjectKey() const { return QString(); }

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::Antintrusion;
    }

    virtual QString getName() const { return name; }

    bool getPartialization() const;
    void setPartialization(bool p);

signals:
    void partializationChanged();

private:
    int object_id;
    QString name;
    bool partialized;
};


class AntintrusionSystem : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(ObjectListModel *zones READ getZones NOTIFY zonesChanged)

public:
    AntintrusionSystem(AntintrusionDevice *d);

    virtual int getObjectId() const
    {
        return ObjectInterface::IdAntintrusionSystem;
    }

    virtual QString getObjectKey() const { return QString(); }

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::Antintrusion;
    }

    virtual QString getName() const { return QString(); }

    ObjectListModel *getZones() const;

private slots:
    virtual void valueReceived(const DeviceValues &values_list);

signals:
    void zonesChanged();

private:
    AntintrusionDevice *dev;
    QList<AntintrusionZone*> zones;
};


#endif // ANTINTRUSIONSYSTEM_H
