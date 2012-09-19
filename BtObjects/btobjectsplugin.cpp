#include "btobjectsplugin.h"
#include "openclient.h"
#include "main.h"
#include "device.h"
#include "objectmodel.h"
#include "lightobjects.h"
#include "automationobjects.h"
#include "thermalobjects.h"
#include "thermalprobes.h"
#include "antintrusionsystem.h"
#include "mediaobjects.h"
#include "messagessystem.h"
#include "multimediaplayer.h"
#include "xml_functions.h"
#include "hardware.h"
#include "platform.h"
#include "platform_device.h"
#include "folderlistmodel.h"
#include "objectlink.h"
#include "splitbasicscenario.h"
#include "splitadvancedscenario.h"
#include "scenarioobjects.h"
#include "vct.h"
#include "energyload.h"
#include "stopandgoobjects.h"
#include "energydata.h"
#include "container.h"
#include "medialink.h"
#include "note.h"
#include "choicelist.h"
#include "energyrate.h"
#include "xmlobject.h"

#include <qdeclarative.h> // qmlRegisterUncreatableType
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QCoreApplication> // qApp
#include <QDomNode>


#define DEVICE_FILE "device.xml"
#define CONF_FILE "conf.xml"
#define LAYOUT_FILE "layout.xml"
#define NOTES_FILE "notes.xml"

QHash<GlobalField, QString> *bt_global::config;


namespace
{
	template<class Tr>
	QList<Tr> convertObjectPairList(QList<ObjectPair> pairs)
	{
		QList<Tr> res;

		foreach (const ObjectPair &pair, pairs)
		{
			Tr r = qobject_cast<Tr>(pair.second);

			Q_ASSERT_X(r, "convertObjectPairList", "Invalid object type");

			if (r)
				res.append(r);
		}

		return res;
	}

	void createMediaLink(QDomDocument archive, int uii, MediaLink *obj_media)
	{
		foreach (QDomNode xml_obj, getChildren(archive.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == obj_media->getType())
			{
				QDomElement obj_node = archive.createElement("ist");

				obj_node.setAttribute("uii", uii);
				obj_node.setAttribute("descr", obj_media->getName());
				obj_node.setAttribute("url", obj_media->getAddress());

				xml_obj.appendChild(obj_node);
				break;
			}
		}
	}

	QDomElement createLink(QDomNode parent, int uii)
	{
		QDomElement link_node = parent.ownerDocument().createElement("link");

		link_node.setAttribute("uii", uii);
		parent.appendChild(link_node);

		return link_node;
	}

	template<class T>
	void createLink(QDomNode parent, int uii, T *obj)
	{
		QDomElement link_node = createLink(parent, uii);

		link_node.setAttribute("x", obj->getPosition().x());
		link_node.setAttribute("y", obj->getPosition().y());
	}

	// these are defined here because there is no 1-to-1 correspondence
	// between used in QML (the ones in objectinterface.h file) and the ones
	// used in configuration file (defined here)
	enum ParserConstants
	{
		IdDimmer100 = 2002,
		IdLight = 2003
	};
}


BtObjectsPlugin::BtObjectsPlugin(QObject *parent) : QDeclarativeExtensionPlugin(parent)
{
	// for logging
	QString errorMsg;
	int errorLine, errorColumn;
	QFile fh(QFileInfo(QDir(qApp->applicationDirPath()), CONF_FILE).absoluteFilePath());
	if (!fh.exists() || !archive.setContent(&fh, &errorMsg, &errorLine, &errorColumn)) {
		QString msg = QString("The config file %1 does not seem a valid xml configuration file: Error description: %2, line: %3, column: %4").arg(qPrintable(QFileInfo(fh).absoluteFilePath())).arg(errorMsg).arg(errorLine).arg(errorColumn);
		qFatal("%s", qPrintable(msg));
	}

	bt_global::config = new QHash<GlobalField, QString>();

	parseDevice();

	MultiMediaPlayer::setGlobalCommandLineArguments("mplayer", QStringList(), QStringList());

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
	note_model.setParent(this);

	global_models.setFloors(&floor_model);
	global_models.setRooms(&room_model);
	global_models.setObjectLinks(&object_link_model);
	global_models.setSystems(&systems_model);
	global_models.setMyHomeObjects(&objmodel);
	global_models.setNotes(&note_model);
	global_models.setProfiles(&profile_model);
	global_models.setMediaLinks(&media_link_model);

	ObjectModel::setGlobalSource(&objmodel);
	createObjectsFakeConfig(archive);
	createObjects(archive);
	parseConfig();

	QList<MediaDataModel *> models = QList<MediaDataModel *>()
			<< &room_model << &floor_model << &object_link_model << &systems_model
			<< &objmodel << &profile_model << &media_link_model;

	foreach (MediaDataModel *model, models)
	{
		model->setParent(this);
		connect(model, SIGNAL(persistItem(ItemInterface*)), this, SLOT(updateObject(ItemInterface*)));
		connect(model, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SLOT(insertObjects(QModelIndex,int,int)));
		connect(model, SIGNAL(rowsAboutToBeRemoved(QModelIndex,int,int)), this, SLOT(removeObjects(QModelIndex,int,int)));
	}

	connect(&note_model, SIGNAL(persistItem(ItemInterface*)), this, SLOT(updateNotes()));
	connect(&note_model, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SLOT(updateNotes()));
	connect(&note_model, SIGNAL(rowsRemoved(QModelIndex,int,int)), this, SLOT(updateNotes()));

	device::initDevices();
}

void BtObjectsPlugin::parseDevice()
{
	QDomDocument device;
	// for logging
	QString errorMsg;
	int errorLine, errorColumn;
	QFile fh(QFileInfo(QDir(qApp->applicationDirPath()), DEVICE_FILE).absoluteFilePath());
	if (!fh.exists() || !device.setContent(&fh, &errorMsg, &errorLine, &errorColumn)) {
		QString msg = QString("The config file %1 does not seem a valid xml configuration file: Error description: %2, line: %3, column: %4").arg(qPrintable(QFileInfo(fh).absoluteFilePath())).arg(errorMsg).arg(errorLine).arg(errorColumn);
		qFatal("%s", qPrintable(msg));
	}

	QHash<QString, QString> values;

	foreach (QDomNode category, getChildren(device.documentElement(), "category"))
	{
		QString category_name = getAttribute(category, "name");

		foreach (QDomNode par, getChildren(category, "par"))
		{
			QString par_name = getAttribute(par, "name");

			values[category_name + "/" + par_name] = par.toElement().text().trimmed();
		}
	}

	(*bt_global::config)[SOURCE_ADDRESS] = values.value("scs/mymmaddress", "-1");
	(*bt_global::config)[AMPLIFIER_ADDRESS] = values.value("scs/myaaddress", "-1");
	// TODO check par name
	(*bt_global::config)[TS_NUMBER] = values.value("scs/diag_addr", "0");

	if ((*bt_global::config)[SOURCE_ADDRESS] == "-1")
		(*bt_global::config)[SOURCE_ADDRESS] = "";
	if ((*bt_global::config)[AMPLIFIER_ADDRESS] == "-1")
		(*bt_global::config)[AMPLIFIER_ADDRESS] = "";
}

void BtObjectsPlugin::createObjects(QDomDocument document)
{
	QList<AntintrusionZone *> antintrusion_zones;
	QList<AntintrusionAlarmSource *> antintrusion_aux;
	QList<AntintrusionScenario *> antintrusion_scenarios;
	QHash<int, QPair<QDomNode, QDomNode> > probe4zones, splitcommands;

	foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
	{
		QList<ObjectPair> obj_list;
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case IdLight:
			obj_list = parseLight(xml_obj);
			break;
		case ObjectInterface::IdDimmerFixed:
			obj_list = parseDimmer(xml_obj);
			break;
		case IdDimmer100:
			obj_list = parseDimmer100(xml_obj);
			break;
		case ObjectInterface::IdLightGroup:
			obj_list = parseLightGroup(xml_obj, uii_map);
			break;
		case ObjectInterface::IdLightCommand:
			obj_list = parseLightCommand(xml_obj);
			break;

		case ObjectInterface::IdAutomation2:
		case ObjectInterface::IdAutomationDoor:
		case ObjectInterface::IdAutomationContact:
			obj_list = parseAutomation2(xml_obj);
			break;
		case ObjectInterface::IdAutomationVDE:
			obj_list = parseAutomation2(xml_obj);
			break;
		case ObjectInterface::IdAutomation3:
			obj_list = parseAutomation3(xml_obj);
			break;
		case ObjectInterface::IdAutomationGroup2:
			obj_list = parseAutomationGroup2(xml_obj, uii_map);
			break;
		case ObjectInterface::IdAutomationGroup3:
			obj_list = parseAutomationGroup3(xml_obj, uii_map);
			break;
		case ObjectInterface::IdAutomationCommand2:
			obj_list = parseAutomationCommand2(xml_obj);
			break;
		case ObjectInterface::IdAutomationCommand3:
			obj_list = parseAutomationCommand3(xml_obj);
			break;

		case ObjectInterface::IdAntintrusionZone:
			obj_list = parseAntintrusionZone(xml_obj);
			antintrusion_zones = convertObjectPairList<AntintrusionZone *>(obj_list);
			break;
		case ObjectInterface::IdAntintrusionAux:
			obj_list = parseAntintrusionAux(xml_obj);
			antintrusion_aux = convertObjectPairList<AntintrusionAlarmSource *>(obj_list);
			break;
		case ObjectInterface::IdAntintrusionScenario:
			obj_list = parseAntintrusionScenario(xml_obj, uii_map, antintrusion_zones);
			antintrusion_scenarios = convertObjectPairList<AntintrusionScenario *>(obj_list);
			break;

		case ObjectInterface::IdThermalControlUnit99:
			obj_list = parseControlUnit99(xml_obj);
			break;
		case ObjectInterface::IdThermalControlUnit4:
			obj_list = parseControlUnit4(xml_obj, probe4zones);
			break;
		case ObjectInterface::IdThermalControlledProbe99:
			obj_list = parseZone99(xml_obj);
			break;
		case ObjectInterface::IdThermalControlledProbe4Zone1:
		case ObjectInterface::IdThermalControlledProbe4Zone2:
		case ObjectInterface::IdThermalControlledProbe4Zone3:
		case ObjectInterface::IdThermalControlledProbe4Zone4:
			foreach (const QDomNode &ist, getChildren(xml_obj, "ist"))
				probe4zones[getIntAttribute(ist, "uii")] = qMakePair(xml_obj, ist);
			break;
		case ObjectInterface::IdThermalExternalProbe:
			obj_list = parseExternalNonControlledProbes(xml_obj, ObjectInterface::IdThermalExternalProbe);
			break;
		case ObjectInterface::IdThermalNonControlledProbe:
			obj_list = parseExternalNonControlledProbes(xml_obj, ObjectInterface::IdThermalNonControlledProbe);
			break;

		case ObjectInterface::IdSplitBasicScenario:
			obj_list = parseSplitBasicScenario(xml_obj);
			break;
		case ObjectInterface::IdSplitAdvancedScenario:
			obj_list = parseSplitAdvancedScenario(xml_obj);
			break;
		case ObjectInterface::IdSplitBasicCommand:
			// updates program list in basic split
			parseSplitBasicCommand(xml_obj, uii_map);
			break;
		case ObjectInterface::IdSplitAdvancedCommand:
			// updates program list in advanced split
			parseSplitAdvancedCommand(xml_obj, uii_map);
			break;
		case ObjectInterface::IdSplitBasicGenericCommand:
		case ObjectInterface::IdSplitAdvancedGenericCommand:
			foreach (const QDomNode &ist, getChildren(xml_obj, "ist"))
				splitcommands[getIntAttribute(ist, "uii")] = qMakePair(xml_obj, ist);
			break;
		case ObjectInterface::IdSplitBasicGenericCommandGroup:
			obj_list = parseSplitBasicCommandGroup(xml_obj, splitcommands);
			break;
		case ObjectInterface::IdSplitAdvancedGenericCommandGroup:
			obj_list = parseSplitAdvancedCommandGroup(xml_obj, splitcommands);
			break;

		case ObjectInterface::IdStopAndGo:
			obj_list = parseStopAndGo(xml_obj);
			break;
		case ObjectInterface::IdStopAndGoPlus:
			obj_list = parseStopAndGoPlus(xml_obj);
			break;
		case ObjectInterface::IdStopAndGoBTest:
			obj_list = parseStopAndGoBTest(xml_obj);
			break;
		case ObjectInterface::IdLoadDiagnostic:
			obj_list = parseLoadDiagnostic(xml_obj);
			break;
		case ObjectInterface::IdLoadWithControlUnit:
			obj_list = parseLoadWithCU(xml_obj);
			break;
		case ObjectInterface::IdLoadWithoutControlUnit:
			obj_list = parseLoadWithoutCU(xml_obj);
			break;
		case ObjectInterface::IdEnergyData:
			objmodel << new EnergyFamily(getAttribute(xml_obj, "descr"));
			obj_list = parseEnergyData(xml_obj);
			break;

		case ObjectInterface::IdSimpleScenario:
			obj_list = parseScenarioUnit(xml_obj);
			break;
		case ObjectInterface::IdScenarioModule:
			obj_list = parseScenarioModule(xml_obj);
			break;
		case ObjectInterface::IdScheduledScenario:
			obj_list = parseScheduledScenario(xml_obj);
			break;
		case ObjectInterface::IdAdvancedScenario:
			obj_list = parseAdvancedScenario(xml_obj);
			break;

		case ObjectInterface::IdSurveillanceCamera:
			// TODO this needs to be added to the list in CCTV object, but it can only be done once
			//      VCT configuration is finalized; surveillance cameras must be in UII map because
			//      they can be linked in profile page
			obj_list = parseVdeCamera(xml_obj);
			break;

		case ObjectInterface::IdIpRadio:
			obj_list = parseIpRadio(xml_obj);
			break;

		case ObjectInterface::IdMessages:
			objmodel << parseMessageObject(xml_obj);
			break;

		case MediaLink::Rss:
		case MediaLink::Web:
		case MediaLink::Webcam:
			parseMediaLinks(xml_obj);
			break;
		}

		if (!obj_list.isEmpty())
		{
			foreach (ObjectPair p, obj_list)
			{
				uii_map.insert(p.first, p.second);
				uii_to_id[p.first] = id;
				objmodel << p.second;
			}
		}
	}

	if (antintrusion_zones.size())
		objmodel << createAntintrusionSystem(antintrusion_zones, antintrusion_aux, antintrusion_scenarios);
}

int BtObjectsPlugin::findLinkedUiiForObject(ItemInterface *item) const
{
	MediaLink *obj_media = qobject_cast<MediaLink *>(item);
	ObjectLink *obj_link = qobject_cast<ObjectLink *>(item);
	QObject *key = 0;

	Q_ASSERT_X(obj_media || obj_link, "BtObjectsPlugin::findLinkedUiiForObject",
		   "Can only find linked UII for link-type objects");

	if (obj_link)
		key = obj_link->getBtObject();
	else
		key = obj_media;

	int uii = uii_map.findUii(key);
	if (uii == -1)
		qWarning() << "Can't get link UII from object" << item;

	return uii;
}

QPair<QDomNode, QString> BtObjectsPlugin::findNodeForObject(ItemInterface *item) const
{
	MediaLink *obj_media = qobject_cast<MediaLink *>(item);
	ObjectLink *obj_link = qobject_cast<ObjectLink *>(item);

	if (obj_media || obj_link)
	{
		QPair<QDomNode, QString> container_path = findNodeForUii(item->getContainerId());
		int uii = findLinkedUiiForObject(item);

		if (uii == -1)
			return QPair<QDomNode, QString>();

		foreach (QDomNode child, getChildren(container_path.first, "link"))
		{
			if (getAttribute(child, "uii", "-1").toInt() == uii)
				return QPair<QDomNode, QString>(child, LAYOUT_FILE);
		}

		qWarning() << "Could not find XML link node for uii" << uii << "in document" << container_path.second;

		return QPair<QDomNode, QString>();
	}
	else
	{
		int uii = uii_map.findUii(item);
		if (uii == -1)
		{
			qWarning() << "Object" << item << "is not in uii_map";
			return QPair<QDomNode, QString>();
		}

		return findNodeForUii(uii);
	}
}

QDomDocument BtObjectsPlugin::findDocumentForId(int id) const
{
	switch (id)
	{
	case Container::IdRooms:
	case Container::IdFloors:
	case Container::IdProfile:
	case Container::IdScenarios:
	case Container::IdLights:
	case Container::IdAutomation:
	case Container::IdAirConditioning:
	case Container::IdLoadControl:
	case Container::IdSupervision:
	case Container::IdEnergyData:
	case Container::IdThermalRegulation:
	case Container::IdVideoDoorEntry:
	case Container::IdSoundDiffusion:
	case Container::IdAntintrusion:
	case Container::IdSettings:
	case Container::IdMessages:
		return layout;
	default:
		return archive;
	}
}

QPair<QDomNode, QString> BtObjectsPlugin::findNodeForUii(int uii) const
{
	if (!uii_to_id.contains(uii))
	{
		qWarning() << "Unknown id for uii:" << uii;
		return QPair<QDomNode, QString>();
	}

	int id = uii_to_id[uii];
	QDomDocument document = findDocumentForId(id);
	QString conf_name = document.documentElement().tagName() == "archive" ? CONF_FILE : LAYOUT_FILE;
	QString child_name = document.documentElement().tagName() == "archive" ? "obj" : "container";

	foreach (QDomNode xml_obj, getChildren(document.documentElement(), child_name))
	{
		if (getIntAttribute(xml_obj, "id") == id)
		{
			foreach (QDomNode xml_ist, getChildren(xml_obj, "ist"))
			{
				if (uii == getIntAttribute(xml_ist, "uii"))
					return QPair<QDomNode, QString>(xml_ist, conf_name);
			}
		}
	}

	qWarning() << "Could not find XML node for uii" << uii << "in document" << conf_name;

	return QPair<QDomNode, QString>();
}

void BtObjectsPlugin::saveConfigFile(QDomDocument document, QString name)
{
	QString filename = QFileInfo(QDir(qApp->applicationDirPath()), name).absoluteFilePath();
	if (!saveXml(document, filename))
		qWarning() << "Error saving the config file" << filename;
	else
		qDebug() << "Config file" << filename << "saved";
}

void BtObjectsPlugin::updateObject(ItemInterface *obj)
{
	qDebug() << "BtObjectsPlugin::updateObject" << obj;
	QPair<QDomNode, QString> node_path = findNodeForObject(obj);

	if (node_path.first.isNull())
		return;

	ObjectInterface *obj_int = qobject_cast<ObjectInterface *>(obj);
	Container *obj_cont = qobject_cast<Container *>(obj);
	MediaLink *obj_media = qobject_cast<MediaLink *>(obj);

	if (obj_int)
	{
		// TODO energy, scenarios, other specialized systems
		updateObjectName(node_path.first, obj_int);
	}
	else if (obj_cont)
	{
		updateContainerNameImage(node_path.first, obj_cont);
	}
	else if (obj_media)
	{
		// TODO special case for cameras (need to update link UII using where as search key)
		QPair<QDomNode, QString> archive_path = findNodeForUii(findLinkedUiiForObject(obj));

		updateMediaNameAddress(archive_path.first, obj_media);
		updateMediaPosition(node_path.first, obj_media);

		saveConfigFile(archive, archive_path.second);
	}
	else
	{
		qWarning() << "Unknown object type" << obj;
	}

	saveConfigFile(node_path.first.ownerDocument(), node_path.second);
}

void BtObjectsPlugin::insertObject(ItemInterface *obj)
{
	qDebug() << "BtObjectsPlugin::insertObject" << obj;
	QPair<QDomNode, QString> container_path = findNodeForUii(obj->getContainerId());
	int uii = -1;

	ObjectLink *obj_link = qobject_cast<ObjectLink *>(obj);
	MediaLink *obj_media = qobject_cast<MediaLink *>(obj);

	// TODO camera links need special treatment to map SCS address to camera UII
	if (obj_media && obj_media->getType() != MediaLink::Camera)
	{
		uii = uii_map.nextUii();
		uii_map.insert(uii, obj_media);
		uii_to_id[uii] = obj_media->getType();

		createMediaLink(archive, uii, obj_media);
		saveConfigFile(archive, CONF_FILE);
	}
	else
		uii = findLinkedUiiForObject(obj);

	if (uii == -1 || container_path.first.isNull())
		return;

	if (obj_link)
		createLink(container_path.first, uii, obj_link);
	else if (obj_media)
		createLink(container_path.first, uii, obj_media);
	else
		createLink(container_path.first, uii);

	saveConfigFile(container_path.first.ownerDocument(), container_path.second);
}

void BtObjectsPlugin::removeObject(ItemInterface *obj)
{
	qDebug() << "BtObjectsPlugin::removeObject" << obj;
	QPair<QDomNode, QString> container_path = findNodeForUii(obj->getContainerId());
	int uii = findLinkedUiiForObject(obj);

	if (uii == -1 || container_path.first.isNull())
		return;

	MediaLink *obj_media = qobject_cast<MediaLink *>(obj);

	// profile media links need to be removed both in archive.xml and in layout.xml
	if (obj_media && obj_media->getType() != MediaLink::Camera)
	{
		QPair<QDomNode, QString> ist_path = findNodeForUii(uii);

		if (ist_path.first.isNull())
			qFatal("Can't find item node for uii %d", uii);

		ist_path.first.parentNode().removeChild(ist_path.first);

		saveConfigFile(ist_path.first.ownerDocument(), ist_path.second);
	}

	foreach (QDomNode child, getChildren(container_path.first, "link"))
	{
		if (getAttribute(child, "uii", "-1").toInt() == uii)
		{
			container_path.first.removeChild(child);
			break;
		}
	}

	saveConfigFile(container_path.first.ownerDocument(), container_path.second);
}

void BtObjectsPlugin::insertObjects(QModelIndex parent, int start, int end)
{
	Q_UNUSED(parent);

	const MediaDataModel *model = qobject_cast<const MediaDataModel *>(sender());
	Q_ASSERT_X(model, "BtObjectsPlugin::insertObjects", "Invalid model instance");

	for (int i = start; i <= end; ++i)
		insertObject(model->getObject(i));
}

void BtObjectsPlugin::removeObjects(QModelIndex parent, int start, int end)
{
	Q_UNUSED(parent);

	const MediaDataModel *model = qobject_cast<const MediaDataModel *>(sender());
	Q_ASSERT_X(model, "BtObjectsPlugin::removeObjects", "Invalid model instance");

	for (int i = start; i <= end; ++i)
		removeObject(model->getObject(i));
}

void BtObjectsPlugin::updateNotes()
{
	saveNotes(QFileInfo(QDir(qApp->applicationDirPath()), NOTES_FILE).absoluteFilePath(), &note_model);
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
		case ObjectInterface::IdHardwareSettings:
			obj = new HardwareSettings;
			break;
		case ObjectInterface::IdMultiChannelSoundDiffusionSystem:
			obj_list = createSoundDiffusionSystem(item, id);
			break;
		case ObjectInterface::IdMonoChannelSoundDiffusionSystem:
			obj_list = createSoundDiffusionSystem(item, id);
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
	// for logging
	QString errorMsg;
	int errorLine, errorColumn;
	QFile fh(QFileInfo(QDir(qApp->applicationDirPath()), LAYOUT_FILE).absoluteFilePath());
	if (!fh.exists() || !layout.setContent(&fh, &errorMsg, &errorLine, &errorColumn)) {
		QString msg = QString("The config file %1 does not seem a valid xml configuration file: Error description: %2, line: %3, column: %4").arg(qPrintable(QFileInfo(fh).absoluteFilePath())).arg(errorMsg).arg(errorLine).arg(errorColumn);
		qFatal("%s", qPrintable(msg));
	}

	foreach (const QDomNode &container, getChildren(layout.documentElement(), "container"))
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
		case Container::IdProfile:
			parseProfiles(container);
			break;
		case Container::IdScenarios:
		case Container::IdLights:
		case Container::IdAutomation:
		case Container::IdAirConditioning:
		case Container::IdLoadControl:
		case Container::IdSupervision:
		case Container::IdEnergyData:
		case Container::IdThermalRegulation:
		case Container::IdVideoDoorEntry:
		case Container::IdSoundDiffusion:
		case Container::IdAntintrusion:
		case Container::IdSettings:
		case Container::IdMessages:
			parseSystem(container);
			break;
		}
	}

	parseNotes(QFileInfo(QDir(qApp->applicationDirPath()), NOTES_FILE).absoluteFilePath(), &note_model);
}

void BtObjectsPlugin::parseMediaLinks(const QDomNode &xml_obj)
{
	XmlObject v(xml_obj);
	int id = getIntAttribute(xml_obj, "id");

	foreach (const QDomNode &ist, getChildren(xml_obj, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		// container and position are filled in when parsing containers
		MediaLink *l = new MediaLink(-1, static_cast<MediaLink::MediaType>(id), v.value("descr"), v.value("url"), QPoint());

		media_link_model << l;
		uii_map.insert(uii, l);
		uii_to_id[uii] = id;
	}
}

void BtObjectsPlugin::parseRooms(const QDomNode &container)
{
	XmlObject v(container);
	int room_id = getIntAttribute(container, "id");

	foreach (const QDomNode &instance, getChildren(container, "ist"))
	{
		v.setIst(instance);
		int room_uii = getIntAttribute(instance, "uii");
		Container *room = new Container(room_id, room_uii, v.value("img"), v.value("descr"));

		room_model << room;
		uii_map.insert(room_uii, room);
		uii_to_id[room_uii] = room_id;

		foreach (const QDomNode &link, getChildren(instance, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			int x = getIntAttribute(link, "x");
			int y = getIntAttribute(link, "y");
			ObjectInterface *o = uii_map.value<ObjectInterface>(object_uii);

			if (!o)
			{
				qWarning() << "Invalid uii" << object_uii << "in room";
				Q_ASSERT_X(false, "parseRooms", "Invalid uii");
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
	XmlObject v(container);
	int floor_id = getIntAttribute(container, "id");

	foreach (const QDomNode &instance, getChildren(container, "ist"))
	{
		v.setIst(instance);
		int floor_uii = getIntAttribute(instance, "uii");
		Container *floor = new Container(floor_id, floor_uii, v.value("img"), v.value("descr"));

		floor_model << floor;
		uii_map.insert(floor_uii, floor);
		uii_to_id[floor_uii] = floor_id;

		foreach (const QDomNode &link, getChildren(instance, "link"))
		{
			int room_uii = getIntAttribute(link, "uii");
			Container *room = uii_map.value<Container>(room_uii);

			if (!room)
			{
				qWarning() << "Invalid uii" << room_uii << "in floor";
				Q_ASSERT_X(false, "parseFloors", "Invalid uii");
				continue;
			}

			room->setContainerId(floor_uii);
		}
	}
}

void BtObjectsPlugin::parseProfiles(const QDomNode &container)
{
	XmlObject v(container);
	int profile_id = getIntAttribute(container, "id");

	foreach (const QDomNode &ist, getChildren(container, "ist"))
	{
		v.setIst(ist);
		int profile_uii = getIntAttribute(ist, "uii");
		Container *profile = new Container(profile_id, profile_uii, v.value("img"), v.value("descr"));

		profile_model << profile;
		uii_map.insert(profile_uii, profile);
		uii_to_id[profile_uii] = profile_id;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int link_uii = getIntAttribute(link, "uii");
			MediaLink *l = uii_map.value<MediaLink>(link_uii);
			ExternalPlace *c = uii_map.value<ExternalPlace>(link_uii);
			QPoint pos(getIntAttribute(link, "x"), getIntAttribute(link, "y"));

			if (l)
			{
				l->setContainerId(profile_uii);
				l->setPosition(pos);
			}
			else if (c)
			{
				// for surveillance cameras, create a media link object on the fly using
				// the data from the camera object (we could add a proxy class, but this is simpler)
				l = new MediaLink(profile_uii, MediaLink::Camera, c->getName(), c->getWhere(), pos);
				media_link_model << l;
			}
			else
			{
				qWarning() << "Invalid uii" << link_uii << "in profile";
				Q_ASSERT_X(false, "parseProfiles", "Invalid uii");
				continue;
			}
		}
	}
}

void BtObjectsPlugin::parseSystem(const QDomNode &container)
{
	XmlObject v(container);
	int system_id = getIntAttribute(container, "id");

	foreach (const QDomNode &ist, getChildren(container, "ist"))
	{
		v.setIst(ist);
		int system_uii = getIntAttribute(ist, "uii");
		Container *system = new Container(system_id, system_uii, v.value("img"), v.value("descr"));

		systems_model << system;
		uii_map.insert(system_uii, system);
		uii_to_id[system_uii] = system_id;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			ObjectInterface *o = uii_map.value<ObjectInterface>(object_uii);

			if (!o)
			{
				qWarning() << "Invalid uii" << object_uii << "in system";
				Q_ASSERT_X(false, "parseSystem", "Invalid uii");
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
	qmlRegisterType<ObjectModel>(uri, 1, 0, "ObjectModel");
	qmlRegisterType<DirectoryListModel>(uri, 1, 0, "DirectoryListModel");
	qmlRegisterType<UPnPListModel>(uri, 1, 0, "UPnPListModel");
	qmlRegisterUncreatableType<ItemInterface>(uri, 1, 0, "ItemInterface",
		"unable to create an ItemInterface instance");
	qmlRegisterUncreatableType<Container>(uri, 1, 0, "Container",
		"unable to create an Container instance");
	qmlRegisterUncreatableType<Note>(uri, 1, 0, "Note",
		"unable to create a Note instance");
	qmlRegisterUncreatableType<MediaLink>(uri, 1, 0, "MediaLink",
		"unable to create a MediaLink instance");
	qmlRegisterUncreatableType<ObjectInterface>(uri, 1, 0, "ObjectInterface",
		"unable to create an ObjectInterface instance");
	qmlRegisterUncreatableType<ThermalControlUnit99Zones>(uri, 1, 0, "ThermalControlUnit99Zones",
		"unable to create a ThermalControlUnit99Zones instance");
	qmlRegisterUncreatableType<ThermalControlUnit>(uri, 1, 0, "ThermalControlUnit",
		"unable to create a ThermalControlUnit instance");
	qmlRegisterUncreatableType<ThermalControlledProbe>(uri, 1, 0, "ThermalControlledProbe",
		"unable to create a ThermalControlledProbe instance");
	qmlRegisterUncreatableType<ThermalControlledProbeFancoil>(uri, 1, 0, "ThermalControlledProbeFancoil",
		"unable to create a ThermalControlledProbeFancoil instance");
	qmlRegisterUncreatableType<PlatformSettings>(uri, 1, 0, "PlatformSettings",
		"unable to create a PlatformSettings instance");
	qmlRegisterUncreatableType<HardwareSettings>(uri, 1, 0, "HardwareSettings",
		"unable to create a HardwareSettings instance");
	qmlRegisterUncreatableType<AntintrusionAlarm>(uri, 1, 0, "AntintrusionAlarm",
		"unable to create an AntintrusionAlarm instance");
	qmlRegisterUncreatableType<FileObject>(uri, 1, 0, "FileObject",
		"unable to create a FileObject instance");
	qmlRegisterUncreatableType<SourceBase>(uri, 1, 0, "SourceBase",
		"unable to create a SourceBase instance");
	qmlRegisterUncreatableType<SourceObject>(uri, 1, 0, "SourceObject",
		"unable to create an SourceObject instance");
	qmlRegisterUncreatableType<MultiMediaPlayer>(uri, 1, 0, "MultiMediaPlayer",
		"unable to create a MultiMediaPlayer instance");
	qmlRegisterUncreatableType<SplitAdvancedProgram>(uri, 1, 0, "SplitAdvancedProgram",
		"unable to create a SplitAdvancedProgram instance");
	qmlRegisterUncreatableType<EnergyLoadManagement>(uri, 1, 0, "EnergyLoadDiagnostic",
		"unable to create an EnergyLoadDiagnostic instance");
	qmlRegisterUncreatableType<StopAndGo>(uri, 1, 0, "StopAndGo",
		"unable to create a StopAndGo instance");
	qmlRegisterUncreatableType<EnergyData>(uri, 1, 0, "EnergyData",
		"unable to create an EnergyData instance");
	qmlRegisterUncreatableType<EnergyRate>(uri, 1, 0, "EnergyRate",
		"unable to create an EnergyRate instance");
	qmlRegisterUncreatableType<Light>(uri, 1, 0, "Light",
		"unable to create a Light instance");
	qmlRegisterUncreatableType<ChoiceList>(uri, 1, 0, "ChoiceList",
		"unable to create a ChoiceList instance");
	qmlRegisterUncreatableType<ScenarioModule>(uri, 1, 0, "ScenarioModule",
		"unable to create a ScenarioModule instance");
	qmlRegisterUncreatableType<DeviceConditionObject>(uri, 1, 0, "DeviceConditionObject",
		"unable to create a DeviceConditionObject instance");
	qmlRegisterUncreatableType<MessagesSystem>(uri, 1, 0, "MessagesSystem", "");
}

Q_EXPORT_PLUGIN2(BtObjects, BtObjectsPlugin)

