#ifndef OBJECTINTERFACE_H
#define OBJECTINTERFACE_H

#include <QObject>
#include <QString>
#include <QPair>


class ObjectInterface : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int objectId READ getObjectId CONSTANT)
	Q_PROPERTY(QString name READ getName CONSTANT)
	Q_PROPERTY(QString objectKey READ getObjectKey CONSTANT)
	Q_ENUMS(ObjectId)
	Q_ENUMS(ObjectCategory)

public:
	ObjectInterface(QObject *parent = 0) : QObject(parent) {}
	virtual ~ObjectInterface() {}

	enum ObjectId
	{
		IdThermalControlUnit99 = 3,
		IdThermalControlledProbe,
		IdThermalControlUnit4,                  // 5
		IdAntintrusionSystem,
		IdHardwareSettings,
		IdMultiChannelSoundDiffusionSystem,
		IdMultiChannelSoundAmbient,
		IdMultiChannelGeneralAmbient,           // 10
		IdSoundAmplifier,
		IdSoundAmplifierGeneral,
		IdPowerAmplifier,
		IdSoundSource,
		IdPlatformSettings,                     // 15
		IdMonoChannelSoundDiffusionSystem,
		IdMonoChannelSoundAmbient,
		IdSplitBasicScenario,
		IdSplitAdvancedScenario,
		IdScenarioSystem,                       // 20
		IdSimpleScenario,
		IdScenarioModule,
		IdCCTV,
		IdRoom,
		IdIntercom,                             // 25
		IdLight = 2003,
		IdDimmer = 2001,
		IdDimmer100 = 2002,
		IdLightGroup = 2004,
		IdCommand = 2005,
		IdMax // the last value + 1, used to check the ids requested from qml
	};

	enum ObjectCategory
	{
		Unassigned = -1,
		Lighting = 1,
		ThermalRegulation,
		Antintrusion,
		Settings,
		SoundDiffusion,
		Scenarios,
		VideoEntry,
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

typedef QPair<int, ObjectInterface *> ObjectPair;


#endif // OBJECTINTERFACE_H
