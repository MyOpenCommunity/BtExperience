import QtQuick 1.1
import BtObjects 1.0


FilterListModel {
    function getComponent(objectId) {

        switch (objectId) {
        case ObjectInterface.IdLight:
            return Qt.createComponent("Components/Lighting/Light.qml")
        case ObjectInterface.IdDimmer:
            return Qt.createComponent("Components/Lighting/Dimmer.qml")
        case ObjectInterface.IdThermalControlUnit99:
            return Qt.createComponent("Components/ThermalRegulation/ThermalControlUnit.qml")
        case ObjectInterface.IdThermalControlledProbe:
            return Qt.createComponent("Components/ThermalRegulation/ThermalControlledProbe.qml")
        case ObjectInterface.IdHardwareSettings:
            return Qt.createComponent("Brightness.qml")
        case ObjectInterface.IdMultiChannelGeneralAmbient:
            return Qt.createComponent("Components/SoundDiffusion/GeneralAmbient.qml")
        case ObjectInterface.IdMultiChannelSoundAmbient:
            return Qt.createComponent("Components/SoundDiffusion/SoundAmbient.qml")
        case ObjectInterface.IdMonoChannelSoundAmbient:
            return Qt.createComponent("Components/SoundDiffusion/SoundAmbient.qml")
        case ObjectInterface.IdSoundAmplifier:
            return Qt.createComponent("Components/SoundDiffusion/Amplifier.qml")
        case ObjectInterface.IdPowerAmplifier:
            return Qt.createComponent("Components/SoundDiffusion/PowerAmplifier.qml")
        case ObjectInterface.IdSoundAmplifierGeneral:
            return Qt.createComponent("Components/SoundDiffusion/AmplifierGeneral.qml")
        case ObjectInterface.IdSplitBasicScenario:
            return Qt.createComponent("Components/ThermalRegulation/BasicSplit.qml")
        case ObjectInterface.IdSplitAdvancedScenario:
            return Qt.createComponent("Components/ThermalRegulation/AdvancedSplit.qml")
        case ObjectInterface.IdSimpleScenario:
            return Qt.createComponent("Components/Scenarios/SimpleScenario.qml")
        case ObjectInterface.IdScenarioModule:
            return Qt.createComponent("Components/Scenarios/SimpleScenario.qml")
        default:
            console.log("getComponent(): Unknown object id: " + objectId)
            return ""
        }
    }
}
