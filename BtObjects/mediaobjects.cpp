#include "mediaobjects.h"


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


SoundSourceBase::SoundSourceBase(QString _name)
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


SoundAmplifier::SoundAmplifier(int area)
{
	key = QString::number(area);
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
