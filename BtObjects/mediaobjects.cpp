#include "mediaobjects.h"
#include "multimediaplayer.h"
#include "media_device.h"
#include "mediaplayer.h"
#include "list_manager.h"
#include "devices_cache.h"
#include "xml_functions.h"

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


QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node, int id)
{
	bool is_multichannel = id == ObjectInterface::IdMultiChannelSoundDiffusionSystem;
	QList<ObjectInterface *> objects;

	SourceDevice::setIsMultichannel(is_multichannel);
	AmplifierDevice::setIsMultichannel(is_multichannel);

	// TODO init local source/amplifier, see SoundDiffusionPage::SoundDiffusionPage
	//      and send sound diffusion initialization frame

	QList<SourceObject *> sources;
	foreach (const QDomNode &source, getChildren(getChildWithName(xml_node, "sources"), "item"))
	{
		QString name = getTextChild(source, "name");
		int type = getTextChild(source, "type").toInt();
		QString where = getTextChild(source, "where");

		switch (type)
		{
		case SourceBase::Radio:
		{
			SourceRadio *source = new SourceRadio(bt_global::add_device_to_cache(new RadioSourceDevice(where)));
			SourceObject *so = new SourceObject(name, source, SourceObject::RdsRadio);
			source->setParent(so);
			source->setSourceObject(so);
			sources << so;
		}
			break;
		case SourceBase::Aux:
		{
			SourceAux *source = new SourceAux(bt_global::add_device_to_cache(new SourceDevice(where)));
			SourceObject *so = new SourceObject(name, source, SourceObject::Aux);
			source->setParent(so);
			source->setSourceObject(so);
			sources << so;
		}
			break;
		case SourceBase::MultiMedia:
		{
			SourceMultiMedia *source = new SourceMultiMedia(bt_global::add_device_to_cache(new VirtualSourceDevice(where)));
			SourceObject *ip_radio = new SourceLocalMedia("IP radio", "", source, SourceObject::IpRadio);
			sources << ip_radio;
			sources << new SourceLocalMedia("USB1", "/media/usb1", source, SourceObject::FileSystem);
			sources << new SourceLocalMedia("SD card", "/media/sd", source, SourceObject::FileSystem);
			sources << new SourceUpnpMedia("Network shares", source);
			// TODO: where are we going to destroy SourceMultiMedia?

			// use a default
			source->setSourceObject(ip_radio);
		}
			break;
		}
	}

	QList<Amplifier *> amplifiers;
	foreach (const QDomNode &amplifier, getChildren(getChildWithName(xml_node, "amplifiers"), "item"))
	{
		int id = getTextChild(amplifier, "id").toInt();
		QString name = getTextChild(amplifier, "name");
		int area = getTextChild(amplifier, "env").toInt();
		QString where = getTextChild(amplifier, "where");

		switch (id)
		{
		case ObjectInterface::IdSoundAmplifier:
			amplifiers << new Amplifier(area, name, AmplifierDevice::createDevice(where));
			break;
		case ObjectInterface::IdSoundAmplifierGeneral:
			amplifiers << new Amplifier(area, name, AmplifierDevice::createDevice(where),
								ObjectInterface::IdSoundAmplifierGeneral);
			break;
		case ObjectInterface::IdPowerAmplifier:
			QStringList sl;
			foreach(const QDomNode &preset, getChildren(amplifier, "preset"))
			{
				QString preset_name = preset.toElement().text();
				sl << preset_name;
			}
			amplifiers << new PowerAmplifier(area, name, bt_global::add_device_to_cache(new PowerAmplifierDevice(where)), sl);
			break;
		}
	}

	QList<SoundAmbient *> ambients;
	foreach (const QDomNode &ambient, getChildren(getChildWithName(xml_node, "ambients"), "item"))
	{
		int id = getTextChild(ambient, "id").toInt();
		QString name = getTextChild(ambient, "name");
		int env = getTextChild(ambient, "env").toInt();

		ambients << new SoundAmbient(env, name, id);
	}

	// connect sources with ambients
	foreach (SoundAmbient *ambient, ambients)
		ambient->connectSources(sources);

	// connect amplifiers with ambients
	foreach (SoundAmbient *ambient, ambients)
		ambient->connectAmplifiers(amplifiers);

	// create special zone (general)
	if (is_multichannel)
	{
		amplifiers << new Amplifier(0, QObject::tr("general"), AmplifierDevice::createDevice("0"),
								ObjectInterface::IdSoundAmplifierGeneral);
		SoundGeneralAmbient *general = new SoundGeneralAmbient(QObject::tr("special zone"));
		objects << general;

		foreach(SourceObject *source, sources)
			QObject::connect(source, SIGNAL(sourceForGeneralAmbientChanged(SourceObject *)), general, SLOT(setSource(SourceObject *)));
	}

	foreach (Amplifier *amplifier, amplifiers)
		objects << amplifier;
	foreach (SourceObject *source, sources)
		objects << source;
	foreach (SoundAmbient *ambient, ambients)
		objects << ambient;

	MediaPlayer::setCommandLineArguments("mplayer", QStringList(), QStringList());

	return objects;
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


SourceMedia::SourceMedia(const QString &name, SourceBase *s, SourceObjectType t) :
	SourceObject(name, s, t)
{
	media_player = new MultiMediaPlayer();
}

void SourceMedia::playlistTrackChanged()
{
	media_player->setCurrentSource(playlist->currentFilePath());
}

QObject *SourceMedia::getMediaPlayer() const
{
	return media_player;
}

void SourceMedia::previousTrack()
{
	playlist->previousFile();
}

void SourceMedia::nextTrack()
{
	playlist->nextFile();
}

void SourceMedia::startPlay(FileObject *file)
{
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
	// build playlist by recovering state from the FileObject
	EntryInfoList entry_list;
	int start_index = 0;
	for (int i = 0; i < model->getCount(); ++i)
	{
		FileObject *fo = static_cast<FileObject *>(model->getObject(i));
		if (fo->getPath() == file->getPath())
			start_index = i;
		entry_list << EntryInfo(fo->getName(), EntryInfo::AUDIO, fo->getPath());
	}

	FileListManager *list = static_cast<FileListManager *>(playlist);
	list->setList(entry_list);
	list->setCurrentIndex(start_index);
	MultiMediaPlayer *media_player = static_cast<MultiMediaPlayer *>(getMediaPlayer());
	media_player->setCurrentSource(list->currentFilePath());
	media_player->play();
}

void SourceLocalMedia::setModel(DirectoryListModel *_model)
{
	DirectoryListModelMemento *state = _model->clone();
	model->restore(state);
	delete state;
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

	// TODO: to be refactored into a protected method of SourceMedia
	MultiMediaPlayer *media_player = static_cast<MultiMediaPlayer *>(getMediaPlayer());
	media_player->setCurrentSource(list->currentFilePath());
	media_player->play();
}




SourceBase::SourceBase(SourceDevice *d, SourceType t)
{
	dev = d;
	track = 0;
	type = t;
	source_object = 0;

	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));
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


SourceRadio::SourceRadio(RadioSourceDevice *d) :
	SourceBase(d, Radio)
{
	dev = d;

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


Amplifier::Amplifier(int _area, QString _name, AmplifierDevice *d, int _object_id)
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

