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
#include "mediaobjects.h"
#include "xml_functions.h"
#include "hardware.h"
#include "platform.h"
#include "platform.h"
#include "platform_device.h"
#include "folderlistmodel.h"
#include "roomelement.h"
#include "splitbasicscenario.h"
#include "splitadvancedscenario.h"
#include "airconditioning_device.h"
#include "scenarioobjects.h"
#include "vct.h"
#include "videodoorentry_device.h"
#include "energyload.h"

#include <QtDeclarative/qdeclarative.h>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QApplication>

#include <QDomNode>

#define CONF_FILE "conf.xml"
#define LAYOUT_FILE "layout.xml"


QHash<GlobalField, QString> *bt_global::config;


namespace {
	NonControlledProbeDevice *createNonControlledProbeDevice(const QDomNode &item_node)
	{
		NonControlledProbeDevice *dev = 0;
		QString where_probe = getTextChild(item_node, "where_probe");
		if (where_probe != "000")
		{
			dev = new NonControlledProbeDevice(where_probe, NonControlledProbeDevice::INTERNAL,
				getTextChild(item_node, "openserver_id_probe").toInt());
			dev = bt_global::add_device_to_cache(dev);
		}
		return dev;
	}
}

BtObjectsPlugin::BtObjectsPlugin(QObject *parent) : QDeclarativeExtensionPlugin(parent)
{
	QFile fh(QFileInfo(QDir(qApp->applicationDirPath()), CONF_FILE).absoluteFilePath());
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

	FilterListModel::setGlobalSource(&objmodel);
	RoomListModel::setGlobalSource(&room_model);
	createObjects(document);
	parseConfig();
	device::initDevices();
}

void BtObjectsPlugin::createObjects(QDomDocument document)
{
	foreach (const QDomNode &item, getChildren(document.documentElement(), "item"))
	{
		ObjectInterface *obj = 0;
		QList<ObjectInterface *> obj_list;

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
			obj = createAntintrusionSystem(bt_global::add_device_to_cache(new AntintrusionDevice), item);
			break;
		case ObjectInterface::IdMultiChannelSoundDiffusionSystem:
			obj_list = createSoundDiffusionSystem(item, id);
			break;
		case ObjectInterface::IdMonoChannelSoundDiffusionSystem:
			obj_list = createSoundDiffusionSystem(item, id);
			break;
		case ObjectInterface::IdSplitBasicScenario:
		{
			QStringList programs;
			foreach (const QDomNode &programs_node, getChildrenExact(item, "programs"))
				foreach (const QDomNode &program_node, getChildrenExact(programs_node, "program"))
					programs << program_node.toElement().text();
			obj = new SplitBasicScenario(descr,
										 where,
										 bt_global::add_device_to_cache(
											 new AirConditioningDevice(where)),
										 getTextChild(item, "command"),
										 getTextChild(item, "off_command"),
										 createNonControlledProbeDevice(item),
										 programs);
			break;
		}
		case ObjectInterface::IdSplitAdvancedScenario:
		{
			QList<SplitProgram *> programs;
			foreach (const QDomNode &programs_node, getChildrenExact(item, "programs"))
				foreach (const QDomNode &program_node, getChildrenExact(programs_node, "program"))
					programs << new SplitProgram(
									getTextChild(program_node, "name"),
									SplitProgram::int2Mode(getTextChild(program_node, "mode").toInt()),
									getTextChild(program_node, "set_point").toInt(),
									SplitProgram::int2Speed(getTextChild(program_node, "speed").toInt()),
									SplitProgram::int2Swing(getTextChild(program_node, "swing").toInt()));
			obj = new SplitAdvancedScenario(descr,
											where,
											bt_global::add_device_to_cache(
												new AdvancedAirConditioningDevice(where)),
											getTextChild(item, "command"),
											createNonControlledProbeDevice(item),
											programs);
			break;
		}
		case ObjectInterface::IdScenarioSystem:
			obj_list = createScenarioSystem(item, id);
			break;
		case ObjectInterface::IdCCTV:
			obj = new CCTV(descr,
						   where,
						   bt_global::add_device_to_cache(
							   new VideoDoorEntryDevice(where, getTextChild(item, "mode"))));
			break;
		case ObjectInterface::IdIntercom:
			obj = new Intercom(descr,
							   where,
							   bt_global::add_device_to_cache(
								   new VideoDoorEntryDevice(where, getTextChild(item, "mode"))));
			break;
		default:
			Q_ASSERT_X(false, "BtObjectsPlugin::createObjects", qPrintable(QString("Unknown id %1").arg(id)));
		}
		if (obj)
			objmodel << obj;
		else if (!obj_list.isEmpty())
		{
			foreach (ObjectInterface *oi, obj_list)
				objmodel << oi;
		}
	}
	// TODO put in the right implementation; for now, use this for testing the interface
	objmodel << new PlatformSettings(new PlatformDevice);
}

void BtObjectsPlugin::parseConfig()
{
	QFile fh(QFileInfo(QDir(qApp->applicationDirPath()), LAYOUT_FILE).absoluteFilePath());
	QDomDocument document;
	if (!fh.exists() || !document.setContent(&fh))
		qFatal("The layout file %s does not seem a valid xml configuration file", qPrintable(QFileInfo(fh).absoluteFilePath()));
	foreach (const QDomNode &container, getChildren(document.documentElement(), "container"))
	{
		int container_id = getIntAttribute(container, "id");
		if (container_id == 2)
			parseRooms(container);
	}
}

void BtObjectsPlugin::parseRooms(const QDomNode &container)
{
	foreach (const QDomNode &instance, getChildren(container, "ist"))
	{
		QString room_name = getAttribute(instance, "descr");
		foreach (const QDomNode &link, getChildren(instance, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			int x = getIntAttribute(link, "x");
			int y = getIntAttribute(link, "y");

			// TODO: map uii to object...
			room_model << new RoomElement(room_name, objmodel.getObject(object_uii), x, y);
		}
	}
}

void BtObjectsPlugin::registerTypes(const char *uri)
{
	// @uri BtObjects
	qmlRegisterUncreatableType<ObjectListModel>(uri, 1, 0, "ObjectListModel", "");
	qmlRegisterType<FilterListModel>(uri, 1, 0, "FilterListModel");
	qmlRegisterType<RoomListModel>(uri, 1, 0, "RoomListModel");
	qmlRegisterType<DirectoryListModel>(uri, 1, 0, "DirectoryListModel");
	qmlRegisterType<UPnPListModel>(uri, 1, 0, "UPnPListModel");
	qmlRegisterUncreatableType<ObjectInterface>(
				uri, 1, 0, "ObjectInterface",
				"unable to create an ObjectInterface instance");
	qmlRegisterUncreatableType<ThermalControlUnit99Zones>(
				uri, 1, 0, "ThermalControlUnit99Zones",
				"unable to create a ThermalControlUnit99Zones instance");
	qmlRegisterUncreatableType<ThermalControlledProbe>(
				uri, 1, 0, "ThermalControlledProbe",
				"unable to create a ThermalControlledProbe instance");
	qmlRegisterUncreatableType<PlatformSettings>(
				uri, 1, 0, "PlatformSettings",
				"unable to create a PlatformSettings instance");
	qmlRegisterUncreatableType<HardwareSettings>(
				uri, 1, 0, "HardwareSettings",
				"unable to create a HardwareSettings instance");
	qmlRegisterUncreatableType<AntintrusionAlarm>(
				uri, 1, 0, "AntintrusionAlarm",
				"unable to create an AntintrusionAlarm instance");
	qmlRegisterUncreatableType<FileObject>(
				uri, 1, 0, "FileObject",
				"unable to create an FileObject instance");
	qmlRegisterUncreatableType<SourceBase>(
				uri, 1, 0, "SourceBase",
				"unable to create an SourceBase instance");
	qmlRegisterType<SplitProgram>(uri, 1, 0, "SplitProgram");
	qmlRegisterUncreatableType<EnergyLoadDiagnostic>(
				uri, 1, 0, "EnergyLoadDiagnostic",
				"unable to create an EnergyLoadDiagnostic instance");
}

Q_EXPORT_PLUGIN2(BtObjects, BtObjectsPlugin)

