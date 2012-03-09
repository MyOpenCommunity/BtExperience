#ifndef OBJECTINTERFACE_H
#define OBJECTINTERFACE_H

#include <QObject>
#include <QString>


class ObjectInterface : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int objectId READ getObjectId CONSTANT)
	Q_PROPERTY(QString name READ getName CONSTANT)
	Q_PROPERTY(QString objectKey READ getObjectKey CONSTANT)
	Q_ENUMS(ObjectId)
	Q_ENUMS(ObjectCategory)

public:
	virtual ~ObjectInterface() {}

	enum ObjectId
	{
		IdLight = 1,
		IdDimmer,
		IdThermalControlUnit99,
		IdThermalControlledProbe,
		IdThermalControlUnit4,
		IdAntintrusionSystem,
		IdHardwareSettings,
		IdMultiChannelSoundAmbient,
		IdSoundAmplifier,
		IdSoundSource,
		IdMax // the last value + 1, used to check the ids requested from qml
	};

	enum ObjectCategory
	{
		Lighting = 1,
		ThermalRegulation,
		Antintrusion,
		Settings,
		SoundDiffusion
	};

	virtual int getObjectId() const = 0;

	// an unique key to identify an object from the others with the same id.
	virtual QString getObjectKey() const = 0;

	// the category (ex: lighting, automation, etc..)
	virtual ObjectCategory getCategory() const = 0;

	// the name of the object
	virtual QString getName() const = 0;

signals:
	void dataChanged();
};


#endif // OBJECTINTERFACE_H
