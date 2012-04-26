import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: element
    width: 212
    height: column.height

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: column
        ControlUpDownReset {
            title: qsTr("automatic reset")
            text: qsTr("disabled")
        }

        MenuItem {
            name: qsTr("self test")
            description: "enabled - 30 days"
            hasChild: true
            state: privateProps.currentIndex === 1 ? "selected" : ""
            onClicked: {
                privateProps.currentIndex = 1
                element.loadElement("Components/EnergyManagement/SelfTest.qml")
            }
        }

        ButtonOkCancel {

        }
    }
}
