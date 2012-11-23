#include "mediaobjects.h"
#include "media_device.h"
#include "list_manager.h"
#include "playlistplayer.h"
#include "devices_cache.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "mounts.h"

#include <QDebug>
#include <QStringList>
#include <QFutureWatcher>
#include <QtConcurrentRun>
#include <QFileInfo>
#include <QDir>

#define REQUEST_FREQUENCY_TIME 1000
#define GENERAL_AMBIENT_MIN_CID 11041

namespace
{
	const char *standard_presets[] =
	{
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Normal"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Dance"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Pop"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Rock"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Classical"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Techno"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Party"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Soft"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Full Bass"),
		QT_TRANSLATE_NOOP("PowerAmplifierPreset", "Full Treble"),
	};

	template<class R>
	R makeAbsolute(QFileInfoList files)
	{
		R result;

		foreach (const QFileInfo &fi, files)
			result.append(fi.absoluteFilePath());

		return result;
	}

	QVariantList makeModelPath(QString path)
	{
		QVariantList res;

		foreach (QString dir, path.split("/", QString::SkipEmptyParts))
			res << dir;

		return res;
	}
}

#define standard_presets_size int(sizeof(standard_presets) / sizeof(standard_presets[0]))


QList<ObjectPair> parseIpRadio(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		obj_list << ObjectPair(uii, new IpRadio(EntryInfo(v.value("descr"), EntryInfo::AUDIO, v.value("url"))));
	}
	return obj_list;
}

QList<ObjectPair> parseAuxSource(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		SourceAux *source = new SourceAux(bt_global::add_device_to_cache(new SourceDevice(v.value("where"))));
		SourceObject *so = new SourceObject(v.value("descr"), source, SourceObject::Aux);

		obj_list << ObjectPair(uii, so);
	}
	return obj_list;
}

QList<ObjectPair> parseMultimediaSource(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		SourceAux *source = new SourceAux(bt_global::add_device_to_cache(new SourceDevice(v.value("where"))));
		SourceObject *so = new SourceObject(v.value("descr"), source, SourceObject::Touch);

		obj_list << ObjectPair(uii, so);
	}
	return obj_list;
}

QList<ObjectPair> parseRadioSource(const QDomNode &xml_node)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");

		SourceRadio *source = new SourceRadio(v.intValue("radio_num"), bt_global::add_device_to_cache(new RadioSourceDevice(v.value("where"))));
		SourceObject *so = new SourceObject(v.value("descr"), source, SourceObject::RdsRadio);
		// TODO station count
		obj_list << ObjectPair(uii, so);
	}
	return obj_list;
}

QList<ObjectPair> parseAmplifier(const QDomNode &xml_node, bool is_multichannel)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		AmplifierDevice *d = AmplifierDevice::createDevice(v.value("where"));
		int area = is_multichannel ? d->getArea().toInt() : 0;

		Amplifier *amp = new Amplifier(area, v.value("descr"), d);
		int cid = v.intValue("cid");
		if (cid >= GENERAL_AMBIENT_MIN_CID)
		{
			QList<Amplifier *> amplifiers;
			amplifiers << amp;
			obj_list << ObjectPair(uii, new AmplifierGroup(v.value("descr"),
				amplifiers, ObjectInterface::IdMultiAmbientAmplifier));
		}
		else
		{
			obj_list << ObjectPair(uii, amp);
		}
	}
	return obj_list;
}

QList<ObjectPair> parseAmplifierGroup(const QDomNode &xml_node, const UiiMapper &uii_map)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		QList<Amplifier *> amplifiers;

		foreach (const QDomNode &link, getChildren(ist, "link"))
		{
			int object_uii = getIntAttribute(link, "uii");
			Amplifier *item = uii_map.value<Amplifier>(object_uii);

			if (!item)
			{
				qWarning() << "Invalid uii" << object_uii << "in amplifier set";
				Q_ASSERT_X(false, "parseAmplifierGroup", "Invalid uii");
				continue;
			}

			amplifiers.append(item);
		}

		obj_list << ObjectPair(uii, new AmplifierGroup(v.value("descr"), amplifiers));
	}
	return obj_list;
}

QList<ObjectPair> parsePowerAmplifier(const QDomNode &xml_node, bool is_multichannel)
{
	QList<ObjectPair> obj_list;
	XmlObject v(xml_node);

	foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
	{
		v.setIst(ist);
		int uii = getIntAttribute(ist, "uii");
		PowerAmplifierDevice *d = bt_global::add_device_to_cache(new PowerAmplifierDevice(v.value("where")));
		int area = is_multichannel ? d->getArea().toInt() : 0;
		QList<QString> presets;

		foreach(const QDomNode &p, getChildren(ist, "pre"))
		{
			QDomElement preset = p.toElement();
			QString preset_name = preset.text();
			int index = preset.tagName().mid(3).toInt() - 11;

			while (presets.count() <= index)
				presets.append(QString());
			presets[index] = preset_name;
		}

		obj_list << ObjectPair(uii, new PowerAmplifier(area, v.value("descr"), d, presets));
	}
	return obj_list;
}

QList<ObjectPair> createLocalSources(bool is_multichannel, QList<QDomNode> multimedia)
{
	QList<ObjectPair> sources;

	// TODO init local source/amplifier, see SoundDiffusionPage::SoundDiffusionPage

	if (!(*bt_global::config)[SOURCE_ADDRESS].isEmpty() || !(*bt_global::config)[AMPLIFIER_ADDRESS].isEmpty())
	{
		QString init_frame = VirtualSourceDevice::createMediaInitFrame(is_multichannel,
									       (*bt_global::config)[SOURCE_ADDRESS],
									       (*bt_global::config)[AMPLIFIER_ADDRESS]);
		bt_global::devices_cache.addInitCommandFrame(0, init_frame);
	}

	VirtualSourceDevice *device = 0;

	// source objects are used both for sound diffusion and multimedia; rather than instantiating different
	// objects it's easier to use a dummy device (in any case it will not be used by the UI)
	if (!(*bt_global::config)[SOURCE_ADDRESS].isEmpty())
		device = bt_global::add_device_to_cache(new VirtualSourceDevice((*bt_global::config)[SOURCE_ADDRESS]));
	else
		device = bt_global::add_device_to_cache(new VirtualSourceDevice("-1"), NO_INIT);

	SourceMultiMedia *source = new SourceMultiMedia(device);

	foreach (QDomNode xml_obj, multimedia)
	{
		int id = getIntAttribute(xml_obj, "id");
		XmlObject v(xml_obj);

		switch (id)
		{
		case ObjectInterface::IdIpRadio:
			sources << ObjectPair(-1, new SourceIpRadio(QObject::tr("IP radio"), source));
			break;
		case ObjectInterface::IdDeviceUSB:
		case ObjectInterface::IdDeviceSD:
		case ObjectInterface::IdDeviceUPnP:
			foreach (const QDomNode &ist, getChildren(xml_obj, "ist"))
			{
				v.setIst(ist);
				int uii = v.intValue("uii");

				switch (id)
				{
				case ObjectInterface::IdDeviceUSB:
				{
					MountPoint *mp = new MountPoint(MountPoint::Usb);
					sources << ObjectPair(uii, new SourceLocalMedia(v.value("descr"), mp, source, SourceObject::Usb));
					break;
				}
				case ObjectInterface::IdDeviceSD:
				{
					MountPoint *mp = new MountPoint(MountPoint::Sd);
					sources << ObjectPair(uii, new SourceLocalMedia(v.value("descr"), mp, source, SourceObject::Sd));
					break;
				}
				case ObjectInterface::IdDeviceUPnP:
					sources << ObjectPair(uii, new SourceUpnpMedia(v.value("descr"), source));
					break;
				}
			}
		}
	}

	return sources;
}

SoundAmbientBase::SoundAmbientBase(QString _name, int _uii)
{
	name = _name;
	uii = _uii;
	current_source = 0;
}

int SoundAmbientBase::getUii() const
{
	return uii;
}

QObject *SoundAmbientBase::getCurrentSource() const
{
	return current_source;
}

int SoundAmbientBase::getArea() const
{
	return area;
}

void SoundAmbientBase::setCurrentSource(SourceObject *other)
{
	if (current_source != other)
	{
		current_source = other;
		emit currentSourceChanged();
	}
}


SoundAmbient::SoundAmbient(int _area, QString name, int _object_id, int uii) :
	SoundAmbientBase(name, uii)
{
	area = _area;
	amplifier_count = 0;
	object_id = _object_id;
	previous_source = NULL;
}

void SoundAmbient::connectSources(QList<SourceObject *> sources)
{
	foreach (SourceObject *source, sources)
		QObject::connect(source, SIGNAL(activeAreasChanged(SourceObject *)), this, SLOT(updateActiveSource(SourceObject *)));
}

void SoundAmbient::connectAmplifiers(QList<Amplifier *> amplifiers)
{
	foreach (Amplifier *amplifier, amplifiers)
		if (amplifier->getArea() == getArea())
			QObject::connect(amplifier, SIGNAL(activeChanged()), this, SLOT(updateActiveAmplifier()));
}

bool SoundAmbient::getHasActiveAmplifier() const
{
	return amplifier_count != 0;
}

QObject *SoundAmbient::getPreviousSource() const
{
	return previous_source;
}

void SoundAmbient::updateActiveSource(SourceObject *source_object)
{
	SourceBase *source = source_object->getSource();
	SourceObject *current_source = static_cast<SourceObject *>(getCurrentSource());

	// there are 3 cases
	//
	// - source is not active on area (isActive is true and current_source != source)
	// - source is turned on on a new area (isActive is true and current_source == source)
	// - source is turned off on the area (isActive is false and current_source == source)
	if (source->isActiveInArea(area))
	{
		if (current_source != source_object)
		{
			previous_source = current_source;
			setCurrentSource(source_object);
		}
	}
	else if (source_object == current_source)
	{
		previous_source = current_source;
		setCurrentSource(0);
	}
}

void SoundAmbient::updateActiveAmplifier()
{
	Amplifier *amplifier = static_cast<Amplifier *>(sender());
	int count = amplifier_count;

	if (amplifier->isActive())
	{
		amplifier_count += 1;

		if (count == 0)
			emit activeAmplifierChanged();
	}
	else
	{
		amplifier_count -= 1;

		if (amplifier_count == 0)
			emit activeAmplifierChanged();
	}
}


SoundGeneralAmbient::SoundGeneralAmbient(QString name, int uii) :
	SoundAmbientBase(name, uii)
{
	area = 0;
}

void SoundGeneralAmbient::setSource(SourceObject * source)
{
	setCurrentSource(source);
}


SourceObject::SourceObject(const QString &_name, SourceBase *s, SourceObjectType t)
{
	name = _name;
	source = s;
	type = t;

	source->setParent(this);
	source->setSourceObject(this);
}

void SourceObject::enableObject()
{
	source->enableObject();
}

void SourceObject::initializeObject()
{
	source->initializeObject();
}

void SourceObject::scsSourceActiveAreasChanged()
{
	emit activeAreasChanged(this);
}

void SourceObject::scsSourceForGeneralAmbientChanged()
{
	emit sourceForGeneralAmbientChanged(this);
}

void SourceObject::setActive(int area)
{
	source->setActive(area);
	source->setSourceObject(this);
}

void SourceObject::previousTrack()
{
	source->previousTrack();
}

void SourceObject::nextTrack()
{
	source->nextTrack();
}

SourceMedia::SourceMedia(const QString &name, SourceMultiMedia *s, SourceObjectType t) :
	SourceObject(name, s, t)
{
	source = s;
	source->addMediaSource(this);
}

QObject *SourceMedia::getMediaPlayer() const
{
	return source->getAudioVideoPlayer()->getMediaPlayer();
}

QObject *SourceMedia::getAudioVideoPlayer() const
{
	return source->getAudioVideoPlayer();
}

void SourceMedia::previousTrack()
{
	source->getAudioVideoPlayer()->prevTrack();
}

void SourceMedia::nextTrack()
{
	source->getAudioVideoPlayer()->nextTrack();
}

void SourceMedia::togglePause()
{
	MultiMediaPlayer *media_player = static_cast<MultiMediaPlayer *>(source->getAudioVideoPlayer()->getMediaPlayer());

	if (media_player->getPlayerState() == MultiMediaPlayer::Playing)
	{
		media_player->pause();
	}
	else
	{
		media_player->resume();
	}
}

void SourceMedia::playFirstMediaContent()
{
	emit firstMediaContentStatus(false);
}


SourceIpRadio::SourceIpRadio(const QString &name, SourceMultiMedia *s) :
	SourceMedia(name, s, IpRadio)
{
}

void SourceIpRadio::startPlay(QList<QVariant> urls, int index, int total_files)
{
	source->getAudioVideoPlayer()->generatePlaylistWebRadio(urls, index, total_files);
}

void SourceIpRadio::playFirstMediaContent()
{
	ObjectModel ip_radios;
	QList<QVariant> urls;

	ip_radios.setFilters(ObjectModelFilters() << "objectId" << ObjectInterface::IdIpRadio);

	for (int i = 0; i < ip_radios.getCount(); ++i)
		urls.append(static_cast< ::IpRadio *>(ip_radios.getObject(i))->getPath());

	if (urls.count())
		startPlay(urls, 0, urls.count());

	emit firstMediaContentStatus(urls.count() != 0);
}


SourceLocalMedia::SourceLocalMedia(const QString &name, MountPoint *_mount_point, SourceMultiMedia *s, SourceObjectType t) :
	SourceMedia(name, s, t)
{
	mount_point = _mount_point;
	model = new DirectoryListModel(this);
	terminate = 0;
}

void SourceLocalMedia::startPlay(DirectoryListModel *_model, int index, int total_files)
{
	if (_model != model)
	{
		DirectoryListModelMemento *state = _model->clone();
		model->restore(state);
		// remove any range that may be set
		model->setRange(QVariantList() << 0 << model->getCount());
		delete state;
	}

	source->getAudioVideoPlayer()->generatePlaylistLocal(model, index, total_files, false);
}

QVariantList SourceLocalMedia::getRootPath() const
{
	return mount_point->getLogicalPath();
}

MountPoint *SourceLocalMedia::getMountPoint() const
{
	return mount_point;
}

void SourceLocalMedia::pathScanComplete()
{
	qDebug() << "USB/SD search complete";

	QFutureWatcher<AsyncRes> *watch = static_cast<QFutureWatcher<AsyncRes> *>(sender());
	DirectoryListModel *files = watch->result().first;
	bool *terminated = watch->result().second;

	if (!*terminated && files->getCount())
	{
		qDebug() << "Playing from USB/SD";
		startPlay(files, 0, files->getCount());
	}

	files->deleteLater();
	delete terminated;
	watch->deleteLater();

	emit firstMediaContentStatus(!*terminated);
}

void SourceLocalMedia::playFirstMediaContent()
{
	if (!mount_point->getMounted() || mount_point->getPath().isEmpty())
	{
		emit firstMediaContentStatus(false);
		return;
	}

	// abort running search (if any)
	if (terminate)
		*terminate = true;

	// run the search asynchronously; the termination flag is always deallocated when the search completes
	// (either by setting *terminate to true or by normal completion); the flag is written at most once to
	// true from the main thread and only checked from the worker thread
	terminate = new bool(false);
	QFuture<AsyncRes> res = QtConcurrent::run(&scanPath, new DirectoryListModel, mount_point->getPath(), terminate);
	QFutureWatcher<AsyncRes> *watch = new QFutureWatcher<AsyncRes>(this);

	connect(watch, SIGNAL(finished()), this, SLOT(pathScanComplete()));

	watch->setFuture(res);
}

SourceLocalMedia::AsyncRes SourceLocalMedia::scanPath(DirectoryListModel *model, QString path, bool * volatile terminate)
{
	QList<QFileInfo> queue;
	QDir files, dirs;

	dirs.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);
	files.setFilter(QDir::Files);
	files.setNameFilters(getFileFilter(EntryInfo::AUDIO));

	queue << path;

	while (!queue.isEmpty() && !*terminate)
	{
		QFileInfo dir = queue.takeFirst();

		// search for files
		qDebug() << "Scanning" << dir.absoluteFilePath();
		files.cd(dir.absoluteFilePath());

		// found some files
		QFileInfoList file_list = files.entryInfoList();
		if (!file_list.isEmpty())
		{
			DirectoryListModel m(0);

			m.setRootPath(makeModelPath(files.absolutePath()));

			DirectoryListModelMemento *s = m.clone();
			model->restore(s);
			delete s;

			return qMakePair(model, terminate);
		}

		// recurse into subdirectories
		dirs.cd(dir.absoluteFilePath());
		queue.append(makeAbsolute<QFileInfoList>(dirs.entryInfoList()));
	}

	*terminate = true;

	return qMakePair(model, terminate);
}


SourceUpnpMedia::SourceUpnpMedia(const QString &name, SourceMultiMedia *s) :
	SourceMedia(name, s, Upnp)
{
}

void SourceUpnpMedia::startUpnpPlay(UPnPListModel *model, int current_index, int total_files)
{
	source->getAudioVideoPlayer()->generatePlaylistUPnP(model, current_index, total_files, false);
}


SourceBase::SourceBase(SourceDevice *d, SourceType t)
{
	dev = d;
	track = 0;
	type = t;
	source_object = 0;

	dev->setSupportedInitMode(device::DISABLED_INIT);
	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));
}

void SourceBase::enableObject()
{
	if (dev->getSupportedInitMode() == device::NORMAL_INIT)
		return;

	dev->setSupportedInitMode(device::DEFERRED_INIT);
}

void SourceBase::initializeObject()
{
	dev->smartInit(device::DEFERRED_INIT);
}

QList<int> SourceBase::getActiveAreas() const
{
	return active_areas;
}

SourceBase::SourceType SourceBase::getType() const
{
	return type;
}

void SourceBase::setActive(int area)
{
	if (area == 0)
	{
		dev->turnOn(QString::number(area));
		source_object->scsSourceForGeneralAmbientChanged();
	}
	else if (!isActiveInArea(area))
		dev->turnOn(QString::number(area));
}

bool SourceBase::isActive() const
{
	return active_areas.count() != 0;
}

bool SourceBase::isActiveInArea(int area) const
{
	return active_areas.contains(area);
}

int SourceBase::getCurrentTrack() const
{
	return track;
}

void SourceBase::previousTrack()
{
	dev->prevTrack();
}

void SourceBase::nextTrack()
{
	dev->nextTrack();
}

SourceObject *SourceBase::getSourceObject()
{
	return source_object;
}

void SourceBase::setSourceObject(SourceObject *so)
{
	source_object = so;
}

void SourceBase::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == SourceDevice::DIM_TRACK)
		{
			int val = it.value().toInt();
			if (track != val)
			{
				track = val;
				emit currentTrackChanged();
			}
		}
		else if (it.key() == SourceDevice::DIM_AREAS_UPDATED)
		{
			QList<int> val;

			for (int i = 0; i <= 8; ++i)
				if (dev->isActive(QString::number(i)))
					val.append(i);

			if (active_areas != val)
			{
				// only emit activeChanged() after assigning active_areas
				bool active_changed = val.count() == 0 || active_areas.count() == 0;

				active_areas = val;
				emit activeAreasChanged();
				source_object->scsSourceActiveAreasChanged();

				if (active_changed)
					emit activeChanged();
			}
		}
		++it;
	}
}


SourceAux::SourceAux(SourceDevice *d) :
	SourceBase(d, Aux)
{
}


SourceMultiMedia::SourceMultiMedia(VirtualSourceDevice *d) :
	SourceBase(d, MultiMedia)
{
	dev = d;
	player = new AudioVideoPlayer(this);
	source_index = -1;

	MultiMediaPlayer *p = static_cast<MultiMediaPlayer *>(player->getMediaPlayer());

#if defined(BT_HARDWARE_X11)
	p->setCommandLineArguments(QStringList(), QStringList());
#else
	p->setCommandLineArguments(QStringList() << "-ao" << "alsa:device=plughw=0.1", QStringList());
#endif
}

void SourceMultiMedia::addMediaSource(SourceMedia *source)
{
	sources.append(source);
	connect(source, SIGNAL(firstMediaContentStatus(bool)), this, SLOT(firstMediaContentStatus(bool)));
}

AudioVideoPlayer *SourceMultiMedia::getAudioVideoPlayer() const
{
	return player;
}

void SourceMultiMedia::startLocalPlayback(bool force)
{
	MultiMediaPlayer *media_player = static_cast<MultiMediaPlayer *>(player->getMediaPlayer());

	if (media_player->getPlayerState() == MultiMediaPlayer::Playing)
		return;

	if (media_player->getPlayerState() != MultiMediaPlayer::Stopped)
	{
		player->resume();
		return;
	}

	if (!force || source_index != -1)
		return;

	nextSource();
}

void SourceMultiMedia::nextSource()
{
	source_index += 1;

	if (source_index >= sources.count())
	{
		qDebug() << "No local media content found";
		source_index = -1;
		return;
	}

	SourceMedia *source = sources[source_index];

	qDebug() << "Trying media source" << source->getName();
	source->playFirstMediaContent();
}

void SourceMultiMedia::firstMediaContentStatus(bool status)
{
	// only handle the case of source switched on from SCS; other users need
	// set the current source separately
	if (source_index == -1)
		return;

	if (!status)
		nextSource();
	else
		setSourceObject(sources[source_index]);
}

void SourceMultiMedia::valueReceived(const DeviceValues &values_list)
{
	SourceBase::valueReceived(values_list);

	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case VirtualSourceDevice::REQ_SOURCE_ON:
		case VirtualSourceDevice::REQ_SOURCE_OFF:
		{
			bool status = (it.key() == VirtualSourceDevice::REQ_SOURCE_ON);

			if (status)
				startLocalPlayback(!values_list.contains(VirtualSourceDevice::DIM_SELF_REQUEST));
			else
				player->pause();
		}
			break;

		case SourceDevice::DIM_AREAS_UPDATED:
			if (!dev->isActive())
				player->pause();
			break;

		case VirtualSourceDevice::REQ_NEXT_TRACK:
			player->nextTrack();
			break;

		case VirtualSourceDevice::REQ_PREV_TRACK:
			player->prevTrack();
			break;
		}

		++it;
	}
}


SourceRadio::SourceRadio(int _saved_stations, RadioSourceDevice *d) :
	SourceBase(d, Radio)
{
	dev = d;
	saved_stations = _saved_stations;

	connect(this, SIGNAL(currentTrackChanged()), this, SIGNAL(currentStationChanged()));

	request_frequency.setInterval(REQUEST_FREQUENCY_TIME);
	request_frequency.setSingleShot(true);
	connect(&request_frequency, SIGNAL(timeout()), this, SLOT(requestFrequency()));
	frequency = 8750;
}

void SourceRadio::setCurrentStation(int station)
{
	dev->setStation(QString::number(station));
}

int SourceRadio::getCurrentFrequency() const
{
	return frequency;
}

QString SourceRadio::getRdsText() const
{
	return rds_text;
}

int SourceRadio::getSavedStationsCount() const
{
	return saved_stations;
}

void SourceRadio::previousStation()
{
	dev->prevTrack();
}

void SourceRadio::nextStation()
{
	dev->nextTrack();
}

void SourceRadio::saveStation(int station)
{
	dev->saveStation(QString::number(station));
}

void SourceRadio::startRdsUpdates()
{
	dev->requestStartRDS();
}

void SourceRadio::stopRdsUpdates()
{
	dev->requestStopRDS();
}

void SourceRadio::frequencyUp(int steps)
{
	dev->frequenceUp(QString::number(steps));
	request_frequency.start();
}

void SourceRadio::frequencyDown(int steps)
{
	dev->frequenceDown(QString::number(steps));
	request_frequency.start();
}

void SourceRadio::searchUp()
{
	frequency = -1;
	dev->frequenceUp();
	emit currentFrequencyChanged();
}

void SourceRadio::searchDown()
{
	frequency = -1;
	dev->frequenceDown();
	emit currentFrequencyChanged();
}

void SourceRadio::requestFrequency()
{
	dev->requestFrequency();
}

void SourceRadio::valueReceived(const DeviceValues &values_list)
{
	SourceBase::valueReceived(values_list);

	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == RadioSourceDevice::DIM_FREQUENCY)
		{
			int val = it.value().toInt();
			if (frequency != val)
			{
				frequency = val;
				emit currentFrequencyChanged();
			}
		}
		else if (it.key() == RadioSourceDevice::DIM_RDS)
		{
			QString val = it.value().toString();
			if (rds_text != val)
			{
				rds_text = val;
				emit rdsTextChanged();
			}
		}
		++it;
	}
}


Amplifier::Amplifier(int _area, QString _name, AmplifierDevice *d, int _object_id) :
	DeviceObjectInterface(d)
{
	dev = d;
	area = _area;
	name = _name;
	object_id = _object_id;
	active = false;
	volume = 1;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

bool Amplifier::isActive() const
{
	return active;
}

void Amplifier::setActive(bool active)
{
	if (active)
		dev->turnOn();
	else
		dev->turnOff();
}

int Amplifier::getVolume() const
{
	return volume;
}

void Amplifier::setVolume(int volume)
{
	dev->setVolume(volume);
}

int Amplifier::getArea() const
{
	return area;
}

void Amplifier::volumeUp() const
{
	dev->volumeUp();
}

void Amplifier::volumeDown() const
{
	dev->volumeDown();
}

void Amplifier::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == AmplifierDevice::DIM_STATUS)
		{
			bool val = it.value().toBool();
			if (active != val)
			{
				active = val;
				emit activeChanged();
			}
		}
		else if (it.key() == AmplifierDevice::DIM_VOLUME)
		{
			int val = it.value().toInt();
			if (volume != val)
			{
				volume = val;
				emit volumeChanged();
			}
		}
		++it;
	}
}


AmplifierGroup::AmplifierGroup(QString _name, QList<Amplifier *> _amplifiers, int _object_id)
{
	name = _name;
	amplifiers = _amplifiers;
	object_id = _object_id;
}

void AmplifierGroup::volumeUp() const
{
	foreach (Amplifier *amplifier, amplifiers)
		amplifier->volumeUp();
}

void AmplifierGroup::volumeDown() const
{
	foreach (Amplifier *amplifier, amplifiers)
		amplifier->volumeDown();
}

void AmplifierGroup::setActive(bool active) const
{
	foreach (Amplifier *amplifier, amplifiers)
		amplifier->setActive(active);
}


PowerAmplifierPreset::PowerAmplifierPreset(int number, const QString &name)
{
	preset_number = number;
	preset_name = name;
}

QString PowerAmplifierPreset::getName() const
{
	if (preset_number < standard_presets_size)
		return trUtf8(preset_name.toUtf8());
	else
		return preset_name;
}


PowerAmplifier::PowerAmplifier(int area, QString name, PowerAmplifierDevice *d, QList<QString> _presets) :
	Amplifier(area, name, d, ObjectInterface::IdPowerAmplifier)
{
	dev = d;
	bass = treble = balance = preset = 0;
	loud = false;

	connect(this, SIGNAL(presetChanged()), this, SIGNAL(presetDescriptionChanged()));

	for (int i = 0; i < standard_presets_size; ++i)
		presets << new PowerAmplifierPreset(i, standard_presets[i]);

	for (int i = 0; i < _presets.size(); ++i)
		presets << new PowerAmplifierPreset(i, _presets[i]);
}

ObjectDataModel *PowerAmplifier::getPresets() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectDataModel*>(&presets);
}

int PowerAmplifier::getBass() const
{
	return bass;
}

int PowerAmplifier::getTreble() const
{
	return treble;
}

int PowerAmplifier::getBalance() const
{
	return balance;
}

int PowerAmplifier::getPreset() const
{
	return preset;
}

void PowerAmplifier::setPreset(int preset)
{
	dev->setPreset(preset);
}

QString PowerAmplifier::getPresetDescription() const
{
	ObjectInterface *p = presets.getObject(preset);

	if (p)
		return p->getName();
	else
		return QString();
}

bool PowerAmplifier::getLoud() const
{
	return loud;
}

void PowerAmplifier::setLoud(bool loud)
{
	if (loud)
		dev->loudOn();
	else
		dev->loudOff();
}

void PowerAmplifier::bassDown()
{
	dev->bassDown();
}

void PowerAmplifier::bassUp()
{
	dev->bassUp();
}

void PowerAmplifier::trebleDown()
{
	dev->trebleDown();
}

void PowerAmplifier::trebleUp()
{
	dev->trebleUp();
}

void PowerAmplifier::balanceLeft()
{
	dev->balanceDown();
}

void PowerAmplifier::balanceRight()
{
	dev->balanceUp();
}

void PowerAmplifier::previousPreset()
{
	dev->prevPreset();
}

void PowerAmplifier::nextPreset()
{
	dev->nextPreset();
}

void PowerAmplifier::valueReceived(const DeviceValues &values_list)
{
	Amplifier::valueReceived(values_list);

	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		if (it.key() == PowerAmplifierDevice::DIM_BASS)
		{
			int val = it.value().toInt();
			if (bass != val)
			{
				bass = val;
				emit bassChanged();
			}
		}
		else if (it.key() == PowerAmplifierDevice::DIM_TREBLE)
		{
			int val = it.value().toInt();
			if (treble != val)
			{
				treble = val;
				emit trebleChanged();
			}
		}
		else if (it.key() == PowerAmplifierDevice::DIM_BALANCE)
		{
			int val = it.value().toInt();
			if (balance != val)
			{
				balance = val;
				emit balanceChanged();
			}
		}
		else if (it.key() == PowerAmplifierDevice::DIM_PRESET)
		{
			int val = it.value().toInt();
			if (preset != val)
			{
				preset = val;
				emit presetChanged();
			}
		}
		else if (it.key() == PowerAmplifierDevice::DIM_LOUD)
		{
			bool val = it.value().toBool();
			if (loud != val)
			{
				loud = val;
				emit loudChanged();
			}
		}
		++it;
	}
}

