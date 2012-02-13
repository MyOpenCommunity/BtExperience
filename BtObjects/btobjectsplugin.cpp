#include "btobjectsplugin.h"
#include "openclient.h"
#include "frame_classes.h"
#include "main.h"
#include "device.h"
#include "devices_cache.h"
#include "lighting_device.h"
#include "thermal_device.h"
#include "probe_device.h"
#include "antintrusion_device.h"
#include "objectlistmodel.h"
#include "lightobjects.h"
#include "thermalobjects.h"
#include "thermalprobes.h"
#include "antintrusionsystem.h"
#include "xml_functions.h"
#include "settings.h"

#include <QtDeclarative/qdeclarative.h>
#include <QFile>
#include <QFileInfo>

#include <QDomNode>

#define CONF_FILE "conf.xml"


QHash<GlobalField, QString> *bt_global::config;


ControlledProbeDevice *getProbeDevice(QString probe_where)
{
	return bt_global::add_device_to_cache(new ControlledProbeDevice(probe_where, "0", probe_where,
		ControlledProbeDevice::CENTRAL_99ZONES, ControlledProbeDevice::NORMAL));
}


BtObjectsPlugin::BtObjectsPlugin(QObject *parent) : QDeclarativeExtensionPlugin(parent)
{
	QFile fh(CONF_FILE);
	QDomDocument document;
	if (!fh.exists() || !document.setContent(&fh))
		qFatal("The config file %s does not seem a valid xml configuration file", qPrintable(QFileInfo(fh).absoluteFilePath()));

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

	createObjects(document);
	device::initDevices();
	FilterListModel::setSource(&objmodel);
}

void BtObjectsPlugin::createObjects(QDomDocument document)
{
	foreach (const QDomNode &item, getChildren(document.documentElement(), "item"))
	{
		ObjectInterface *obj = 0;

		int id = getTextChild(item, "id").toInt();
		QString descr = getTextChild(item, "descr");
		QString where = getTextChild(item, "where");

		switch (id)
		{
		case ObjectInterface::IdLight:
		{
			PullMode p = getTextChild(item, "pul").toInt() == 1 ? PULL : NOT_PULL;
			obj = new Light(descr, where, bt_global::add_device_to_cache(new LightingDevice(where, p)));
			break;
		}
		case ObjectInterface::IdDimmer:
		{
			PullMode p = getTextChild(item, "pul").toInt() == 1 ? PULL : NOT_PULL;
			obj = new Dimmer(descr, where, bt_global::add_device_to_cache(new DimmerDevice(where, p)));
			break;
		}
		case ObjectInterface::IdThermalControlUnit99:
			obj = new ThermalControlUnit99Zones(descr, "", bt_global::add_device_to_cache(new ThermalDevice99Zones("0")));
			break;
		case ObjectInterface::IdThermalControlledProbe:
		{
			ControlledProbeDevice::ProbeType fancoil = getTextChild(item, "fancoil").toInt() == 1 ?
						ControlledProbeDevice::FANCOIL :  ControlledProbeDevice::NORMAL;
			obj = new ThermalControlledProbe(descr, where,
											 new ControlledProbeDevice(where, "0", where, ControlledProbeDevice::CENTRAL_99ZONES, fancoil));
			break;
		}
		case ObjectInterface::IdHardwareSettings:
			obj = new HardwareSettings;
			break;
		case ObjectInterface::IdAntintrusionSystem:
			obj = new AntintrusionSystem(bt_global::add_device_to_cache(new AntintrusionDevice), item);
			break;
		default:
			Q_ASSERT_X(false, "BtObjectsPlugin::createObjects", qPrintable(QString("Unknown id %1").arg(id)));
		}
		objmodel.appendRow(obj);
	}

	objmodel.reparentObjects();
	objmodel.setRoleNames();
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

