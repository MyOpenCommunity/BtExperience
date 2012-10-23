#ifndef OBJECTINTERFACE_H
#define OBJECTINTERFACE_H

#include "iteminterface.h"

#include <QString>
#include <QPair>

class QDomNode;
class ObjectInterface;
class device;


void updateObjectName(QDomNode node, ObjectInterface *item);


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
	ObjectInterface(QObject *parent = 0);

	/// Numeric identifier for object type
	enum ObjectId
	{
		IdAntintrusionSystem = 1,
		IdHardwareSettings,
		IdMultiChannelSoundDiffusionSystem,
		IdSoundAmplifier,
		IdSoundAmplifierGeneral,
		IdPowerAmplifier,
		IdSoundSource,
		IdPlatformSettings,
		IdMonoChannelSoundAmbient,
		IdSoundAmplifierGroup,                  // 10

		IdMultiChannelSoundAmbient = 14,        // Container::IdAmbient
		IdMultiChannelGeneralAmbient = 16,      // Container::IdSpecialAmbient

		IdCCTV = 23,
		IdRoom,
		IdIntercom,                             // 25

		IdEnergyFamily, //!< Group of energy lines
		IdEnergyLoad, //!< Energy load object
		IdThermalControlledProbe, //!< Thermal controlled probe
		IdThermalControlledProbeFancoil, //!< Thermal controlled probe with fancoil

		IdDangers,                              // 30
		IdScenarioModulesNotifier,
		IdEnergies,

		// used internally
		IdDimmerGroup = 100, //!< Group of lights containing only dimmer objects
		IdDimmer100Group = 101, //!< group of lights containing only 100-level dimmer objects
		// from configuration file
		// scenarios
		IdSimpleScenario = 1001, //!< Scenario unit
		IdScenarioModule = 1002, //!< Scenario module
		IdScenarioPlus = 1003, //!< Scenario plus
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
		// energy management
		IdStopAndGo = 6101, //!< Stop and go
		IdStopAndGoPlus = 6102, //!< Stop and go Plus
		IdStopAndGoBTest = 6103, //!< Stop and go BTest
		IdEnergyData = 6105, //!< Energy data
		// note that the follwoing three types are all parsed into an IdEnergyLoad object
		IdLoadDiagnostic = 6104, //!< Load diagnostic
		IdLoadWithControlUnit = 6111, //!< Energy load with control unit
		IdLoadWithoutControlUnit = 6112, //!< Energy load without control unit
		// advanced/scheduled scenarios
		IdAdvancedScenario = 9001,
		IdScheduledScenario = 9002,
		// air conditioning
		IdSplitBasicScenario = 8010,
		IdSplitAdvancedScenario = 8014,
		IdSplitBasicCommand = 8011,
		IdSplitAdvancedCommand = 8015,
		IdSplitBasicGenericCommand = 8012,
		IdSplitAdvancedGenericCommand = 8016,
		IdSplitBasicGenericCommandGroup = 8013,
		IdSplitAdvancedGenericCommandGroup = 8017,

		IdExternalPlace = 10050,
		IdSurveillanceCamera = 10051,
		IdInternalIntercom = 10052,
		IdExternalIntercom = 10053,
		IdSwitchboard = 10054, // a.k.a. guard unit

		IdRadioSource = 11032,
		IdAuxSource = 11033,
		IdMultimediaSource = 11034,

		IdMonoAmplifier = 11029,
		IdMonoAmplifierGroup = 11030,
		IdMonoPowerAmplifier = 11031,

		IdMultiAmplifier = 11001,
		IdMultiAmplifierGroup = 11002,
		IdMultiGeneral = 11003,
		IdMultiPowerAmplifier = 11004,

		IdEnergyRate = 14267,

		IdIpRadio = 16000,
		IdDeviceUPnP = 16006,
		IdDeviceUSB = 16007,
		IdDeviceSD = 16008,

		IdMessages = 16004,

		// the following constants don't have a correspondence 1-to-1 with
		// ids used in configuration file; ids used in configuration file
		// are defined inside the anonymous namespace contained in
		// btobjectsplugin.cpp file
		IdDimmer100Custom = 10012002, //!< 100-level dimmer with custom time
		IdDimmer100Fixed = 10022002, //!< 100-level dimmer with fixed time
		IdLightCustom = 10012003, //!< A simple light actuator with custom time
		IdLightFixed = 10022003, //!< A simple light actuator with fixed time

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

	/*!
		\brief Mark object as enabled

		Objects are initially disabled, and should not perform SCS initialization, even
		if \ref initializeObject is called.

		\ref enableObject marks the object for later initialization
	 */
	virtual void enableObject() {}

	/*!
		\brief Initialize object

		Called after \ref enableObject to actually perform object initialization; typically
		called by \ref ObjectModel::getObject (right before the object is displayed).
	 */
	virtual void initializeObject() {}

	virtual void setContainerUii(int uii);

signals:
	void nameChanged();

protected:
	QString name;
};


/*!
	\ingroup Core
	\brief Default implementation for objects using a device

	Default implementation for \ref enableObject and \ref initializeObject
	useful for most objects containing a device.

	The device is marked as disabled on object creation and initialized with
	deferred initialization when the object is enabled/initialized.
*/
class DeviceObjectInterface : public ObjectInterface
{
public:
	DeviceObjectInterface(device *dev, QObject *parent = 0);

	virtual void enableObject();
	virtual void initializeObject();

private:
	device *dev;
};

typedef QPair<int, ObjectInterface *> ObjectPair;


#endif // OBJECTINTERFACE_H
