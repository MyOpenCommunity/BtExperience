#include "mediaobjects.h"
#include "media_device.h"
#include "devices_cache.h"

#define REQUEST_FREQUENCY_TIME 1000


QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node)
{
	QList<ObjectInterface *> objects;

	// TODO init local source/amplifier, see SoundDiffusionPage::SoundDiffusionPage

	RadioSourceDevice *radio = bt_global::add_device_to_cache(new RadioSourceDevice("1"));
	SourceDevice *touch = bt_global::add_device_to_cache(new SourceDevice("3"));

	QList<SourceBase *> sources;
	QList<SoundAmbient *> ambients;

	sources << new SourceRadio(radio, "Radio");
	sources << new SourceAux(touch, "Touch");

	QList<Amplifier *> amplifiers;

	ambients << new SoundAmbient(2, "Cucina");
	ambients << new SoundAmbient(3, "Salotto");

	amplifiers << new Amplifier(2, "Amplificatore 2", AmplifierDevice::createDevice("22"));
	amplifiers << new Amplifier(2, "Amplificatore 3", AmplifierDevice::createDevice("23"));
	amplifiers << new Amplifier(2, "Generale", AmplifierDevice::createDevice("#2"),
				    ObjectInterface::IdSoundAmplifierGeneral);
	amplifiers << new Amplifier(3, "Amplificatore 2", AmplifierDevice::createDevice("32"));
	amplifiers << new Amplifier(3, "Generale", AmplifierDevice::createDevice("#3"),
				    ObjectInterface::IdSoundAmplifierGeneral);

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


SoundAmbient::SoundAmbient(int _area, QString name) :
	SoundAmbientBase(name)
{
	area = _area;
	amplifier_count = 0;
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

	if (source->isActiveInArea(area))
	{
		current_source = source;
		emit currentSourceChanged();
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


SourceBase::SourceBase(SourceDevice *d, QString _name)
{
	name = _name;
	dev = d;
	track = 0;
}

QList<int> SourceBase::getActiveAreas() const
{
	return active_areas;
}

void SourceBase::setActive(int area)
{
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
	SourceBase(d, name)
{
}


SourceRadio::SourceRadio(RadioSourceDevice *d, QString name) :
	SourceBase(d, name)
{
	dev = d;

	connect(dev, SIGNAL(valueReceived(DeviceValues)), this, SLOT(valueReceived(DeviceValues)));
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
	volume = 0;
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
