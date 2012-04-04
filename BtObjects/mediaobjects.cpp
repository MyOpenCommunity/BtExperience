#include "mediaobjects.h"
#include "media_device.h"
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

	// TODO init local source/amplifier, see SoundDiffusionPage::SoundDiffusionPage
	SourceDevice::setIsMultichannel(is_multichannel);
	AmplifierDevice::setIsMultichannel(is_multichannel);

	RadioSourceDevice *radio = bt_global::add_device_to_cache(new RadioSourceDevice("1"));
	SourceDevice *touch = bt_global::add_device_to_cache(new SourceDevice("4"));

	QList<SourceBase *> sources;

	sources << new SourceRadio(radio, "Radio");
	sources << new SourceAux(touch, "Touch");

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

	foreach (Amplifier *amplifier, amplifiers)
		objects << amplifier;
	foreach (SourceBase *source, sources)
		objects << source;
	foreach (SoundAmbient *ambient, ambients)
		objects << ambient;

	objects << new SoundGeneralAmbient("Generale");

	return objects;
}


SoundAmbientBase::SoundAmbientBase(QString _name)
{
	name = _name;
}


SoundAmbient::SoundAmbient(int _area, QString name, int _object_id) :
	SoundAmbientBase(name)
{
	area = _area;
	amplifier_count = 0;
	object_id = _object_id;
	current_source = NULL;
}

void SoundAmbient::connectSources(QList<SourceBase *> sources)
{
	foreach (SourceBase *source, sources)
		QObject::connect(source, SIGNAL(activeAreasChanged()), this, SLOT(updateActiveSource()));
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

int SoundAmbient::getArea() const
{
	return area;
}

QObject *SoundAmbient::getCurrentSource() const
{
	return current_source;
}

void SoundAmbient::updateActiveSource()
{
	SourceBase *source = static_cast<SourceBase *>(sender());

	// there are 3 cases
	//
	// - source is not active on area (isActive is true and current_source != source)
	// - source is turned on on a new area (isActive is true and current_source == source)
	// - source is turned off on the area (isActive is false and current_source == source)
	if (source->isActiveInArea(area))
	{
		if (current_source != source)
		{
			current_source = source;
			emit currentSourceChanged();
		}
	}
	else if (source == current_source)
	{
		current_source = NULL;
		emit currentSourceChanged();
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
}


SourceBase::SourceBase(SourceDevice *d, QString _name, SourceType t)
{
	name = _name;
	dev = d;
	track = 0;
	type = t;

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
	if (!isActiveInArea(area))
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

				if (active_changed)
					emit activeChanged();
			}
		}
		++it;
	}
}


SourceAux::SourceAux(SourceDevice *d, QString name) :
	SourceBase(d, name, Aux)
{
}


SourceRadio::SourceRadio(RadioSourceDevice *d, QString name) :
	SourceBase(d, name, Radio)
{
	dev = d;

	connect(this, SIGNAL(currentTrackChanged()), this, SIGNAL(currentStationChanged()));

	request_frequency.setInterval(REQUEST_FREQUENCY_TIME);
	request_frequency.setSingleShot(true);
	connect(&request_frequency, SIGNAL(timeout()), this, SLOT(requestFrequency()));
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

ObjectListModel *PowerAmplifier::getPresets() const
{
	// TODO: we remove the const because it produces an error when we export the
	// type to the qml engine. Find a solution.
	return const_cast<ObjectListModel*>(&presets);
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
