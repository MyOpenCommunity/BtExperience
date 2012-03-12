#ifndef MEDIAOBJECTS_H
#define MEDIAOBJECTS_H

#include "objectinterface.h"
#include "objectlistmodel.h"

class QDomNode;


QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node);

// internal class
class SoundAmbientBase : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(ObjectListModel *amplifiers READ getAmplifiers CONSTANT)
	Q_PROPERTY(QObject *generalAmplifier READ getGeneralAmplifier CONSTANT)
	Q_PROPERTY(QObject *currentSource READ getCurrentSource NOTIFY currentSourceChanged)

public:
	virtual QString getObjectKey() const { return key; }

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::SoundDiffusion;
	}

	virtual QString getName() const { return name; }

	ObjectListModel *getAmplifiers() const;
	QObject *getGeneralAmplifier() const;
	QObject *getCurrentSource() const;

signals:
	void currentSourceChanged();

protected:
	SoundAmbientBase(QString key, QString name);

private:
	QString key, name;
};


class SoundAmbient : public SoundAmbientBase
{
	Q_OBJECT
	Q_PROPERTY(bool hasActiveAmplifier READ getHasActiveAmplifier NOTIFY activeAmplifierChanged)

public:
	SoundAmbient(int area, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdMultiChannelSoundAmbient;
	}

	bool getHasActiveAmplifier();

signals:
	void activeAmplifierChanged();
};


class SoundGeneralAmbient : public SoundAmbientBase
{
	Q_OBJECT

public:
	SoundGeneralAmbient(QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdMultiChannelGeneralAmbient;
	}
};


// internal class
class SourceBase : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(QList<int> activeAreas READ getActiveAreas NOTIFY activeAreasChanged)
	Q_PROPERTY(int currentTrack READ getCurrentTrack WRITE setCurrentTrack NOTIFY currentTrackChanged)

public:
	virtual QString getObjectKey() const { return QString(); }

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::SoundDiffusion;
	}

	virtual QString getName() const { return name; }

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSoundSource;
	}

	QList<int> getActiveAreas() const;

	int getCurrentTrack() const;
	void setCurrentTrack(int track);

public slots:
	void setActive(int area, bool status);
	void previousTrack();
	void nextTrack();

signals:
	void activeAreasChanged();
	void currentTrackChanged();

protected:
	SourceBase(int id, QString name);

private:
	QString name;
};


class SourceAux : public SourceBase
{
	Q_OBJECT

public:
	SourceAux(int id, QString name);
};


class SourceRadio : public SourceBase
{
	Q_OBJECT
	Q_PROPERTY(int currentStation READ getCurrentStation WRITE setCurrentStation NOTIFY currentStationChanged)
	Q_PROPERTY(int currentFrequency READ getCurrentFrequency NOTIFY currentFrequencyChanged)

public:
	SourceRadio(int id, QString name);

	int getCurrentStation() const;
	void setCurrentStation(int station);

	int getCurrentFrequency() const;

public slots:
	void previousStation();
	void nextStation();

	// changes frequency by steps * 0.05 MHz
	void frequencyUp(int steps);
	void frequencyDown(int steps);

	void searchUp();
	void searchDown();

signals:
	void currentStationChanged();
	void currentFrequencyChanged();
};


class Amplifier : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)
	Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)

public:
	Amplifier(int area, QString name, int object_id = ObjectInterface::IdSoundAmplifier);

	virtual QString getObjectKey() const { return key; }

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::SoundDiffusion;
	}

	virtual QString getName() const { return name; }

	virtual int getObjectId() const
	{
		return object_id;
	}

	bool isActive() const;
	void setActive(bool active);

	int getVolume() const;
	void setVolume(int volume);

signals:
	void activeChanged();
	void volumeChanged();

private:
	QString key, name;
	int object_id;
};

#endif // MEDIAOBJECTS_H
