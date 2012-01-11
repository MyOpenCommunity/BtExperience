#include "antintrusionsystem.h"
#include "antintrusion_device.h"
#include "objectlistmodel.h"

#include <QDebug>


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


AntintrusionSystem::AntintrusionSystem(AntintrusionDevice *d)
{
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
            if (inserted && !status)
            {
                // TODO: delete all the old alarms
            }
            status = inserted;
            break;
        }

        case AntintrusionDevice::DIM_ZONE_INSERTED:
        case AntintrusionDevice::DIM_ZONE_PARTIALIZED:
            foreach (AntintrusionZone *z, zones)
                if (z->getObjectId() == it.value().toInt())
                    z->setPartialization(it.key() == AntintrusionDevice::DIM_ZONE_PARTIALIZED, false);

            break;
        }

        ++it;
    }
}
