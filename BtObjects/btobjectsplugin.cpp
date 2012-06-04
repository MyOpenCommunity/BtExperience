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
#include "objectmodel.h"
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
#include "objectlink.h"
#include "splitbasicscenario.h"
#include "splitadvancedscenario.h"
#include "airconditioning_device.h"
#include "scenarioobjects.h"
#include "vct.h"
#include "videodoorentry_device.h"
#include "energyload.h"
#include "stopandgoobjects.h"
#include "energydata.h"
#include "container.h"

#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
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

	global_models.setParent(this);
	room_model.setParent(this);
	floor_model.setParent(this);
	object_link_model.setParent(this);
	systems_model.setParent(this);
	objmodel.setParent(this);

	global_models.setFloors(&floor_model);
	global_models.setRooms(&room_model);
	global_models.setObjectLinks(&object_link_model);
	global_models.setSystems(&systems_model);
	global_models.setMyHomeObjects(&objmodel);

	ObjectModel::setGlobalSource(&objmodel);
	createObjectsFakeConfig(document);
	createObjects(document);
	parseConfig();
	device::initDevices();
}

void BtObjectsPlugin::createObjects(QDomDocument document)
{
	foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
	{
		QList<ObjectPair> obj_list;
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case ObjectInterface::IdLight:
			obj_list = parseLight(xml_obj);
			break;
		case ObjectInterface::IdDimmer:
			obj_list = parseDimmer(xml_obj);
			break;
		case ObjectInterface::IdDimmer100:
			obj_list = parseDimmer100(xml_obj);
			break;
		case ObjectInterface::IdLightGroup:
			obj_list = parseLightGroup(xml_obj, uii_map);
			break;
		case ObjectInterface::IdLightCommand:
			obj_list = parseLightCommand(xml_obj);
			break;
		}

		if (!obj_list.isEmpty())
		{
			foreach (ObjectPair p, obj_list)
			{
				uii_map.insert(p.first, p.second);
				objmodel.insertWithoutUii(p.second);
			}
		}
	}
}

void BtObjectsPlugin::createObjectsFakeConfig(QDomDocument document)
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
		case ObjectInterface::IdThermalControlUnit99:
			obj = new ThermalControlUnit99Zones(descr, "", bt_global::add_device_to_cache(new ThermalDevice99Zones("0")));
			break;
		case ObjectInterface::IdThermalControlUnit4:
			obj = new ThermalControlUnit4Zones(descr, "2", bt_global::add_device_to_cache(new ThermalDevice4Zones("0")));
			break;
		case ObjectInterface::IdThermalControlledProbe:
		{
			ControlledProbeDevice::ProbeType fancoil = getTextChild(item, "fancoil").toInt() == 1 ?
						ControlledProbeDevice::FANCOIL :  ControlledProbeDevice::NORMAL;
			if(fancoil == ControlledProbeDevice::NORMAL)
				obj = new ThermalControlledProbe(descr, where, new ControlledProbeDevice(where, "0", where, ControlledProbeDevice::CENTRAL_99ZONES, fancoil));
			else
				obj = new ThermalControlledProbeFancoil(descr, where, new ControlledProbeDevice(where, "0", where, ControlledProbeDevice::CENTRAL_99ZONES, fancoil));
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
		case ObjectInterface::IdEnergyData:
			obj_list = createEnergyData(item, id);
			break;
		case ObjectInterface::IdCCTV:
			obj = parseCCTV(item);
			break;
		case ObjectInterface::IdIntercom:
			obj = parseIntercom(item);
			break;
		default:
			Q_ASSERT_X(false, "BtObjectsPlugin::createObjects", qPrintable(QString("Unknown id %1").arg(id)));
		}
		if (obj)
			objmodel.insertWithoutUii(obj);
		else if (!obj_list.isEmpty())
		{
			foreach (ObjectInterface *oi, obj_list)
				objmodel.insertWithoutUii(oi);
		}
	}
	// TODO put in the right implementation; for now, use this for testing the interface
	objmodel.insertWithoutUii(new PlatformSettings(new PlatformDevice));
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

		switch (container_id)
		{
		case Container::IdRooms:
			parseRooms(container);
			break;
		case Container::IdFloors:
			parseFloors(container);
			break;
		case Container::IdLights:
			parseSystem(container);
			break;
		}
	}
}

void BtObjectsPlugin::parseRooms(const QDomNode &container)
{
	int room_id = getIntAttribute(container, "id");
	QString def_room_name = getAttribute(container, "descr");
	QString def_room_img = getAttribute(container, "img");

	foreach (const QDomNode &instance, getChildren(container, "ist"))
	{
		QString room_name = getAttribute(instance, "descr", def_room_name);
		QString room_img = getAttribute(instance, "img", def_room_img);
		int room_uii = getIntAttribute(instance, "uii");
		Container *room = new Container(room_id, room_uii, room_img, room_name);

		room_model << room;
		uii_map.insert(room_uii, room);

		foreach (const QDomNode &link, getChildren(instance, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			int x = getIntAttribute(link, "x");
			int y = getIntAttribute(link, "y");
			ObjectInterface *o = uii_map.value<ObjectInterface>(object_uii);

			if (!o)
			{
				qWarning() << "Invalid uii" << object_uii << "in room";
				continue;
			}

			ObjectLink *item = new ObjectLink(o, x, y);

			item->setContainerId(room_uii);

			object_link_model << item;
		}
	}
}

void BtObjectsPlugin::parseFloors(const QDomNode &container)
{
	QString def_floor_name = getAttribute(container, "descr");
	QString def_floor_img = getAttribute(container, "img");
	int floor_id = getIntAttribute(container, "id");

	foreach (const QDomNode &instance, getChildren(container, "ist"))
	{
		QString floor_name = getAttribute(instance, "descr", def_floor_name);
		QString floor_img = getAttribute(instance, "img", def_floor_img);
		int floor_uii = getIntAttribute(instance, "uii");
		Container *floor = new Container(floor_id, floor_uii, floor_img, floor_name);

		floor_model << floor;
		uii_map.insert(floor_uii, floor);

		foreach (const QDomNode &link, getChildren(instance, "link"))
		{
			int room_uii = getIntAttribute(link, "uii");
			Container *room = uii_map.value<Container>(room_uii);

			if (!room)
			{
				qWarning() << "Invalid uii" << room_uii << "in floor";
				continue;
			}

			room->setContainerId(floor_uii);
		}
	}
}

void BtObjectsPlugin::parseSystem(const QDomNode &container)
{
	QString def_system_name = getAttribute(container, "descr");
	QString def_system_img = getAttribute(container, "img");
	int system_id = getIntAttribute(container, "id");

	foreach (const QDomNode &ist, getChildren(container, "ist"))
	{
		QString system_name = getAttribute(ist, "descr", def_system_name);
		QString system_img = getAttribute(ist, "img", def_system_img);
		int system_uii = getIntAttribute(ist, "uii");
		Container *system = new Container(system_id, system_uii, system_img, system_name);

		systems_model << system;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			ObjectInterface *o = uii_map.value<ObjectInterface>(object_uii);

			if (!o)
			{
				qWarning() << "Invalid uii" << object_uii << "in system";
				continue;
			}

			o->setContainerId(system_uii);
		}
	}
}

void BtObjectsPlugin::initializeEngine(QDeclarativeEngine *engine, const char *uri)
{
	Q_UNUSED(uri);

	engine->rootContext()->setContextProperty("myHomeModels", &global_models);
}

void BtObjectsPlugin::registerTypes(const char *uri)
{
	// @uri BtObjects
	qmlRegisterUncreatableType<ObjectDataModel>(uri, 1, 0, "ObjectListModel", "");
	qmlRegisterUncreatableType<MediaDataModel>(uri, 1, 0, "MediaDataModel", "");
	qmlRegisterType<MediaModel>(uri, 1, 0, "MediaModel");
	qmlRegisterType<ObjectModel>(uri, 1, 0, "FilterListModel");
	qmlRegisterType<DirectoryListModel>(uri, 1, 0, "DirectoryListModel");
	qmlRegisterType<UPnPListModel>(uri, 1, 0, "UPnPListModel");
	qmlRegisterUncreatableType<ItemInterface>(
				uri, 1, 0, "ItemInterface",
				"unable to create an ItemInterface instance");
	qmlRegisterUncreatableType<Container>(
				uri, 1, 0, "Container",
				"unable to create an Container instance");
	qmlRegisterUncreatableType<ObjectInterface>(
				uri, 1, 0, "ObjectInterface",
				"unable to create an ObjectInterface instance");
	qmlRegisterUncreatableType<ThermalControlUnit99Zones>(
				uri, 1, 0, "ThermalControlUnit99Zones",
				"unable to create a ThermalControlUnit99Zones instance");
	qmlRegisterUncreatableType<ThermalControlledProbe>(
				uri, 1, 0, "ThermalControlledProbe",
				"unable to create a ThermalControlledProbe instance");
	qmlRegisterUncreatableType<ThermalControlledProbeFancoil>(
				uri, 1, 0, "ThermalControlledProbeFancoil",
				"unable to create a ThermalControlledProbeFancoil instance");
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
	qmlRegisterUncreatableType<EnergyLoadManagement>(
				uri, 1, 0, "EnergyLoadDiagnostic",
				"unable to create an EnergyLoadDiagnostic instance");
	qmlRegisterUncreatableType<StopAndGo>(
				uri, 1, 0, "StopAndGo",
				"unable to create an StopAndGo instance");
	qmlRegisterUncreatableType<EnergyData>(
				uri, 1, 0, "EnergyData",
				"unable to create an EnergyData instance");
}

Q_EXPORT_PLUGIN2(BtObjects, BtObjectsPlugin)

