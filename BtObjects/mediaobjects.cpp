#include "mediaobjects.h"


ObjectListModel *SoundAmbientBase::getSources() const
{
	return NULL;
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


bool SoundAmbient::getHasActiveAmplifier()
{
	return false;
}


bool SoundSourceBase::isActive() const
{
	return false;
}

void SoundSourceBase::setActive(bool active)
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
