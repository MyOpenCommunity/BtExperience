#include "mediaobjects.h"
#include "media_device.h"
#include "list_manager.h"
#include "devices_cache.h"
#include "xml_functions.h"
#include "xmlobject.h"

#include <QDebug>
#include <QStringList>

#define REQUEST_FREQUENCY_TIME 1000

const char *PowerAmplifier::standard_presets[] =
{
	QT_TR_NOOP("Normal"),
	QT_TR_NOOP("Dance"),
	QT_TR_NOOP("Pop"),
	QT_TR_NOOP("Rock"),
	QT_TR_NOOP("Classical"),
	QT_TR_NOOP("Techno"),
	QT_TR_NOOP("Party"),
	QT_TR_NOOP("Soft"),
	QT_TR_NOOP("Full Bass"),
	QT_TR_NOOP("Full Treble"),
};
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
		source->setParent(so);
		source->setSourceObject(so);

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
		source->setParent(so);
		source->setSourceObject(so);

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
		source->setParent(so);
		source->setSourceObject(so);
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

		obj_list << ObjectPair(uii, new Amplifier(area, v.value("descr"), d));
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

QList<ObjectInterface *> createLocalSources(bool is_multichannel)
{
	QList<ObjectInterface *> sources;

	// TODO init local source/amplifier, see SoundDiffusionPage::SoundDiffusionPage

	if (!(*bt_global::config)[SOURCE_ADDRESS].isEmpty() || !(*bt_global::config)[AMPLIFIER_ADDRESS].isEmpty())
	{
		QString init_frame = VirtualSourceDevice::createMediaInitFrame(is_multichannel,
									       (*bt_global::config)[SOURCE_ADDRESS],
									       (*bt_global::config)[AMPLIFIER_ADDRESS]);
		bt_global::devices_cache.addInitCommandFrame(0, init_frame);
	}

	if ((*bt_global::config)[SOURCE_ADDRESS].isEmpty())
		return sources;

	SourceMultiMedia *source = new SourceMultiMedia(bt_global::add_device_to_cache(new VirtualSourceDevice((*bt_global::config)[SOURCE_ADDRESS])));

	// TODO use configuration...
	sources << new SourceIpRadio(QObject::tr("IP radio"), source);
	sources << new SourceLocalMedia("USB1", "/media/sda1", source, SourceObject::FileSystem);
	sources << new SourceLocalMedia("SD card", "/media/mmcblk0p1", source, SourceObject::FileSystem);
	sources << new SourceUpnpMedia("Network shares", source);

	// use a default
	source->setSourceObject(static_cast<SourceObject *>(sources[0]));
	// one of the above, used to destroy the object
	source->setParent(sources[0]);

	return sources;
}
SoundAmbientBase::SoundAmbientBase(QString _name)
{
	name = _name;
	current_source = 0;
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


SoundAmbient::SoundAmbient(int _area, QString name, int _object_id) :
	SoundAmbientBase(name)
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


SoundGeneralAmbient::SoundGeneralAmbient(QString name) :
	SoundAmbientBase(name)
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

bool SourceMedia::user_track_change_request = false;

SourceMedia::SourceMedia(const QString &name, SourceBase *s, SourceObjectType t) :
	SourceObject(name, s, t)
{
	media_player = new MultiMediaPlayer();
	connect(media_player, SIGNAL(playerStateChanged(MultiMediaPlayer::PlayerState)),
		SLOT(handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState)));
}

void SourceMedia::play(const QString &song_path)
{
	user_track_change_request = true;
	media_player->setCurrentSource(song_path);
	if (media_player->getPlayerState() == MultiMediaPlayer::Stopped)
		media_player->play();
}

void SourceMedia::playlistTrackChanged()
{
	play(playlist->currentFilePath());
}

QObject *SourceMedia::getMediaPlayer() const
{
	return media_player;
}

void SourceMedia::previousTrack()
{
	user_track_change_request = true;
	if (playlist)
		playlist->previousFile();
}

void SourceMedia::nextTrack()
{
	user_track_change_request = true;
	if (playlist)
		playlist->nextFile();
}

void SourceMedia::togglePause()
{
	if (media_player->getPlayerState() == MultiMediaPlayer::Playing)
	{
		media_player->pause();
	}
	else
	{
		media_player->resume();
	}
}

void SourceMedia::handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state)
{
	if (new_state == MultiMediaPlayer::Stopped && !user_track_change_request)
		if (playlist)
			playlist->nextFile();
	user_track_change_request = false;
}


SourceIpRadio::SourceIpRadio(const QString &name, SourceBase *s) :
	SourceMedia(name, s, IpRadio)
{
}

void SourceIpRadio::startPlay(FileObject *file)
{
	play(file->getPath());
}


SourceLocalMedia::SourceLocalMedia(const QString &name, const QString &_root_path, SourceBase *s, SourceObjectType t) :
	SourceMedia(name, s, t)
{
	root_path = _root_path;
	model = new DirectoryListModel(this);
	playlist = new FileListManager;
	connect(playlist, SIGNAL(currentFileChanged()), SLOT(playlistTrackChanged()));
}

void SourceLocalMedia::startPlay(FileObject *file)
{
	EntryInfoList entry_list;
	int start_index = 0;
	int skipped_entries = 0;
	for (int i = 0; i < model->getCount(); ++i)
	{
		FileObject *fo = static_cast<FileObject *>(model->getObject(i));
		if (fo->getPath() == file->getPath())
			start_index = i;

		// skip directories from playlist
		if (fo->getFileType() == FileObject::Directory)
			++skipped_entries;
		else
			entry_list << fo->getEntryInfo();
	}

	FileListManager *list = static_cast<FileListManager *>(playlist);
	list->setList(entry_list);
	list->setCurrentIndex(start_index - skipped_entries);
	play(file->getPath());
}

void SourceLocalMedia::setModel(DirectoryListModel *_model)
{
	if (_model != model)
	{
		DirectoryListModelMemento *state = _model->clone();
		model->restore(state);
		// remove any range that may be set
		model->setRange(QVariantList() << 0 << model->getCount());
		delete state;
	}
}

QVariantList SourceLocalMedia::getRootPath() const
{
	QVariantList list;

	foreach (const QString &s, root_path.split("/", QString::SkipEmptyParts))
		list << s;
	return list;
}


SourceUpnpMedia::SourceUpnpMedia(const QString &name, SourceBase *s) :
	SourceMedia(name, s, Upnp)
{
	playlist = new UPnpListManager(UPnPListModel::getXmlDevice());
	connect(playlist, SIGNAL(currentFileChanged()), SLOT(playlistTrackChanged()));
}

void SourceUpnpMedia::startUpnpPlay(FileObject *file, int current_index, int total_files)
{
	UPnpListManager *list = static_cast<UPnpListManager *>(playlist);
	list->setStartingFile(file->getEntryInfo());
	list->setCurrentIndex(current_index);
	list->setTotalFiles(total_files);
	play(file->getPath());
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
			qDebug() << "REQ_SOURCE_ON/OFF";
			break;

		case SourceDevice::DIM_AREAS_UPDATED:
		{
			bool status = dev->isActive();

			// TODO: do something smart here
//			if (!status)
//				source_object->pauseLocalPlayback();
		}
			break;

		case VirtualSourceDevice::REQ_NEXT_TRACK:
			source_object->nextTrack();
			break;

		case VirtualSourceDevice::REQ_PREV_TRACK:
			source_object->previousTrack();
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


AmplifierGroup::AmplifierGroup(QString _name, QList<Amplifier *> _amplifiers)
{
	name = _name;
	amplifiers = _amplifiers;
}

void AmplifierGroup::setActive(bool active)
{
	foreach (Amplifier *amplifier, amplifiers)
		amplifier->setActive(active);
}

void AmplifierGroup::setVolume(int volume)
{
	foreach (Amplifier *amplifier, amplifiers)
		amplifier->setVolume(volume);
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


PowerAmplifierPreset::PowerAmplifierPreset(int number, const QString &name)
{
	preset_number = number;
	preset_name = name;
}


PowerAmplifier::PowerAmplifier(int area, QString name, PowerAmplifierDevice *d, QList<QString> _presets) :
	Amplifier(area, name, d, ObjectInterface::IdPowerAmplifier)
{
	dev = d;
	bass = treble = balance = preset = 0;
	loud = false;

	connect(this, SIGNAL(presetChanged()), this, SIGNAL(presetDescriptionChanged()));

	for (int i = 0; i < standard_presets_size; ++i)
		presets << new PowerAmplifierPreset(i, tr(standard_presets[i]));

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

