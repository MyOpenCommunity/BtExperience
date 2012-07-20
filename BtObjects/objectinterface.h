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
		IdAntintrusionSystem = 6,
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
		IdScenarioSystem,                       // 20 - TO BE REMOVED
		IdCCTV = 23,
		IdRoom,
		IdIntercom,                             // 25
		IdEnergyLoad,
		IdStopAndGo,
		IdStopAndGoPlus,
		IdStopAndGoBTest,
		IdEnergyData,                           // 30
		IdThermalControlledProbe, //!< Thermal controlled probe
		IdThermalControlledProbeFancoil, //!< Thermal controlled probe with fancoil
		// used internally
		IdDimmerGroup = 100, //!< Group of lights containing only dimmer objects
		IdDimmer100Group = 101, //!< group of lights containing only 100-level dimmer objects
		// from configuration file
		// lights
		IdDimmerFixed = 2001, //!< 10-level dimmer
		IdLightGroup = 2004, //!< A set of lights
		IdLightCommand = 2005, //!< Command to control the lights for an environment or all the lights
		// automation
		IdAutomation2 = 3002, //!< A simple 2-states automation actuator (Fan,watering, controlled socket)
		IdAutomation3 = 3000, //!< A 3-states automation actuator (Curtain, garage, shutter, gate)
		IdAutomationVDE = 3001, //!< A 1-state VDE Gate/Door actuator
		IdAutomationDoor = 3003, //!< A 1-state Door lock actuator
		IdAutomationContact = 3004, //!< Automation Contact actuator
		IdAutomationCommand2 = 3007, //!< Automation AMB, GEN, GR
		IdAutomationCommand3 = 3008, //!< Automation 3-states AMB, GEN, GR
		IdAutomationGroup2 = 3006, //!< Group of automation 2-state
		IdAutomationGroup3 = 3005, //!< Group of automation 3-state
		// antintrusion
		IdAntintrusionZone = 13001, //!< A signe anti-intrusion zone
		IdAntintrusionScenario = 13010, //!< Set of anti-intrusion zones
		IdAntintrusionAux = 13101, //!< Auxiliary alarm channel (for technical alarms)
		// thermal regulation
		IdThermalControlUnit99 = 8001, //!< Control unit for 99 zones
		IdThermalControlledProbe99 = 8002, //!< Controlled probe for 99 zones (configuration file)
		IdThermalControlUnit4 = 8003, //!< Control unit for 4 zones
		IdThermalControlledProbe4Zone1 = 8004, //!< Controlled probe for 4 zones zone 1 (configuration file)
		IdThermalControlledProbe4Zone2 = 8005, //!< Controlled probe for 4 zones zone 2 (configuration file)
		IdThermalControlledProbe4Zone3 = 8006, //!< Controlled probe for 4 zones zone 3 (configuration file)
		IdThermalControlledProbe4Zone4 = 8007, //!< Controlled probe for 4 zones zone 4 (configuration file)
		IdThermalExternalProbe = 8008, //!< Thermal external probe device
		IdThermalNonControlledProbe = 8009, //!< Thermal non-controlled probe device

		// the following constants don't have a correspondence 1-to-1 with
		// ids used in configuration file; ids used in configuration file
		// are defined inside the anonymous namespace contained in
		// btobjectsplugin.cpp file
		IdDimmer100Custom = 10012002, //!< 100-level dimmer with custom time
		IdDimmer100Fixed = 10022002, //!< 100-level dimmer with fixed time
		IdLightCustom = 10012003, //!< A simple light actuator with custom time
		IdLightFixed = 10022003, //!< A simple light actuator with fixed time

		IdSimpleScenario,
		IdScenarioModule,
		IdScheduledScenario,
		IdAdvancedScenario,

		// the last value + 1, used to check the ids requested from qml
		// NOTE: always verify is the highest value out there!
		IdMax
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
