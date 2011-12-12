import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    signal programSelected(string programName)

    onChildLoaded: {
        if (child.programSelected)
            child.programSelected.connect(childProgramSelected)
    }

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    function childProgramSelected(programName) {
        var model = itemList.model.getObject(itemList.currentIndex);

        element.programSelected(model.name + " " + programName)
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false
        property bool transparent: true

        delegate: MenuItemDelegate {
            hasChild: itemList.getComponentFile(model.objectId) !== null
            onClicked: {
                var component = itemList.getComponentFile(model.objectId)
                var obj = itemList.model.getObject(model.index)

                if (component !== null)
                    element.loadElement(component, model.name, obj)
                else {
                    element.closeChild()
                    element.programSelected(obj.name)
                    obj.apply()
                }
            }
        }

        model: element.dataModel.modalities

        function getComponentFile(objectId) {
            switch (objectId) {
            case ThermalControlUnit99Zones.IdOff:
                return null
            case ThermalControlUnit99Zones.IdAntifreeze:
                return null
            case ThermalControlUnit99Zones.IdHoliday:
            case ThermalControlUnit99Zones.IdVacation:
                return "ThermalCentralUnitHolidays.qml"
            case ThermalControlUnit99Zones.IdWeeklyPrograms:
                return "ThermalCentralUnitWeekly.qml"
            case ThermalControlUnit99Zones.IdScenarios:
                return "ThermalCentralUnitScenarios.qml"
            default:
                console.log("Unknown thermal central unit subobject id: " + objectId)
                return ""
            }
        }
    }
}
