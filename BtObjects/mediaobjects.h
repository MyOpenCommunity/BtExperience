#ifndef MEDIAOBJECTS_H
#define MEDIAOBJECTS_H

#include "objectinterface.h"
#include "objectlistmodel.h"
#include "device.h" // DeviceValues

class QDomNode;
class AmplifierDevice;
class SourceDevice;
class RadioSourceDevice;
class Amplifier;
class SourceBase;
class PowerAmplifierDevice;


// ambients and amplifiers have the area number as the key

QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node);

// internal class
class SoundAmbientBase : public ObjectInterface
{
	Q_OBJECT

public:
	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::SoundDiffusion;
	}

	virtual QString getName() const { return name; }

protected:
	SoundAmbientBase(QString name);

private:
	QString name;
};


class SoundAmbient : public SoundAmbientBase
{
	friend class TestSoundAmbient;

	Q_OBJECT
	Q_PROPERTY(bool hasActiveAmplifier READ getHasActiveAmplifier NOTIFY activeAmplifierChanged)
	Q_PROPERTY(QObject *currentSource READ getCurrentSource NOTIFY currentSourceChanged)

public:
	SoundAmbient(int area, QString name);

	virtual QString getObjectKey() const { return QString::number(area); }

	virtual int getObjectId() const
	{
		return ObjectInterface::IdMultiChannelSoundAmbient;
	}

	bool getHasActiveAmplifier() const;

	int getArea() const;

	QObject *getCurrentSource() const;

	void connectSources(QList<SourceBase *> sources);
	void connectAmplifiers(QList<Amplifier *> amplifiers);

signals:
	void currentSourceChanged();
	void activeAmplifierChanged();

private slots:
	void updateActiveSource();
	void updateActiveAmplifier();

private:
	int area, amplifier_count;
	SourceBase *current_source;
};


class SoundGeneralAmbient : public SoundAmbientBase
{
	Q_OBJECT

public:
	SoundGeneralAmbient(QString name);

	virtual QString getObjectKey() const { return QString(); }

	virtual int getObjectId() const
	{
		return ObjectInterface::IdMultiChannelGeneralAmbient;
	}
};


// internal class
class SourceBase : public ObjectInterface
{
	friend class TestSourceBase;
	friend class TestSoundAmbient;

	Q_OBJECT
	Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)
	Q_PROPERTY(QList<int> activeAreas READ getActiveAreas NOTIFY activeAreasChanged)
	Q_PROPERTY(int currentTrack READ getCurrentTrack NOTIFY currentTrackChanged)

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

	bool isActive() const;
	bool isActiveInArea(int area) const;

	int getCurrentTrack() const;

public slots:
	void setActive(int area);
	void previousTrack();
	void nextTrack();

signals:
	void activeChanged();
	void activeAreasChanged();
	void currentTrackChanged();

protected:
	SourceBase(SourceDevice *d, QString name);

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	QString name;
	SourceDevice *dev;
	int track;
	QList<int> active_areas;
};


class SourceAux : public SourceBase
{
	Q_OBJECT

public:
	SourceAux(SourceDevice *d, QString name);
};


class SourceRadio : public SourceBase
{
	friend class TestSourceRadio;

	Q_OBJECT
	Q_PROPERTY(int currentStation READ getCurrentStation WRITE setCurrentStation NOTIFY currentStationChanged)
	Q_PROPERTY(int currentFrequency READ getCurrentFrequency NOTIFY currentFrequencyChanged)
	Q_PROPERTY(QString rdsText READ getRdsText NOTIFY rdsTextChanged)

public:
	SourceRadio(RadioSourceDevice *d, QString name);

	int getCurrentStation() const { return getCurrentTrack(); }
	void setCurrentStation(int station);

	int getCurrentFrequency() const;

	QString getRdsText() const;

public slots:
	void previousStation();
	void nextStation();
	void saveStation(int station);

	void startRdsUpdates();
	void stopRdsUpdates();

	// changes frequency by steps * 0.05 MHz
	void frequencyUp(int steps);
	void frequencyDown(int steps);

	// automatic scan up/down; sets frequency to -1 during scanning
	void searchUp();
	void searchDown();

signals:
	void currentStationChanged();
	void currentFrequencyChanged();
	void rdsTextChanged();

private slots:
	virtual void valueReceived(const DeviceValues &values_list);
	void requestFrequency();

private:
	RadioSourceDevice *dev;
	int frequency;
	QString rds_text;
	QTimer request_frequency;
};


class Amplifier : public ObjectInterface
{
	friend class TestAmplifier;
	friend class TestSoundAmbient;

	Q_OBJECT
	Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)
	Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)

public:
	Amplifier(int area, QString name, AmplifierDevice *d, int object_id = ObjectInterface::IdSoundAmplifier);

	virtual QString getObjectKey() const { return QString::number(area); }

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

	int getArea() const;

signals:
	void activeChanged();
	void volumeChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	AmplifierDevice *dev;
	QString name;
	int object_id, area;
	bool active;
	int volume;
};


class PowerAmplifierPreset : public ObjectInterface
{
	Q_OBJECT

public:
	PowerAmplifierPreset(int number, const QString &name);

	virtual int getObjectId() const { return preset_number; }

	virtual QString getObjectKey() const { return QString(); }

	virtual ObjectCategory getCategory() const { return SoundDiffusion; }

	virtual QString getName() const { return preset_name; }

private:
	int preset_number;
	QString preset_name;
};


class PowerAmplifier : public Amplifier
{
	friend class TestPowerAmplifier;

	Q_OBJECT
	Q_PROPERTY(int bass READ getBass NOTIFY bassChanged)
	Q_PROPERTY(int treble READ getTreble NOTIFY trebleChanged)
	Q_PROPERTY(int balance READ getBalance NOTIFY balanceChanged)
	Q_PROPERTY(int preset READ getPreset WRITE setPreset NOTIFY presetChanged)
	Q_PROPERTY(QString presetDescription READ getPresetDescription NOTIFY presetDescriptionChanged)
	Q_PROPERTY(bool loud READ getLoud WRITE setLoud NOTIFY loudChanged)
	Q_PROPERTY(ObjectListModel *presets READ getPresets CONSTANT)

public:
	PowerAmplifier(int area, QString name, PowerAmplifierDevice *d, QList<QString> custom_presets);

	ObjectListModel *getPresets() const;

	int getBass() const;
	int getTreble() const;
	int getBalance() const;

	int getPreset() const;
	QString getPresetDescription() const;
	void setPreset(int preset);

	bool getLoud() const;
	void setLoud(bool loud);

public slots:
	void bassDown();
	void bassUp();

	void trebleDown();
	void trebleUp();

	void balanceLeft();
	void balanceRight();

	void previousPreset();
	void nextPreset();

signals:
	void bassChanged();
	void trebleChanged();
	void balanceChanged();
	void presetChanged();
	void presetDescriptionChanged();
	void loudChanged();

private  slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	PowerAmplifierDevice *dev;
	ObjectListModel presets;
	int bass, treble, balance, preset;
	bool loud;

	static const char *standard_presets[];
};

#endif // MEDIAOBJECTS_H
