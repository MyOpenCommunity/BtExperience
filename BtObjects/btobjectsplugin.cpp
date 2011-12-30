#include "btobjectsplugin.h"
#include "openclient.h"
#include "frame_classes.h"
#include "main.h"
#include "device.h"
#include "devices_cache.h"
#include "lighting_device.h"
#include "thermal_device.h"
#include "probe_device.h"
#include "objectlistmodel.h"
#include "lightobjects.h"
#include "thermalobjects.h"
#include "thermalprobes.h"

#include <QtDeclarative/qdeclarative.h>


QHash<GlobalField, QString> *bt_global::config;


ControlledProbeDevice *getProbeDevice(QString probe_where)
{
    return bt_global::add_device_to_cache(new ControlledProbeDevice(probe_where, "0", probe_where,
                                            ControlledProbeDevice::CENTRAL_99ZONES, ControlledProbeDevice::NORMAL));
}


BtObjectsPlugin::BtObjectsPlugin(QObject *parent) : QDeclarativeExtensionPlugin(parent)
{
    bt_global::config = new QHash<GlobalField, QString>();
    (*bt_global::config)[TS_NUMBER] = QString::number(0);

    ClientWriter::setDelay((*bt_global::config)[TS_NUMBER].toInt() * TS_NUMBER_FRAME_DELAY);

    QHash<int, Clients> clients;
    QHash<int, ClientReader*> monitors;

    monitors[MAIN_OPENSERVER] = new ClientReader(Client::MONITOR);
    clients[MAIN_OPENSERVER].command = new ClientWriter(Client::COMMAND);
    clients[MAIN_OPENSERVER].request = new ClientWriter(Client::REQUEST);

    ClientReader *client_supervisor = new ClientReader(Client::SUPERVISOR);
    client_supervisor->forwardFrame(monitors[MAIN_OPENSERVER]);
    clients[MAIN_OPENSERVER].supervisor = client_supervisor;

    FrameReceiver::setClientsMonitor(monitors);
    FrameSender::setClients(clients);

    createObjects();
    device::initDevices();
    FilterListModel::setSource(&objmodel);
}

void BtObjectsPlugin::createObjects()
{
    objmodel.appendRow(new Light("lampada scrivania", "13", bt_global::add_device_to_cache(new LightingDevice("13"))));
    objmodel.appendRow(new Light("lampadario soggiorno", "1", bt_global::add_device_to_cache(new LightingDevice("1"))));
    objmodel.appendRow(new Dimmer("faretti soggiorno", "29", bt_global::add_device_to_cache(new DimmerDevice("29", PULL))));
    objmodel.appendRow(new Light("lampada da terra soggiorno","2",  bt_global::add_device_to_cache(new LightingDevice("2"))));
    objmodel.appendRow(new Light("abat jour", "3", bt_global::add_device_to_cache(new LightingDevice("3"))));
    objmodel.appendRow(new Light("abat jour", "4", bt_global::add_device_to_cache(new LightingDevice("4"))));
    objmodel.appendRow(new Light("lampada studio", "5", bt_global::add_device_to_cache(new LightingDevice("5"))));
    objmodel.appendRow(new ThermalControlUnit99Zones(QString::fromLocal8Bit("unità centrale"), "", bt_global::add_device_to_cache(new ThermalDevice99Zones("0"))));
    objmodel.appendRow(new ThermalControlledProbe("zona giorno", "1", getProbeDevice("5")));
    objmodel.appendRow(new ThermalControlledProbe("zona notte", "2", getProbeDevice("2")));
    objmodel.appendRow(new ThermalControlledProbe("zona taverna", "3", getProbeDevice("3")));
    objmodel.appendRow(new ThermalControlledProbe("zona studio", "4", getProbeDevice("4")));
    objmodel.reparentObjects();
}

void BtObjectsPlugin::registerTypes(const char *uri)
{
    // @uri BtObjects
    qmlRegisterUncreatableType<ObjectListModel>(uri, 1, 0, "ObjectListModel", "");
    qmlRegisterType<FilterListModel>(uri, 1, 0, "FilterListModel");
    qmlRegisterUncreatableType<ObjectInterface>(uri, 1, 0, "ObjectInterface",
        "unable to create an ObjectInterface instance");
    qmlRegisterUncreatableType<ThermalControlUnit99Zones>(uri, 1, 0, "ThermalControlUnit99Zones",
        "unable to create a ThermalControlUnit99Zones instance");
    qmlRegisterUncreatableType<ThermalControlledProbe>(uri, 1, 0, "ThermalControlledProbe",
        "unable to create a ThermalControlledProbe instance");
}

Q_EXPORT_PLUGIN2(BtObjects, BtObjectsPlugin)

