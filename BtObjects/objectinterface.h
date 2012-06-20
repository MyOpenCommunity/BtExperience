#ifndef OBJECTINTERFACE_H
#define OBJECTINTERFACE_H

#include "iteminterface.h"

#include <QString>
#include <QPair>


/*!
	\ingroup Core
	\brief The base class for all objects that interface with BTicino actuators

	Adds some common properties used for filtering and implements a default
	property for the object description.
*/
class ObjectInterface : public ItemInterface
{
	Q_OBJECT

	/*!
		\brief A numeric identifier for the object type.

		Most of the identifiers map directly to the \c id attribute
		in the \c archive.xml configuration file, other are used
		internally.
	*/
	Q_PROPERTY(int objectId READ getObjectId CONSTANT)

	/*!
		\brief A descriptive name for the object
	*/
	Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)

	/*!
		\brief A comma-separated string used for filtering

		\sa ObjectModel
		\sa ObjectModel::filters
	*/
	Q_PROPERTY(QString objectKey READ getObjectKey CONSTANT)

	Q_ENUMS(ObjectId)

public:
	ObjectInterface(QObject *parent = 0) : ItemInterface(parent) {}

	/// Numeric identifier for object type
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
		IdEnergyLoad,
		IdStopAndGo,
		IdStopAndGoPlus,
		IdStopAndGoBTest,
		IdEnergyData,                           // 30
		IdThermalControlledProbeFancoil, //!< Thermal controlled probe with fancoil
		IdThermalNonControlledProbe, //!< Thermal non-controlled probe device
		IdThermalExternalProbe, //!< Thermal external probe device
		// used internally
		IdDimmerGroup = 100, //!< Group of lights containing only dimmer objects
		IdDimmer100Group = 101, //!< group of lights containing only 100-level dimmer objects
		// from configuration file
		// lights
		IdDimmerFixed = 2001, //!< 10-level dimmer
		IdLightGroup = 2004, //!< A set of lights
		IdLightCommand = 2005, //!< Command to control the lights for an environment or all the lights
		// antintrusion
		IdAntintrusionZone = 13001, //!< A signe anti-intrusion zone
		IdAntintrusionScenario = 13010, //!< Set of anti-intrusion zones
		IdAntintrusionAux = 13101, //!< Auxiliary alarm channel (for technical alarms)

		// the following constants don't have a correspondence 1-to-1 with
		// ids used in configuration file; ids used in configuration file
		// are defined inside the anonymous namespace contained in
		// btobjectsplugin.cpp file
		IdLightCustom = 10012003, //!< A simple light actuator with custom time
		IdLightFixed = 10002003, //!< A simple light actuator with fixed time
		IdDimmer100Custom = 10012002, //!< 100-level dimmer with custom time
		IdDimmer100Fixed = 10002002, //!< 100-level dimmer with fixed time

		IdMax // the last value + 1, used to check the ids requested from qml
	};

	virtual int getObjectId() const;

	// an unique key to identify an object from the others with the same id.
	virtual QString getObjectKey() const;

	// the name of the object
	virtual QString getName() const;
	virtual void setName(const QString &n);

signals:
	void nameChanged();

protected:
	QString name;
};

typedef QPair<int, ObjectInterface *> ObjectPair;


#endif // OBJECTINTERFACE_H
