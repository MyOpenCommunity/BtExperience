#include "mediaobjects.h"
#include "media_device.h"
#include "devices_cache.h"


QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node)
{
	QList<ObjectInterface *> objects;

	// TODO init local source/amplifier, see SoundDiffusionPage::SoundDiffusionPage

	RadioSourceDevice *radio = bt_global::add_device_to_cache(new RadioSourceDevice("1"));
	SourceDevice *touch = bt_global::add_device_to_cache(new SourceDevice("3"));

	objects << new SoundAmbient(2, "Cucina");
	objects << new SoundAmbient(3, "Salotto");
	objects << new SoundGeneralAmbient("Generale");
	objects << new SourceRadio(radio, "Radio");
	objects << new SourceAux(touch, "Touch");
	objects << new Amplifier(2, "Amplificatore 2", AmplifierDevice::createDevice("22"));
	objects << new Amplifier(2, "Amplificatore 3", AmplifierDevice::createDevice("23"));
	objects << new Amplifier(2, "Generale", AmplifierDevice::createDevice("#2"),
				 ObjectInterface::IdSoundAmplifierGeneral);
	objects << new Amplifier(3, "Amplificatore 2", AmplifierDevice::createDevice("32"));
	objects << new Amplifier(3, "Generale", AmplifierDevice::createDevice("#3"),
				 ObjectInterface::IdSoundAmplifierGeneral);

	return objects;
}


SoundAmbientBase::SoundAmbientBase(QString _key, QString _name)
{
	key = _key;
	name = _name;
}

ObjectListModel *SoundAmbientBase::getAmplifiers() const
{
	return NULL;
}

QObject *SoundAmbientBase::getGeneralAmplifier() const
{
	return NULL;
}

QObject *SoundAmbientBase::getCurrentSource() const
{
	return NULL;
}


SoundAmbient::SoundAmbient(int area, QString name) :
	SoundAmbientBase(QString::number(area), name)
{
}

bool SoundAmbient::getHasActiveAmplifier()
{
	return false;
}


SoundGeneralAmbient::SoundGeneralAmbient(QString name) :
	SoundAmbientBase(QString(), name)
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
	return dev->isActive();
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
}

int SourceRadio::getCurrentStation() const
{
	return 0;
}

void SourceRadio::setCurrentStation(int station)
{
}

int SourceRadio::getCurrentFrequency() const
{
	return 0;
}

void SourceRadio::previousStation()
{
}

void SourceRadio::nextStation()
{
}

void SourceRadio::frequencyUp(int steps)
{
}

void SourceRadio::frequencyDown(int steps)
{
}

void SourceRadio::searchUp()
{
}

void SourceRadio::searchDown()
{
}


Amplifier::Amplifier(int area, QString _name, AmplifierDevice *d, int _object_id)
{
	dev = d;
	key = QString::number(area);
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
