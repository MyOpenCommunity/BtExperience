import QtQuick 1.1
import bticino 1.0

CustomListModel {
    function getComponentFile(objectId) {
        switch (objectId) {
        case ObjectInterface.Light:
            return "Light.qml"
        case ObjectInterface.Dimmer:
            return "Dimmer.qml"
        default:
            console.log("Unknown object id: " + objectId)
            return ""
        }
    }

    Component.onCompleted: setSource(mainModel)
}
