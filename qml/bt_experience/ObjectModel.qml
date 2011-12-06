import QtQuick 1.1
import BtObjects 1.0

CustomListModel {
    function getComponentFile(objectId) {

        switch (objectId) {
        case ObjectInterface.IdLight:
            return "Light.qml"
        case ObjectInterface.IdDimmer:
            return "Dimmer.qml"
        case ObjectInterface.IdThermalControlUnit99:
            return "ThermalCentralUnit.qml"
        case ObjectInterface.IdThermalControlledProbe:
            return "ThermalControlledProbe.qml"
        case ObjectInterface.IdThermalControlUnitOff:
            return null
        case ObjectInterface.IdThermalControlUnitAntifreeze:
            return null
        case ObjectInterface.IdThermalControlUnitHoliday:
            return "ThermalCentralUnitHolidays.qml"
        default:
            console.log("Unknown object id: " + objectId)
            return ""
        }
    }
}
