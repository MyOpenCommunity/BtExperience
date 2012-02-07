#include "antintrusionsystem.h"
#include "antintrusion_device.h"
#include "objectlistmodel.h"

#include "xml_functions.h"

#include <QDebug>

#define CODE_TIMEOUT_SECS 10

AntintrusionZone::AntintrusionZone(int id, QString _name)
{
    zone_number = id;
    name = _name;
    partialized = true;
}

bool AntintrusionZone::getPartialization() const
{
    return partialized;
}

void AntintrusionZone::setPartialization(bool p, bool request_partialization)
{
    if (p != partialized) {
        partialized = p;
        emit partializationChanged();
        if (request_partialization)
            emit requestPartialization(zone_number, p);
    }
}


AntintrusionSystem::AntintrusionSystem(AntintrusionDevice *d, const QDomNode &xml_node)
{
    foreach (const QDomNode &scenario, getChildren(getChildWithName(xml_node, "scenarios"), "scenario"))
    {

    }

    waiting_response = false;
    initialized = false;
    status = false;
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

    QList<QPair<int, QString> > zone_list;
    zone_list << qMakePair(1, QString("ingresso")) << qMakePair(2, QString("taverna"))
              << qMakePair(3, QString("mansarda")) << qMakePair(4, QString("box/cantina"))
              << qMakePair(5, QString("soggiorno")) << qMakePair(6, QString("cucina"))
              << qMakePair(7, QString("camera")) << qMakePair(8, QString("cameretta"));

    for (int i = 0; i < zone_list.length(); ++i) {
        AntintrusionZone *z = new AntintrusionZone(zone_list.at(i).first, zone_list.at(i).second);
        dev->partializeZone(zone_list.at(i).first, z->getPartialization()); // initialization
        connect(z, SIGNAL(requestPartialization(int,bool)), dev, SLOT(partializeZone(int,bool)));
        zones << z;
    }
}

ObjectListModel *AntintrusionSystem::getZones() const
{
    ObjectListModel *items = new ObjectListModel;
    for (int i = 0; i < zones.length(); ++i)
        items->appendRow(zones[i]);

    items->reparentObjects();

    return items;
}

void AntintrusionSystem::valueReceived(const DeviceValues &values_list)
{
    DeviceValues::const_iterator it = values_list.constBegin();
    while (it != values_list.constEnd())
    {
        switch (it.key())
        {
        case AntintrusionDevice::DIM_SYSTEM_INSERTED:
        {
            bool inserted = it.value().toBool();
            if (!initialized) {
                initialized = true;
                status = inserted;
            }
            else {
                if (inserted == status) {
                    if (waiting_response) {
                        emit codeRefused();
                        waiting_response = false;
                    }
                }
                else {
                    if (!status) {
                        // TODO: delete all the old alarms
                    }
                    status = inserted;
                    emit statusChanged();

                    if (waiting_response) {
                        emit codeAccepted();
                        waiting_response = false;
                    }
                }
            }
            break;
        }

        case AntintrusionDevice::DIM_ZONE_INSERTED:
        case AntintrusionDevice::DIM_ZONE_PARTIALIZED:
            foreach (AntintrusionZone *z, zones)
                if (z->getObjectId() == it.value().toInt())
                    z->setPartialization(it.key() == AntintrusionDevice::DIM_ZONE_PARTIALIZED, false);
            break;
        case AntintrusionDevice::DIM_ANTIPANIC_ALARM:
        case AntintrusionDevice::DIM_INTRUSION_ALARM:
        case AntintrusionDevice::DIM_TAMPER_ALARM:
        case AntintrusionDevice::DIM_TECHNICAL_ALARM:
//            emit alarmReceived();
            break;
        }

        ++it;
    }
}

void AntintrusionSystem::handleCodeTimeout()
{
    if (!waiting_response) // we have already received the response
        return;

    qDebug() << "AntintrusionSystem -> code timeout";
    waiting_response = false;
    emit codeTimeout();
}

void AntintrusionSystem::requestPartialization(const QString &password)
{
    dev->setPartialization(password);
    waiting_response = true;
    QTimer::singleShot(CODE_TIMEOUT_SECS * 1000, this, SLOT(handleCodeTimeout()));
}

void AntintrusionSystem::toggleActivation(const QString &password)
{
    dev->toggleActivation(password);
    waiting_response = true;
}
