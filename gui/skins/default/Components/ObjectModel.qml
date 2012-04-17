import QtQuick 1.1
import BtObjects 1.0

FilterListModel {
    function getComponentFile(objectId) {

        switch (objectId) {
        case ObjectInterface.IdLight:
            return "Components/Lighting/Light.qml"
        case ObjectInterface.IdDimmer:
            return "Components/Lighting/Dimmer.qml"
        case ObjectInterface.IdThermalControlUnit99:
            return "Components/ThermalRegulation/ThermalControlUnit.qml"
        case ObjectInterface.IdThermalControlledProbe:
            return "Components/ThermalRegulation/ThermalControlledProbe.qml"
        case ObjectInterface.IdHardwareSettings:
            return "Brightness.qml"
        case ObjectInterface.IdMultiChannelGeneralAmbient:
            return "Components/SoundDiffusion/GeneralAmbient.qml"
        case ObjectInterface.IdMultiChannelSoundAmbient:
            return "Components/SoundDiffusion/SoundAmbient.qml"
        case ObjectInterface.IdMonoChannelSoundAmbient:
            return "Components/SoundDiffusion/SoundAmbient.qml"
        case ObjectInterface.IdSoundAmplifier:
            return "Components/SoundDiffusion/Amplifier.qml"
        case ObjectInterface.IdPowerAmplifier:
            return "Components/SoundDiffusion/PowerAmplifier.qml"
        case ObjectInterface.IdSoundAmplifierGeneral:
            return "Components/SoundDiffusion/AmplifierGeneral.qml"
        case ObjectInterface.IdSplitBasicScenario:
            return "Components/ThermalRegulation/BasicSplit.qml"
        case ObjectInterface.IdSplitAdvancedScenario:
            return "Components/ThermalRegulation/AdvancedSplit.qml"
        case ObjectInterface.IdSimpleScenario:
            return "Components/Scenarios/SimpleScenario.qml"
        case ObjectInterface.IdScenarioModule:
            return "Components/Scenarios/SimpleScenario.qml"
        default:
            console.log("getComponentFile(): Unknown object id: " + objectId)
            return ""
        }
    }
}
