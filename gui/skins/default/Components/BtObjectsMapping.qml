import QtQuick 1.1
import BtObjects 1.0


/**
  * It was not possible to use Components.
  * In case of circular imports, the createObject function hangs forever.
  * Reverting to file names (at least for now).
  * Another possibility is to use new <<Component>>() in Javascript code, but
  * it is not clear if it is a bug or a feature, so we leave apart at the moment.
  */
QtObject {
    function getComponent(objectId) {
        switch (objectId) {
        case ObjectInterface.IdLight:
            return Qt.createComponent("Lighting/Light.qml")
        case ObjectInterface.IdDimmer:
            return Qt.createComponent("Lighting/Dimmer.qml")
        case ObjectInterface.IdDimmer100:
            return Qt.createComponent("Lighting/Dimmer.qml")
        case ObjectInterface.IdLightGroup:
        case ObjectInterface.IdDimmerGroup:
        case ObjectInterface.IdDimmer100Group:
            return Qt.createComponent("Lighting/LightGroup.qml")
        case ObjectInterface.IdThermalControlUnit4:
            return Qt.createComponent("ThermalRegulation/ThermalControlUnit.qml")
        case ObjectInterface.IdThermalControlUnit99:
            return Qt.createComponent("ThermalRegulation/ThermalControlUnit.qml")
        case ObjectInterface.IdThermalControlledProbe:
            return Qt.createComponent("ThermalRegulation/ThermalControlledProbe.qml")
        case ObjectInterface.IdThermalControlledProbeFancoil:
            return Qt.createComponent("ThermalRegulation/ThermalControlledProbe.qml")
        case ObjectInterface.IdHardwareSettings:
            return Qt.createComponent("Settings/Brightness.qml")
        case ObjectInterface.IdMultiChannelGeneralAmbient:
            return Qt.createComponent("SoundDiffusion/GeneralAmbient.qml")
        case ObjectInterface.IdMultiChannelSoundAmbient:
            return Qt.createComponent("SoundDiffusion/SoundAmbient.qml")
        case ObjectInterface.IdMonoChannelSoundAmbient:
            return Qt.createComponent("SoundDiffusion/SoundAmbient.qml")
        case ObjectInterface.IdSoundAmplifier:
            return Qt.createComponent("SoundDiffusion/Amplifier.qml")
        case ObjectInterface.IdPowerAmplifier:
            return Qt.createComponent("SoundDiffusion/PowerAmplifier.qml")
        case ObjectInterface.IdSoundAmplifierGeneral:
            return Qt.createComponent("SoundDiffusion/AmplifierGeneral.qml")
        case ObjectInterface.IdSplitBasicScenario:
            return Qt.createComponent("ThermalRegulation/BasicSplit.qml")
        case ObjectInterface.IdSplitAdvancedScenario:
            return Qt.createComponent("ThermalRegulation/AdvancedSplit.qml")
        case ObjectInterface.IdSimpleScenario:
            return Qt.createComponent("Scenarios/SimpleScenario.qml")
        case ObjectInterface.IdScenarioModule:
            return Qt.createComponent("Scenarios/SimpleScenario.qml")
        default:
            console.log("getComponent(): Unknown object id: " + objectId)
            return ""
        }
    }
}
