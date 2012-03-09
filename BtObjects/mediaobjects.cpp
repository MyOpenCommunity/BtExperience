#include "mediaobjects.h"


QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node)
{
	QList<ObjectInterface *> objects;

	objects << new SoundAmbient(2, "Cucina");
	objects << new SoundAmbient(3, "Salotto");
	objects << new SoundGeneralAmbient("Generale");
	objects << new SoundSourceRadio(1, "Radio");
	objects << new SoundSourceAux(3, "Touch");
	objects << new SoundAmplifier(2, "Amplificatore");
	objects << new SoundAmplifier(2, "Amplificatore");
	objects << new SoundAmplifier(2, "Generale", ObjectInterface::IdSoundAmplifierGeneral);
	objects << new SoundAmplifier(3, "Amplificatore");
	objects << new SoundAmplifier(3, "Generale", ObjectInterface::IdSoundAmplifierGeneral);

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


SoundSourceBase::SoundSourceBase(int id, QString _name)
{
	name = _name;
}

QList<int> SoundSourceBase::getActiveAreas() const
{
	return QList<int>();
}

void SoundSourceBase::setActive(int area, bool active)
{
}

int SoundSourceBase::getCurrentTrack() const
{
	return 0;
}

void SoundSourceBase::setCurrentTrack(int track)
{
}

void SoundSourceBase::previousTrack()
{
}

void SoundSourceBase::nextTrack()
{
}


SoundSourceAux::SoundSourceAux(int id, QString name) :
	SoundSourceBase(id, name)
{
}


SoundSourceRadio::SoundSourceRadio(int id, QString name) :
	SoundSourceBase(id, name)
{
}

int SoundSourceRadio::getCurrentStation() const
{
	return 0;
}

void SoundSourceRadio::setCurrentStation(int station)
{
}

int SoundSourceRadio::getCurrentFrequency() const
{
	return 0;
}

void SoundSourceRadio::previousStation()
{
}

void SoundSourceRadio::nextStation()
{
}

void SoundSourceRadio::frequencyUp(int steps)
{
}

void SoundSourceRadio::frequencyDown(int steps)
{
}

void SoundSourceRadio::searchUp()
{
}

void SoundSourceRadio::searchDown()
{
}


SoundAmplifier::SoundAmplifier(int area, QString _name, int _object_id)
{
	key = QString::number(area);
	name = _name;
	object_id = _object_id;
}

bool SoundAmplifier::isActive() const
{
	return false;
}

void SoundAmplifier::setActive(bool active)
{
}

int SoundAmplifier::getVolume() const
{
	return 0;
}

void SoundAmplifier::setVolume(int volume)
{
}
