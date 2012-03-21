import QtQuick 1.1
import BtObjects 1.0

FilterListModel {
    function getComponentFile(objectId) {

        switch (objectId) {
        case ObjectInterface.IdLight:
            return "Actuator.qml"
        case ObjectInterface.IdDimmer:
            return "Dimmer.qml"
        case ObjectInterface.IdThermalControlUnit99:
            return "ThermalControlUnit.qml"
        case ObjectInterface.IdThermalControlledProbe:
            return "ThermalControlledProbe.qml"
        case ObjectInterface.IdHardwareSettings:
            return "Brightness.qml"
        case ObjectInterface.IdMultiChannelGeneralAmbient:
            return "GeneralAmbient.qml"
        case ObjectInterface.IdMultiChannelSoundAmbient:
            return "SoundAmbient.qml"
        case ObjectInterface.IdSoundAmplifier:
            return "Actuator.qml"
        case ObjectInterface.IdPowerAmplifier:
            return "Amplifier.qml"
        case ObjectInterface.IdSoundAmplifierGeneral:
            return "Actuator.qml"
        default:
            console.log("getComponentFile(): Unknown object id: " + objectId)
            return ""
        }
    }
}
