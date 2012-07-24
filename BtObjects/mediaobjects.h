#ifndef MEDIAOBJECTS_H
#define MEDIAOBJECTS_H

/*!
	\defgroup SoundDiffusion Sound diffusion
*/

#include "objectinterface.h"
#include "objectmodel.h"
#include "device.h" // DeviceValues
#include "folderlistmodel.h"
#include "multimediaplayer.h"

class QDomNode;
class AmplifierDevice;
class SourceDevice;
class RadioSourceDevice;
class VirtualSourceDevice;
class Amplifier;
class SourceObject;
class SourceBase;
class PowerAmplifierDevice;
class ListManager;


QList<ObjectInterface *> createSoundDiffusionSystem(const QDomNode &xml_node, int id);

// internal class
class SoundAmbientBase : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Current sound diffusion source for the area
	*/
	Q_PROPERTY(QObject *currentSource READ getCurrentSource NOTIFY currentSourceChanged)

	Q_PROPERTY(int area READ getArea CONSTANT)

public:
	QObject *getCurrentSource() const;

	int getArea() const;

signals:
	void currentSourceChanged();

protected:
	SoundAmbientBase(QString name);
	void setCurrentSource(SourceObject *other);
	int area;

private:
	SourceObject *current_source;
};


/*!
	\ingroup SoundDiffusion
	\brief Properties for a single sound diffusion area

	The object id is \a ObjectInterface::IdMultiChannelSoundAmbient and area number is the object key
*/
class SoundAmbient : public SoundAmbientBase
{
	friend class TestSoundAmbient;

	Q_OBJECT

	/*!
		\brief Amplifier status for the area

		Returns true if there is at least one amplifier turned on in this area
	*/
	Q_PROPERTY(bool hasActiveAmplifier READ getHasActiveAmplifier NOTIFY activeAmplifierChanged)

	/*!
		\brief Previous sound diffusion source for the area
	*/
	Q_PROPERTY(QObject *previousSource READ getPreviousSource NOTIFY previousSourceChanged)

public:
	SoundAmbient(int area, QString name, int object_id);

	virtual QString getObjectKey() const { return QString::number(area); }

	virtual int getObjectId() const
	{
		return object_id;
	}

	bool getHasActiveAmplifier() const;

	QObject *getPreviousSource() const;

	void connectSources(QList<SourceObject *> sources);
	void connectAmplifiers(QList<Amplifier *> amplifiers);

signals:
	void previousSourceChanged();
	void activeAmplifierChanged();

private slots:
	void updateActiveSource(SourceObject *source_object);
	void updateActiveAmplifier();

private:
	int amplifier_count, object_id;
	SourceObject *previous_source;
};


/*!
	\ingroup SoundDiffusion
	\brief Properties for the general sound diffusion area

	The object id is \a ObjectInterface::IdMultiChannelGeneralAmbient, object key is empty
*/
class SoundGeneralAmbient : public SoundAmbientBase
{
	Q_OBJECT

public:
	SoundGeneralAmbient(QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdMultiChannelGeneralAmbient;
	}

public slots:
	void setSource(SourceObject *source);
};







/*
  Base class for objects that represent a user visible source, eg. usb, sd,
  ip radio, rds radio etc.

  Each SourceObject communicates with one SourceBase object, which handles low
  level communication with the bus.
*/
class SourceObject : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(QObject *source READ getSource CONSTANT)
	Q_PROPERTY(SourceObjectType sourceType READ getSourceType CONSTANT)
	Q_ENUMS(SourceObjectType)

public:
	enum SourceObjectType
	{
		RdsRadio,
		IpRadio,
		Aux,
		Upnp,
		FileSystem,
	};

	SourceObject(const QString &name, SourceBase *s, SourceObjectType t);

	SourceBase *getSource() const
	{
		return source;
	}

	SourceObjectType getSourceType() const
	{
		return type;
	}

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSoundSource;
	}

	void scsSourceActiveAreasChanged();
	void scsSourceForGeneralAmbientChanged();

public slots:
	/*!
		\brief Activates this source on the specified area
	*/
	void setActive(int area);

	/*!
		\brief Go to the previous track (memorized station for the radio)
	*/
	virtual void previousTrack();

	/*!
		\brief Go to the next track (memorized station for the radio)
	*/
	virtual void nextTrack();

signals:
	void activeAreasChanged(SourceObject *source_object);
	void sourceForGeneralAmbientChanged(SourceObject *);

private:
	SourceBase *source;
	SourceObjectType type;
};

class SourceMedia : public SourceObject
{
	Q_OBJECT
	Q_PROPERTY(QObject *mediaPlayer READ getMediaPlayer CONSTANT)

public:
	Q_INVOKABLE void togglePause();
	QObject *getMediaPlayer() const;

public slots:
	virtual void previousTrack();
	virtual void nextTrack();

protected:
	SourceMedia(const QString &name, SourceBase *s, SourceObjectType t);
	void play(const QString &song_path);
	ListManager *playlist;

protected slots:
	void playlistTrackChanged();

private slots:
	void handleMediaPlayerStateChange(MultiMediaPlayer::PlayerState new_state);

private:
	MultiMediaPlayer *media_player;
	bool user_track_change_request;
};


class IpRadio : public FileObject
{
	Q_OBJECT

public:
	IpRadio(const EntryInfo &info) : FileObject(info, QVariantList()) { }
	virtual int getObjectId() const
	{
		return ObjectInterface::IdIpRadio;
	}
};


class SourceIpRadio : public SourceMedia
{
	Q_OBJECT
public:
	SourceIpRadio(const QString &name, SourceBase *s);
	Q_INVOKABLE void startPlay(FileObject *file);
};


class SourceLocalMedia : public SourceMedia
{
	Q_OBJECT
	Q_PROPERTY(QVariantList rootPath READ getRootPath CONSTANT)

public:
	SourceLocalMedia(const QString &name, const QString &root_path, SourceBase *s, SourceObjectType t);
	QVariantList getRootPath() const;
	Q_INVOKABLE void startPlay(FileObject *file);
	Q_INVOKABLE void setModel(DirectoryListModel *_model);

private:
	QString root_path;
	DirectoryListModel *model;
};

class SourceUpnpMedia : public SourceMedia
{
	Q_OBJECT
public:
	SourceUpnpMedia(const QString &name, SourceBase *s);
	Q_INVOKABLE void startUpnpPlay(FileObject *file, int current_index, int total_files);
};




/*!
	\ingroup SoundDiffusion
	\brief Base class for sound diffusion sources

	The object id is \a ObjectInterface::IdSoundSource, object key is empty
*/
class SourceBase : public QObject
{
	friend class TestSourceBase;
	friend class TestSoundAmbient;

	Q_OBJECT

	/*!
		\brief Gets the active status of the source

		The value is true if the source is active in at least one of the areas,
		false otherwise.
	*/
	Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)

	/*!
		\brief Gets the list of areas that use this source
	*/
	Q_PROPERTY(QList<int> activeAreas READ getActiveAreas NOTIFY activeAreasChanged)

	/*!
		\brief Gets the current track playing on this source
	*/
	Q_PROPERTY(int currentTrack READ getCurrentTrack NOTIFY currentTrackChanged)

	Q_PROPERTY(SourceType type READ getType CONSTANT)

	Q_ENUMS(SourceType)

public:

	enum SourceType
	{
		Radio = 1,
		Aux,
		MultiMedia,
	};

	QList<int> getActiveAreas() const;

	SourceType getType() const;

	bool isActive() const;
	bool isActiveInArea(int area) const;

	int getCurrentTrack() const;

	void setActive(int area);
	void previousTrack();
	void nextTrack();

	SourceObject *getSourceObject();
	void setSourceObject(SourceObject *so);

signals:
	void activeChanged();
	void activeAreasChanged();
	void currentTrackChanged();

protected:
	SourceBase(SourceDevice *d, SourceType t);
	SourceObject *source_object;

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	SourceDevice *dev;
	int track;
	SourceType type;
	QList<int> active_areas;
};


/*!
	\ingroup SoundDiffusion
	\brief Manages an AUX source

	Can be used to control an aux adapter (for ananlogic sound input) or another
	BTicino touch screen device.
*/
class SourceAux : public SourceBase
{
	Q_OBJECT

public:
	SourceAux(SourceDevice *d);
};


class SourceMultiMedia : public SourceBase
{
	Q_OBJECT

public:
	SourceMultiMedia(VirtualSourceDevice *d);

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	VirtualSourceDevice *dev;
};


/*!
	\ingroup SoundDiffusion
	\brief Manages an RDS radio device
*/
class SourceRadio : public SourceBase
{
	friend class TestSourceRadio;

	Q_OBJECT

	/*!
		\brief Sets and gets the current memorized station

		The value can be set to 1-5 to listen to one of the memorized stations.
	*/
	Q_PROPERTY(int currentStation READ getCurrentStation WRITE setCurrentStation NOTIFY currentStationChanged)

	/*!
		\brief Gets the currently tuned frquency (in MHz * 100)
	*/
	Q_PROPERTY(int currentFrequency READ getCurrentFrequency NOTIFY currentFrequencyChanged)

	/*!
		\brief Gets the current RDS text
	*/
	Q_PROPERTY(QString rdsText READ getRdsText NOTIFY rdsTextChanged)

public:
	SourceRadio(RadioSourceDevice *d);

	int getCurrentStation() const { return getCurrentTrack(); }
	void setCurrentStation(int station);

	int getCurrentFrequency() const;

	QString getRdsText() const;

public slots:
	/*!
		\brief Go to the previous memorized station
	*/
	void previousStation();

	/*!
		\brief Go to the next memorized station
	*/
	void nextStation();

	/*!
		\brief Save current frequency to the given \a station
	*/
	void saveStation(int station);

	void startRdsUpdates();
	void stopRdsUpdates();

	/*!
		\brief Increment frequency by \a steps * 0.05 MHz
	*/
	void frequencyUp(int steps);

	/*!
		\brief Decrement frequency by \a steps * 0.05 MHz
	*/
	void frequencyDown(int steps);

	/*!
		\brief Automatic upward scan

		Sets frequency to -1 during the scan
	*/
	void searchUp();

	/*!
		\brief Automatic upward scan

		Sets frequency to -1 during the scan
	*/
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


/*!
	\ingroup SoundDiffusion
	\brief Manages a sound diffusion amplifier

	The object id is \a ObjectInterface::IdSoundAmplifier and area number is the object key
*/
class Amplifier : public ObjectInterface
{
	friend class TestAmplifier;
	friend class TestSoundAmbient;

	Q_OBJECT

	/*!
		\brief Sets or gets the on/off status of the amplifier
	*/
	Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

	/*!
		\brief Sets or gets the amplifier volume (1-31)
	*/
	Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)

public:
	Amplifier(int area, QString name, AmplifierDevice *d, int object_id = ObjectInterface::IdSoundAmplifier);

	virtual QString getObjectKey() const { return QString::number(area); }

	virtual int getObjectId() const
	{
		return object_id;
	}

	bool isActive() const;
	void setActive(bool active);

	int getVolume() const;
	void setVolume(int volume);

	int getArea() const;

	Q_INVOKABLE void volumeUp() const;
	Q_INVOKABLE void volumeDown() const;

signals:
	void activeChanged();
	void volumeChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	AmplifierDevice *dev;
	int object_id, area;
	bool active;
	int volume;
};


/*!
	\ingroup SoundDiffusion
	\brief container for a power amplifier preset

	The preset number is in the object id, the preset name in the object name.
*/
class PowerAmplifierPreset : public ObjectInterface
{
	Q_OBJECT

public:
	PowerAmplifierPreset(int number, const QString &name);

	virtual int getObjectId() const { return preset_number; }

	virtual QString getName() const { return preset_name; }

private:
	int preset_number;
	QString preset_name;
};


/*!
	\ingroup SoundDiffusion
	\brief Manages a sound diffusion power amplifier

	The object id is \a ObjectInterface::IdPowerAmplifier and area number is the object key
*/
class PowerAmplifier : public Amplifier
{
	friend class TestPowerAmplifier;

	Q_OBJECT

	/*!
		\brief Gets bass equalization (-10 to +10)
	*/
	Q_PROPERTY(int bass READ getBass NOTIFY bassChanged)

	/*!
		\brief Gets treble equalization (-10 to +10)
	*/
	Q_PROPERTY(int treble READ getTreble NOTIFY trebleChanged)

	/*!
		\brief Gets left/right balance (-10 is full left, +10 is full right)
	*/
	Q_PROPERTY(int balance READ getBalance NOTIFY balanceChanged)

	/*!
		\brief Sets and gets currently selected preset (0 to 19)
	*/
	Q_PROPERTY(int preset READ getPreset WRITE setPreset NOTIFY presetChanged)

	/*!
		\brief Gets currently selected preset description
	*/
	Q_PROPERTY(QString presetDescription READ getPresetDescription NOTIFY presetDescriptionChanged)

	/*!
		\brief Sets and gets loudness status
	*/
	Q_PROPERTY(bool loud READ getLoud WRITE setLoud NOTIFY loudChanged)

	/*!
		\brief Gets the list of available presets

		Returns a list of \ref PowerAmplifierPreset objects; the first 10
		are fixed presets, the last 10 are user-defined
	*/
	Q_PROPERTY(ObjectDataModel *presets READ getPresets CONSTANT)

public:
	PowerAmplifier(int area, QString name, PowerAmplifierDevice *d, QList<QString> custom_presets);

	ObjectDataModel *getPresets() const;

	int getBass() const;
	int getTreble() const;
	int getBalance() const;

	int getPreset() const;
	QString getPresetDescription() const;
	void setPreset(int preset);

	bool getLoud() const;
	void setLoud(bool loud);

public slots:
	/*!
		\brief Decrease bass equalization.
	*/
	void bassDown();

	/*!
		\brief Increase bass equalization.
	*/
	void bassUp();

	/*!
		\brief Decrease treble equalization.
	*/
	void trebleDown();

	/*!
		\brief Increase treble equalization.
	*/
	void trebleUp();

	/*!
		\brief Move balance to the left
	*/
	void balanceLeft();

	/*!
		\brief Move balance to the right
	*/
	void balanceRight();

	/*!
		\brief Select previous preset
	*/
	void previousPreset();

	/*!
		\brief Select next preset
	*/
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
	ObjectDataModel presets;
	int bass, treble, balance, preset;
	bool loud;

	static const char *standard_presets[];
};

#endif // MEDIAOBJECTS_H
