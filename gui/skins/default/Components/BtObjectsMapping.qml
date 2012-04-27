import QtQuick 1.1
import BtObjects 1.0

import Components.Lighting 1.0
import Components.Scenarios 1.0
import Components.Settings 1.0
import Components.SoundDiffusion 1.0
import Components.ThermalRegulation 1.0


/**
  * Uses new Javascript operator to create components.
  * It is not standard practice, so it may cease to work in future versions
  * of Qt. In such a case it is possible to revert to file names.
  * About new operator usage, we use the component object to instantiate
  * some other objects later, but we don't use them for anything else.
  * IMHO this is not standard practice, but it is not harmful either.
  */
QtObject {
    function getComponent(objectId) {
        switch (objectId) {
        case ObjectInterface.IdLight:
            return new Light()
        case ObjectInterface.IdDimmer:
            return new Dimmer()
        case ObjectInterface.IdThermalControlUnit99:
            return new ThermalControlUnit()
        case ObjectInterface.IdThermalControlledProbe:
            return new ThermalControlledProbe()
        case ObjectInterface.IdHardwareSettings:
            return new Brightness()
        case ObjectInterface.IdMultiChannelGeneralAmbient:
            return new GeneralAmbient()
        case ObjectInterface.IdMultiChannelSoundAmbient:
            return new SoundAmbient()
        case ObjectInterface.IdMonoChannelSoundAmbient:
            return new SoundAmbient()
        case ObjectInterface.IdSoundAmplifier:
            return new Amplifier()
        case ObjectInterface.IdPowerAmplifier:
            return new PowerAmplifier()
        case ObjectInterface.IdSoundAmplifierGeneral:
            return new AmplifierGeneral()
        case ObjectInterface.IdSplitBasicScenario:
            return new BasicSplit()
        case ObjectInterface.IdSplitAdvancedScenario:
            return new AdvancedSplit()
        case ObjectInterface.IdSimpleScenario:
            return new SimpleScenario()
        case ObjectInterface.IdScenarioModule:
            return new SimpleScenario()
        default:
            console.log("getComponent(): Unknown object id: " + objectId)
            return ""
        }
    }
}
