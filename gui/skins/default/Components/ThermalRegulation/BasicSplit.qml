import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter

        MenuItem {
            id: programItem
            name: qsTr("program")
            description: dataModel.program
            hasChild: true
            state: privateProps.currentIndex === 1 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadElement(
                            "Components/ThermalRegulation/ProgramListSplit.qml",
                            name,
                            dataModel)
            }
        }

        ButtonOkCancel {
            onCancelClicked: column.closeElement()
            onOkClicked: {
                dataModel.ok()
                column.closeElement()
            }
        }
    }
}
