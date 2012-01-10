#include "antintrusionsystem.h"
#include "antintrusion_device.h"
#include "objectlistmodel.h"

#include <QDebug>


AntintrusionZone::AntintrusionZone(int id, QString _name)
{
    object_id = id;
    name = _name;
    partialized = true;
}
bool AntintrusionZone::getPartialization() const
{
    return partialized;
}

void AntintrusionZone::setPartialization(bool p)
{
    if (p != partialized) {
        partialized = p;
        emit partializationChanged();
    }
}


AntintrusionSystem::AntintrusionSystem(AntintrusionDevice *d)
{
    dev = d;
    connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));

    zones << new AntintrusionZone(1, "ingresso");
    zones << new AntintrusionZone(2, "taverna");
    zones << new AntintrusionZone(3, "mansarda");
    zones << new AntintrusionZone(4, "box/cantina");
    zones << new AntintrusionZone(5, "soggiorno");
    zones << new AntintrusionZone(6, "cucina");
    zones << new AntintrusionZone(7, "camera");
    zones << new AntintrusionZone(8, "cameretta");
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
    Q_UNUSED(values_list) // TODO
}
