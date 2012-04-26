import QtQuick 1.1
import BtObjects 1.0
import Components.ThermalRegulation 1.0

FilterListModel {

    function getComponent(objectId) {
        switch (objectId) {
        case ObjectInterface.IdLight:
            return Qt.createComponent("Lighting/Light.qml")
        case ObjectInterface.IdDimmer:
            return Qt.createComponent("Lighting/Dimmer.qml")
        case ObjectInterface.IdThermalControlUnit99:
            return Qt.createComponent("ThermalRegulation/ThermalControlUnit.qml")
        case ObjectInterface.IdThermalControlledProbe:
            return Qt.createComponent("ThermalRegulation/ThermalControlledProbe.qml")
        case ObjectInterface.IdHardwareSettings:
            return Qt.createComponent("Brightness.qml")
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
