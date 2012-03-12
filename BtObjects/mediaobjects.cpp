#include "mediaobjects.h"


QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node)
{
	QList<ObjectInterface *> objects;

	objects << new SoundAmbient(2, "Cucina");
	objects << new SoundAmbient(3, "Salotto");
	objects << new SoundGeneralAmbient("Generale");
	objects << new SourceRadio(1, "Radio");
	objects << new SourceAux(3, "Touch");
	objects << new Amplifier(2, "Amplificatore");
	objects << new Amplifier(2, "Amplificatore");
	objects << new Amplifier(2, "Generale", ObjectInterface::IdSoundAmplifierGeneral);
	objects << new Amplifier(3, "Amplificatore");
	objects << new Amplifier(3, "Generale", ObjectInterface::IdSoundAmplifierGeneral);

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


SourceBase::SourceBase(int id, QString _name)
{
	name = _name;
}

QList<int> SourceBase::getActiveAreas() const
{
	return QList<int>();
}

void SourceBase::setActive(int area, bool active)
{
}

int SourceBase::getCurrentTrack() const
{
	return 0;
}

void SourceBase::setCurrentTrack(int track)
{
}

void SourceBase::previousTrack()
{
}

void SourceBase::nextTrack()
{
}


SourceAux::SourceAux(int id, QString name) :
	SourceBase(id, name)
{
}


SourceRadio::SourceRadio(int id, QString name) :
	SourceBase(id, name)
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


Amplifier::Amplifier(int area, QString _name, int _object_id)
{
	key = QString::number(area);
	name = _name;
	object_id = _object_id;
}

bool Amplifier::isActive() const
{
	return false;
}

void Amplifier::setActive(bool active)
{
}

int Amplifier::getVolume() const
{
	return 0;
}

void Amplifier::setVolume(int volume)
{
}
