import QtQuick 1.1
import BtObjects 1.0

FilterListModel {
    function getComponentFile(objectId) {

        switch (objectId) {
        case ObjectInterface.IdLight:
            return "Light.qml"
        case ObjectInterface.IdDimmer:
            return "Dimmer.qml"
        case ObjectInterface.IdThermalControlUnit99:
            return "ThermalControlUnit.qml"
        case ObjectInterface.IdThermalControlledProbe:
            return "ThermalControlledProbe.qml"
        default:
            console.log("Unknown object id: " + objectId)
            return ""
        }
    }
}
