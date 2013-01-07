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
#include "mediaplayer.h"
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
#include "devices_cache.h"
#include "dangers.h"
#include "scenariomodulesnotifier.h"
#include "energies.h"
#include "configfile.h"
#include "playlistplayer.h"
#include "alarmclock.h"
#include "mounts.h"
#include "alarmclocknotifier.h"
#include "screenstate.h"
#include "calibration.h"

#include <qdeclarative.h> // qmlRegisterUncreatableType
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QFileInfo>
#include <QDir>
#include <QCoreApplication> // qApp
#include <QDomNode>

#if defined(BT_HARDWARE_X11)
#define NOTES_FILE "notes.xml"
#define CONF_LOADED "BtExperience_checkconfok"
#else
#define NOTES_FILE "/home/bticino/cfg/extra/0/notes.xml"
#define CONF_LOADED "/var/tmp/flags/BTouch_checkconfok"
#endif

QHash<GlobalField, QString> *bt_global::config;


namespace
{
	void createFlagFile(QString filename)
	{
#if defined(BT_HARDWARE_X11)
		Q_UNUSED(filename);
#else
		QFile fh(filename);

		if (!fh.open(QFile::WriteOnly))
			qWarning("unable to create flag file");
#endif
	}

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

	void createContainer(QDomDocument layout, int uii, Container *obj_container)
	{
		foreach (QDomNode xml_obj, getChildren(layout.documentElement(), "container"))
		{
			if (getIntAttribute(xml_obj, "id") == obj_container->getContainerId())
			{
				QDomElement obj_node = layout.createElement("ist");

				obj_node.setAttribute("uii", uii);
				obj_node.setAttribute("descr", obj_container->getDescription());
				obj_node.setAttribute("img", obj_container->getImage());

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

	void createLinkHomepage(QDomNode parent, int uii)
	{
		QDomElement link_node = createLink(parent, uii);

		link_node.setAttribute("img", "");
	}

	template<class T>
	void createLink(QDomNode parent, int uii, T *obj)
	{
		QDomElement link_node = createLink(parent, uii);

		link_node.setAttribute("x", obj->getPosition().x());
		link_node.setAttribute("y", obj->getPosition().y());
	}

	QList<SourceObject *> getSoundSources(const ObjectDataModel &objects)
	{
		QList<SourceObject *> sources;

		for (int i = 0; i < objects.getCount(); ++i)
		{
			SourceObject *s = qobject_cast<SourceObject *>(objects.getObject(i));

			if (s)
				sources.append(s);
		}

		return sources;
	}

	// these are defined here because there is no 1-to-1 correspondence
	// between used in QML (the ones in objectinterface.h file) and the ones
	// used in configuration file (defined here)
	enum ParserConstants
	{
		IdDimmer100 = 2002,
		IdLight = 2003,
		IdEnergyElectricity = 6105,
		IdEnergyWater = 6106,
		IdEnergyGas = 6107,
		IdEnergyDomesticHotWater = 6108,
		IdEnergyHeatingCooling = 6109,
		IdEnergyCustom = 6110,
		IdHandsFree = 14251,
		IdProfessionalStudio = 14252,
		IdRingExclusion = 14253,
		IdVideoSettings = 14268,
	};
}


BtObjectsPlugin::BtObjectsPlugin(QObject *parent) : QDeclarativeExtensionPlugin(parent)
{
	parseConfFile();

#if defined(BT_HARDWARE_X11)
	MultiMediaPlayer::setGlobalCommandLineArguments("mplayer", QStringList(), QStringList());
#else
	MultiMediaPlayer::setGlobalCommandLineArguments("mplayer",
							QStringList() << "-ao" << "alsa:device=plughw=0.0",
							QStringList() << "-ao" << "alsa:device=plughw=0.0");
#endif
	SoundPlayer::setGlobalCommandLineArguments("aplay", QStringList() << "<FILE_NAME>");

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

	general_ambient_uii = -1;
	configurations = new ConfigFile(this);
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
	global_models.setMediaContainers(&media_model);

	ObjectModel::setGlobalSource(&objmodel);
	createObjects();
	parseConfig();

	MountWatcher::instance()->startWatching();

	QList<MediaDataModel *> models = QList<MediaDataModel *>()
			<< &room_model << &floor_model << &object_link_model << &systems_model
			<< &objmodel << &profile_model << &media_link_model << &media_model;

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
	createFlagFile(CONF_LOADED);
}

void BtObjectsPlugin::createObjects()
{
	QDomDocument document = configurations->getConfiguration(ARCHIVE_FILE);
	QDomDocument settings = configurations->getConfiguration(SETTINGS_FILE);

	QList<AntintrusionZone *> antintrusion_zones;
	QList<AntintrusionAlarmSource *> antintrusion_aux;
	QList<AntintrusionScenario *> antintrusion_scenarios;
	QList<ObjectPair> vde, intercom;
	QHash<int, QPair<QDomNode, QDomNode> > probe4zones, splitcommands;
	QHash<int, EnergyRate *> rates;
	QDomNode cu99zones;
	QList<QDomNode> multimedia;
	bool is_multichannel = false;
	bool hands_free = false, professional_studio = false, ring_exclusion = false;
	int video_brightness = 50, video_contrast = 50, video_color = 50;

	foreach (const QDomNode &xml_obj, getChildren(settings.documentElement(), "obj"))
	{
		QList<ObjectPair> obj_list;
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case ObjectInterface::IdEnergyRate:
			obj_list = parseEnergyRate(xml_obj);

			foreach (ObjectPair p, obj_list)
			{
				EnergyRate *rate = static_cast<EnergyRate *>(p.second);

				rates[rate->getRateId()] = rate;
			}
			break;
		case IdHandsFree:
			hands_free = parseEnableFlag(xml_obj);
			break;
		case IdProfessionalStudio:
			professional_studio = parseEnableFlag(xml_obj);
			break;
		case IdRingExclusion:
			ring_exclusion = parseEnableFlag(xml_obj);
			break;
		case IdVideoSettings:
			video_brightness = parseIntSetting(xml_obj, "brightness");
			video_contrast = parseIntSetting(xml_obj, "contrast");
			video_color = parseIntSetting(xml_obj, "color");
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
		//case ObjectInterface::IdAutomationCommand2:
			//obj_list = parseAutomationCommand2(xml_obj);
			//break;
		//case ObjectInterface::IdAutomationCommand3:
			//obj_list = parseAutomationCommand3(xml_obj);
			//break;

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
			cu99zones = xml_obj;
			break;
		case ObjectInterface::IdThermalControlUnit4:
			obj_list = parseControlUnit4(xml_obj, probe4zones);
			break;
		case ObjectInterface::IdThermalControlledProbe99:
			obj_list = parseControlUnit99(cu99zones, xml_obj);
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
			obj_list = parseLoadWithCU(xml_obj, rates);
			break;
		case ObjectInterface::IdLoadWithoutControlUnit:
			obj_list = parseLoadWithoutCU(xml_obj, rates);
			break;
		case ObjectInterface::IdEnergyData:
		{
			EnergyFamily::FamilyType family;

			switch (getIntAttribute(xml_obj, "cid"))
			{
			case IdEnergyElectricity:
				family = EnergyFamily::Electricity;
				break;
			case IdEnergyWater:
				family = EnergyFamily::Water;
				break;
			case IdEnergyGas:
				family = EnergyFamily::Gas;
				break;
			case IdEnergyDomesticHotWater:
				family = EnergyFamily::DomesticHotWater;
				break;
			case IdEnergyHeatingCooling:
				family = EnergyFamily::HeatingCooling;
				break;
			case IdEnergyCustom:
				family = EnergyFamily::Custom;
				break;
			default:
				qFatal("Invalid CID value for energy data: %d\n", getIntAttribute(xml_obj, "cid"));
			}

			objmodel << new EnergyFamily(getAttribute(xml_obj, "descr"), family);
			obj_list = parseEnergyData(xml_obj, family, rates);
			break;
		}

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

		case ObjectInterface::IdExternalPlace:
			obj_list = parseExternalPlace(xml_obj);
			vde.append(obj_list);
			break;
		case ObjectInterface::IdSurveillanceCamera:
			obj_list = parseVdeCamera(xml_obj);
			vde.append(obj_list);
			break;
		case ObjectInterface::IdExternalIntercom:
			obj_list = parseExternalIntercom(xml_obj);
			intercom.append(obj_list);
			break;
		case ObjectInterface::IdInternalIntercom:
			obj_list = parseInternalIntercom(xml_obj);
			intercom.append(obj_list);
			break;
		case ObjectInterface::IdSwitchboard:
			obj_list = parseSwitchboard(xml_obj);
			break;

		case ObjectInterface::IdRadioSource:
			obj_list = parseRadioSource(xml_obj);
			break;
		case ObjectInterface::IdAuxSource:
			obj_list = parseAuxSource(xml_obj);
			break;
		case ObjectInterface::IdMultimediaSource:
			obj_list = parseMultimediaSource(xml_obj);
			break;
		case ObjectInterface::IdMonoAmplifier:
		case ObjectInterface::IdMultiAmplifier:
			is_multichannel = id == ObjectInterface::IdMultiAmplifier;
			obj_list = parseAmplifier(xml_obj, is_multichannel);
			break;
		case ObjectInterface::IdMonoAmplifierGroup:
		case ObjectInterface::IdMultiAmplifierGroup:
			obj_list = parseAmplifierGroup(xml_obj, uii_map);
			break;
		case ObjectInterface::IdMultiGeneral:
			obj_list = parseGeneralAmplifier(xml_obj, id);
			// The line below seems to assume that we can only have one general
			// amplifier, but above we allow a list of them.
			// In the end, we don't really care, since they will be always the
			// same; here we take one uii from the above.
			Q_ASSERT_X(obj_list.size() > 0, "IdMultiGeneral parsing", "You didn't define at least one ist for the general object");
			general_ambient_uii = obj_list[0].first;
			break;
		case ObjectInterface::IdMonoGeneral:
			obj_list = parseGeneralAmplifier(xml_obj, id);
			break;
		case ObjectInterface::IdMonoPowerAmplifier:
		case ObjectInterface::IdMultiPowerAmplifier:
			is_multichannel = id == ObjectInterface::IdMultiPowerAmplifier;
			obj_list = parsePowerAmplifier(xml_obj, is_multichannel);
			break;

		case ObjectInterface::IdDeviceUPnP:
		case ObjectInterface::IdDeviceUSB:
		case ObjectInterface::IdDeviceSD:
			multimedia.append(xml_obj);
			break;

		case ObjectInterface::IdMessages:
			objmodel << parseMessageObject(xml_obj);
			break;

		case MediaLink::WebRadio:
			multimedia.append(xml_obj);
		case MediaLink::Rss:
		case MediaLink::RssMeteo:
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

	// note that this returns source objects even if sound diffusion is not configured, because
	// the objects are used to construct the item list for multimedia
	//
	// source objects are used for alarm clock construction
	foreach (ObjectPair p, createLocalSources(is_multichannel, multimedia, &media_link_model))
	{
		if (p.first != -1)
			uii_map.insert(p.first, p.second);
		objmodel << p.second;
	}


	foreach (const QDomNode &xml_obj, getChildren(settings.documentElement(), "obj"))
	{
		QList<ObjectPair> obj_list;
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case ObjectInterface::IdAlarmClock:
			obj_list = parseAlarmClocks(xml_obj, getSoundSources(objmodel), uii_map);
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
	if ((*bt_global::config)[PI_ADDRESS] != "")
	{
		CCTV *cctv = static_cast<CCTV *>(createCCTV(vde));

		cctv->setAutoOpen(professional_studio);
		cctv->setHandsFree(hands_free);
		cctv->setRingExclusion(ring_exclusion);

		cctv->setColor(video_color);
		cctv->setBrightness(video_brightness);
		cctv->setContrast(video_contrast);

		objmodel << cctv;
		objmodel << createIntercom(intercom);
	}

	objmodel << new HardwareSettings;
	objmodel << new PlatformSettings(bt_global::add_device_to_cache(new PlatformDevice));

	// the following objects are used as collectors of signals from other objects
	// they are used in EventManager, for example, to be notified only globally
	// the following needs stop&go objects to be already created
	objmodel << new StopAndGoDangers();
	// the following needs scenario modules to be already created
	objmodel << new ScenarioModulesNotifier();
	// the following needs energy "objects" to be already created
	objmodel << new EnergyThresholdsGoals();
	// the following needs alarm clocks object to be already created
	objmodel << new AlarmClockNotifier();
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
		QPair<QDomNode, QString> container_path = findNodeForUii(item->getContainerUii());
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
	case Container::IdSoundDiffusionMono:
	case Container::IdSoundDiffusionMulti:
	case Container::IdAntintrusion:
	case Container::IdSettings:
	case Container::IdMessages:
	case Container::IdAmbient:
	case Container::IdSpecialAmbient:
	case Container::IdMultimediaRss:
	case Container::IdMultimediaRssMeteo:
	case Container::IdMultimediaWebRadio:
	case Container::IdMultimediaWebCam:
	case Container::IdMultimediaDevice:
	case Container::IdMultimediaWebLink:
	case Container::IdHomepage:
		return configurations->getConfiguration(LAYOUT_FILE);
	case ObjectInterface::IdEnergyRate:
	case ObjectInterface::IdAlarmClock:
		return configurations->getConfiguration(SETTINGS_FILE);
	default:
		return configurations->getConfiguration(ARCHIVE_FILE);
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
	QString conf_name = document.documentElement().tagName() == "archive" ? ARCHIVE_FILE :
			    document.documentElement().tagName() == "settings" ? SETTINGS_FILE :
										 LAYOUT_FILE;
	QString child_name = document.documentElement().tagName() == "layout" ? "container" : "obj";

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

void BtObjectsPlugin::updateObject(ItemInterface *obj)
{
	ObjectInterface *obj_int = qobject_cast<ObjectInterface *>(obj);

	// CCTV object do not have an obj/ist, but have configurations in settings.xml
	if (obj_int && obj_int->getObjectId() == ObjectInterface::IdCCTV)
	{
		CCTV *cctv = qobject_cast<CCTV*>(obj_int);
		QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

		setEnableFlag(document, IdHandsFree, cctv->getHandsFree());
		setEnableFlag(document, IdProfessionalStudio, cctv->getAutoOpen());
		setEnableFlag(document, IdRingExclusion, cctv->getRingExclusion());
		setIntSetting(document, IdVideoSettings, "brightness", cctv->getBrightness());
		setIntSetting(document, IdVideoSettings, "color", cctv->getColor());
		setIntSetting(document, IdVideoSettings, "contrast", cctv->getContrast());

		configurations->saveConfiguration(SETTINGS_FILE);
		return;
	}

	QPair<QDomNode, QString> node_path = findNodeForObject(obj);

	if (node_path.first.isNull())
		return;

	Container *obj_cont = qobject_cast<Container *>(obj);
	MediaLink *obj_media = qobject_cast<MediaLink *>(obj);
	ObjectLink *obj_link = qobject_cast<ObjectLink *>(obj);

	// If we are in homepage, we don't want to update the position of the link
	bool is_home_page = (global_models.getHomepageLinks()->getUii() == obj->getContainerUii());

	if (obj_int)
	{
		updateObjectName(node_path.first, obj_int);

		// TODO energy, other specialized systems
		switch (obj_int->getObjectId())
		{
		case ObjectInterface::IdAdvancedScenario:
			updateAdvancedScenario(node_path.first, qobject_cast<AdvancedScenario *>(obj_int));
			break;
		case ObjectInterface::IdEnergyData:
			updateEnergyData(node_path.first, qobject_cast<EnergyData *>(obj_int));
			break;
		case ObjectInterface::IdEnergyRate:
			updateEnergyRate(node_path.first, qobject_cast<EnergyRate *>(obj_int));
			break;
		case ObjectInterface::IdAlarmClock:
			updateAlarmClocks(node_path.first, qobject_cast<AlarmClock *>(obj_int), uii_map);
			break;
		}
	}
	else if (obj_cont)
	{
		ContainerWithCard *obj_card = qobject_cast<ContainerWithCard *>(obj_cont);

		updateContainerNameImage(node_path.first, obj_cont);

		if (obj_card)
			updateProfileCardImage(node_path.first, obj_card);
	}
	else if (obj_media)
	{
		QPair<QDomNode, QString> archive_path = findNodeForUii(findLinkedUiiForObject(obj));

		updateMediaNameAddress(archive_path.first, obj_media);
		if (!is_home_page)
			updateLinkPosition(node_path.first, obj_media);

		configurations->saveConfiguration(archive_path.second);
	}
	else if (obj_link)
	{
		if (!is_home_page)
			updateLinkPosition(node_path.first, obj_link);
	}
	else
	{
		qWarning() << "Unknown object type" << obj;
	}

	configurations->saveConfiguration(node_path.second);
}

void BtObjectsPlugin::insertObject(ItemInterface *obj)
{
	qDebug() << "BtObjectsPlugin::insertObject" << obj << obj->getContainerUii();
	QPair<QDomNode, QString> container_path;
	if (obj->getContainerUii() != -1)
		container_path = findNodeForUii(obj->getContainerUii());
	int uii = -1;

	ObjectLink *obj_link = qobject_cast<ObjectLink *>(obj);
	MediaLink *obj_media = qobject_cast<MediaLink *>(obj);
	Container *obj_container = qobject_cast<Container *>(obj);
	ObjectInterface *obj_interface = qobject_cast<ObjectInterface *>(obj);

	if (obj_media)
	{
		QDomDocument archive = configurations->getConfiguration(ARCHIVE_FILE);

		uii = uii_map.nextUii();
		uii_map.insert(uii, obj_media);
		uii_to_id[uii] = obj_media->getType();

		createMediaLink(archive, uii, obj_media);
		configurations->saveConfiguration(ARCHIVE_FILE);
	}
	else if (obj_container)
	{
		QDomDocument layout = configurations->getConfiguration(LAYOUT_FILE);

		uii = uii_map.nextUii();
		uii_map.insert(uii, obj_container);
		uii_to_id[uii] = obj_container->getContainerId();

		createContainer(layout, uii, obj_container);

		if (obj->getContainerUii() == -1)
			configurations->saveConfiguration(LAYOUT_FILE);
	}
	else if (obj_interface)
	{
		uii = uii_map.nextUii();
		uii_map.insert(uii, obj_interface);
		uii_to_id[uii] = obj_interface->getObjectId();

		QDomDocument settings = configurations->getConfiguration(SETTINGS_FILE);

		foreach (QDomNode xml_obj, getChildren(settings.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == obj_interface->getObjectId())
			{
				QDomElement ist_obj = settings.createElement("ist");
				// TODO for now, we are sure we have only AlarmClocks objects;
				// if other classes need this, update code accordingly
				updateAlarmClocks(ist_obj, qobject_cast<AlarmClock *>(obj_interface), uii_map);
				setAttribute(ist_obj, "uii", QString::number(uii));
				xml_obj.appendChild(ist_obj);
				break;
			}
		}

		configurations->saveConfiguration(SETTINGS_FILE);

		return;
	}
	else
		uii = findLinkedUiiForObject(obj);

	if (uii == -1 || container_path.first.isNull())
		return;

	// Homepage links don't have a position but they have an 'img' tag
	bool is_home_page = (global_models.getHomepageLinks()->getUii() == obj->getContainerUii());

	if (is_home_page)
	{
		createLinkHomepage(container_path.first, uii);
	}
	else
	{
		if (obj_link)
			createLink(container_path.first, uii, obj_link);
		else if (obj_media)
			createLink(container_path.first, uii, obj_media);
		else
			createLink(container_path.first, uii);
	}

	configurations->saveConfiguration(container_path.second);
}

void BtObjectsPlugin::removeObject(ItemInterface *obj)
{
	qDebug() << "BtObjectsPlugin::removeObject" << obj;
	QPair<QDomNode, QString> container_path;
	if (obj->getContainerUii() != -1)
		container_path = findNodeForUii(obj->getContainerUii());
	int uii = -1;

	MediaLink *obj_media = qobject_cast<MediaLink *>(obj);
	Container *obj_container = qobject_cast<Container *>(obj);
	ObjectInterface *obj_interface = qobject_cast<ObjectInterface *>(obj);

	if (obj_container)
	{
		// TODO and what about contained objects?
		QPair<QDomNode, QString> ist_path = findNodeForUii(obj_container->getUii());

		if (ist_path.first.isNull())
			qFatal("Can't find item node for uii %d", obj_container->getUii());

		ist_path.first.parentNode().removeChild(ist_path.first);

		configurations->saveConfiguration(ist_path.second);
	}
	else if (obj_interface)
	{
		int uii = uii_map.findUii(obj_interface);
		QPair<QDomNode, QString> ist_path = findNodeForUii(uii);

		if (ist_path.first.isNull())
			qFatal("Can't find item node for uii %d", uii);

		ist_path.first.parentNode().removeChild(ist_path.first);

		configurations->saveConfiguration(SETTINGS_FILE);
		return;
	}
	else
		uii = findLinkedUiiForObject(obj);

	if (uii == -1 || container_path.first.isNull())
		return;

	// profile media links need to be removed both in archive.xml and in layout.xml
	if (obj_media)
	{
		QPair<QDomNode, QString> ist_path = findNodeForUii(uii);

		if (ist_path.first.isNull())
			qFatal("Can't find item node for uii %d", uii);

		ist_path.first.parentNode().removeChild(ist_path.first);

		configurations->saveConfiguration(ist_path.second);
	}

	foreach (QDomNode child, getChildren(container_path.first, "link"))
	{
		if (getAttribute(child, "uii", "-1").toInt() == uii)
		{
			container_path.first.removeChild(child);
			break;
		}
	}

	configurations->saveConfiguration(container_path.second);
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

void BtObjectsPlugin::parseConfig()
{
	QDomDocument layout = configurations->getConfiguration(LAYOUT_FILE);

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
		case Container::IdAmbient:
		case Container::IdSpecialAmbient:
			parseSoundAmbientMulti(container);
			break;
		case Container::IdSoundDiffusionMono:
			parseSoundAmbientMono(container);
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
		case Container::IdSoundDiffusionMulti:
		case Container::IdAntintrusion:
		case Container::IdSettings:
		case Container::IdMessages:
			parseSystem(container);
			break;
		case Container::IdHomepage:
			parseHomepage(container);
			break;
		case Container::IdMultimediaRss:
		case Container::IdMultimediaRssMeteo:
		case Container::IdMultimediaWebRadio:
		case Container::IdMultimediaWebCam:
		case Container::IdMultimediaDevice:
		case Container::IdMultimediaWebLink:
			parseMediaContainers(container);
			break;
		}
	}

	parseNotes(QFileInfo(QDir(qApp->applicationDirPath()), NOTES_FILE).absoluteFilePath(), &note_model);

	// Since we don't have an ambient for the general, we build one. This way we can
	// treat it like any other ambient in the GUI; it also naturally handles the concept
	// of source, which normal amplifiers don't have.
	if (general_ambient_uii > 0)
		createGeneralAmbient();
}

void BtObjectsPlugin::createGeneralAmbient()
{
	QDomNode node = findNodeForUii(general_ambient_uii).first;
	QList<SourceObject *> sources = getSoundSources(objmodel);

	int ambient_uii = uii_map.nextUii();
	SoundGeneralAmbient *general_ambient = new SoundGeneralAmbient(getAttribute(node, "descr"), ambient_uii);

	uii_map.insert(ambient_uii, general_ambient);
	uii_to_id[ambient_uii] = general_ambient->getObjectId();
	AmplifierGroup *a = uii_map.value<AmplifierGroup>(general_ambient_uii);
	if (!a)
	{
		qWarning() << "Invalid uii" << general_ambient_uii << "for general object";
		Q_ASSERT_X(false, "createGeneralAmbient", "Invalid uii");
	}
	// don't put the general amplifier into the new ambient, we can retrieve it
	// anyway in the GUI. This allows the user to put the general amplifier
	// in another ambient as well (as an amplifier group).
	objmodel.prepend(general_ambient);

	general_ambient->connectSources(sources);
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
		Container *room = new ContainerWithCard(room_id, room_uii, v.value("img"), v.value("img_card"), v.value("descr"));

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

			item->setContainerUii(room_uii);

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

			room->setContainerUii(floor_uii);
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
		Container *profile = new ContainerWithCard(profile_id, profile_uii, v.value("img"), v.value("img_card"), v.value("descr"));

		profile_model << profile;
		uii_map.insert(profile_uii, profile);
		uii_to_id[profile_uii] = profile_id;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int link_uii = getIntAttribute(link, "uii");
			MediaLink *l = uii_map.value<MediaLink>(link_uii);
			ExternalPlace *e = uii_map.value<ExternalPlace>(link_uii);
			QPoint pos(getIntAttribute(link, "x"), getIntAttribute(link, "y"));

			if (l)
			{
				l->setContainerUii(profile_uii);
				l->setPosition(pos);
			}
			else if (e)
			{
				// for surveillance cameras, create a media link object on the fly using
				// the data from the camera object
				ObjectLink *o = new ObjectLink(uii_map.value<ObjectInterface>(link_uii), pos.x(), pos.y());
				o->setContainerUii(profile_uii);
				media_link_model << o;
			}
			else
			{
				qWarning() << "The uii" << link_uii << "in profile" << profile_uii << "is neither a camera nor a MediaLink, expect failures.";
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

		// TODO this is a temporary workaround to allow the code in Systems.qml to work
		system->setContainerUii(system_id);

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

			o->setContainerUii(system_uii);
		}
	}
}

void BtObjectsPlugin::parseHomepage(const QDomNode &container)
{
	XmlObject v(container);
	int homepage_id = getIntAttribute(container, "id");

	foreach (const QDomNode &ist, getChildren(container, "ist"))
	{
		v.setIst(ist);
		int homepage_uii = getIntAttribute(ist, "uii");
		Container *homepage = new Container(homepage_id, homepage_uii, QString("Use GuiSettings homeBgImage property, not this"), v.value("descr"));

		global_models.setHomepageLinks(homepage);
		uii_map.insert(homepage_uii, homepage);
		uii_to_id[homepage_uii] = homepage_id;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int link_uii = getIntAttribute(link, "uii");
			ItemInterface *l = uii_map.value<ItemInterface>(link_uii);

			ObjectInterface *o = qobject_cast<ObjectInterface *>(l);
			if (o) {
				ObjectLink *item = new ObjectLink(o, -1, -1);
				item->setContainerUii(homepage_uii);
				media_link_model << item;
			}
			else
			{
				if (!l)
				{
					qWarning() << "Invalid uii" << link_uii << "in homepage";
					Q_ASSERT_X(false, __PRETTY_FUNCTION__, "Invalid uii");
					continue;
				}

				l->setContainerUii(homepage_uii);
			}
		}

		// looking for child toolbar tag
		foreach (const QDomNode &toolbar, getChildren(ist, "toolbar"))
		{
			foreach (const QDomNode &sub_link, getChildren(toolbar, "link"))
			{
				int link_uii = getIntAttribute(sub_link, "uii");
				ItemInterface *l = uii_map.value<ItemInterface>(link_uii);

				// Did we find a thermal probe?
				ThermalNonControlledProbe *p1 = qobject_cast<ThermalNonControlledProbe *>(l);
				ThermalControlledProbe *p2 = qobject_cast<ThermalControlledProbe *>(l);
				ObjectInterface *o = qobject_cast<ObjectInterface *>(l);
				if (p1 || p2)
				{
					ObjectLink *item = new ObjectLink(o, -1, -1);
					item->setContainerUii(homepage_uii);
					object_link_model << item;
				}
				else
				{
					qWarning() << "Invalid uii" << link_uii << "in homepage/toolbar";
					Q_ASSERT_X(false, __PRETTY_FUNCTION__, "Invalid uii");
					continue;
				}
			}
		}
	}
}

void BtObjectsPlugin::parseMediaContainers(const QDomNode &container)
{
	XmlObject v(container);
	int media_id = getIntAttribute(container, "id");

	foreach (const QDomNode &ist, getChildren(container, "ist"))
	{
		v.setIst(ist);
		int media_uii = getIntAttribute(ist, "uii");
		Container *media = new Container(media_id, media_uii, v.value("img"), v.value("descr"));
		media->setContainerUii(media_uii);

		media_model << media;
		uii_map.insert(media_uii, media);
		uii_to_id[media_uii] = media_id;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int link_uii = getIntAttribute(link, "uii");
			ItemInterface *l = uii_map.value<ItemInterface>(link_uii);

			if (!l)
			{
				qWarning() << "Invalid uii" << link_uii << "in media container";
				Q_ASSERT_X(false, "parseMediaContainers", "Invalid uii");
				continue;
			}

			l->setContainerUii(media_uii);
		}
	}
}

void BtObjectsPlugin::parseSoundAmbientMulti(const QDomNode &ambient)
{
	XmlObject v(ambient);
	int ambient_id = getIntAttribute(ambient, "id");
	QList<SourceObject *> sources = getSoundSources(objmodel);

	foreach (const QDomNode &ist, getChildren(ambient, "ist"))
	{
		v.setIst(ist);
		int ambient_uii = getIntAttribute(ist, "uii");
		SoundAmbient *ambient = new SoundAmbient(v.intValue("env"), v.value("descr"), ambient_id, ambient_uii);
		QList<Amplifier *> amplifiers;

		objmodel << ambient;
		uii_map.insert(ambient_uii, ambient);
		uii_to_id[ambient_uii] = ambient_id;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			ObjectInterface *o = uii_map.value<ObjectInterface>(object_uii);
			Amplifier *a = qobject_cast<Amplifier *>(o);

			if (!o)
			{
				qWarning() << "Invalid uii" << object_uii << "in ambient";
				Q_ASSERT_X(false, "parseSoundAmbientMulti", "Invalid uii");
				continue;
			}

			o->setContainerUii(ambient_uii);
			if (a)
				amplifiers.append(a);
		}

		ambient->connectSources(sources);
		ambient->connectAmplifiers(amplifiers);
	}
}

void BtObjectsPlugin::parseSoundAmbientMono(const QDomNode &ambient)
{
	XmlObject v(ambient);
	int system_id = getIntAttribute(ambient, "id");
	QList<SourceObject *> sources = getSoundSources(objmodel);

	foreach (const QDomNode &ist, getChildren(ambient, "ist"))
	{
		v.setIst(ist);
		int system_uii = getIntAttribute(ist, "uii");
		int ambient_uii = -2;
		Container *system = new Container(system_id, system_uii, v.value("img"), v.value("descr"));
		SoundAmbient *ambient = new SoundAmbient(0, "", ObjectInterface::IdMonoChannelSoundAmbient, ambient_uii);

		objmodel << ambient;
		systems_model << system;
		uii_map.insert(system_uii, system);
		uii_to_id[system_uii] = system_id;

		// TODO this is a temporary workaround to allow the code in Systems.qml to work
		system->setContainerUii(system_id);

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			ObjectInterface *o = uii_map.value<ObjectInterface>(object_uii);

			if (!o)
			{
				qWarning() << "Invalid uii" << object_uii << "in ambient";
				Q_ASSERT_X(false, "parseSoundAmbientMono", "Invalid uii");
				continue;
			}

			o->setContainerUii(ambient_uii);
		}

		ambient->connectSources(sources);
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
	qmlRegisterUncreatableType<ObjectDataModel>(uri, 1, 0, "ObjectDataModel", "");
	qmlRegisterUncreatableType<MediaDataModel>(uri, 1, 0, "MediaDataModel", "");
	qmlRegisterType<MediaModel>(uri, 1, 0, "MediaModel");
	qmlRegisterType<ObjectModel>(uri, 1, 0, "ObjectModel");
	qmlRegisterType<DirectoryListModel>(uri, 1, 0, "DirectoryListModel");
	qmlRegisterType<UPnPListModel>(uri, 1, 0, "UPnPListModel");
	qmlRegisterUncreatableType<ItemInterface>(uri, 1, 0, "ItemInterface",
		"unable to create an ItemInterface instance");
	qmlRegisterUncreatableType<LinkInterface>(uri, 1, 0, "LinkInterface",
		"unable to create an LinkInterface instance");
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
	qmlRegisterUncreatableType<Amplifier>(uri, 1, 0, "Amplifier",
		"unable to create an Amplifier instance");
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
	qmlRegisterType<EnergyGraphObject>(uri, 1, 0, "EnergyGraphObject");
	qmlRegisterType<EnergyItemObject>(uri, 1, 0, "EnergyItemObject");
	qmlRegisterUncreatableType<EnergyFamily>(uri, 1, 0, "EnergyFamily",
		"unable to create an EnergyFamily instance");
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
	qmlRegisterUncreatableType<AudioVideoPlayer>(uri, 1, 0, "AudioVideoPlayer", "");
	qmlRegisterUncreatableType<PhotoPlayer>(uri, 1, 0, "PhotoPlayer", "");
	qmlRegisterUncreatableType<AlarmClock>(uri, 1, 0, "AlarmClock",
		"unable to create a AlarmClock instance");
	qmlRegisterUncreatableType<ExternalPlace>(uri, 1, 0, "ExternalPlace",
		"unable to create a ExternalPlace instance");
	qmlRegisterUncreatableType<MountPoint>(uri, 1, 0, "MountPoint",
										   "unable to create a MountPoint instance");
	qmlRegisterUncreatableType<ScreenState>(uri, 1, 0, "ScreenState",
						"unable to create a ScreenState instance");
}

Q_EXPORT_PLUGIN2(BtObjects, BtObjectsPlugin)

