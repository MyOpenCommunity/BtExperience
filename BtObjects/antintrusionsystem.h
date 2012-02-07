#ifndef ANTINTRUSIONSYSTEM_H
#define ANTINTRUSIONSYSTEM_H

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QString>


class AntintrusionDevice;
class ObjectListModel;
class QDomNode;


class AntintrusionZone : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(bool partialization READ getPartialization WRITE setPartialization NOTIFY partializationChanged)

public:
    AntintrusionZone(int id, QString name);
    virtual int getObjectId() const
    {
        return zone_number;
    }

    virtual QString getObjectKey() const { return QString(); }

    virtual ObjectCategory getCategory() const
    {
        return ObjectInterface::Antintrusion;
    }

    virtual QString getName() const { return name; }

    bool getPartialization() const;
    void setPartialization(bool p, bool request_partialization = true);

signals:
    void partializationChanged();
    void requestPartialization(int zone_number, bool partialize);

private:
    int zone_number;
    QString name;
    bool partialized;
};


class AntintrusionSystem : public ObjectInterface
{
    Q_OBJECT
    Q_PROPERTY(ObjectListModel *zones READ getZones NOTIFY zonesChanged)
//    Q_PROPERTY(ObjectListModel *scenarios READ getScenarios NOTIFY scenariosChanged)
    Q_PROPERTY(bool status READ getStatus NOTIFY statusChanged)

public:
    AntintrusionSystem(AntintrusionDevice *d, const QDomNode &xml_node);

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

    Q_INVOKABLE void requestPartialization(const QString &password);
    Q_INVOKABLE void toggleActivation(const QString &password);

    bool getStatus() const
    {
        return status;
    }

signals:
    void zonesChanged();
    void statusChanged();

    void codeAccepted();
    void codeRefused();
    void codeTimeout();

private slots:
    virtual void valueReceived(const DeviceValues &values_list);
    void handleCodeTimeout();

private:
    AntintrusionDevice *dev;
    QList<AntintrusionZone*> zones;
    bool status;
    bool initialized;
    bool waiting_response;
};


#endif // ANTINTRUSIONSYSTEM_H
