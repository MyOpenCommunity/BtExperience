import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: element
    width: 212
    height: paginator.height

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Component.onCompleted: options.setComponent(off)

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 500

        MenuItem {
            id: programItem
            name: qsTr("program")
            description: dataModel.program
            hasChild: true
            state: privateProps.currentIndex === 1 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                element.loadElement(
                            "Components/ThermalRegulation/ProgramListSplit.qml",
                            name,
                            dataModel)
            }
        }

        AnimatedLoader {
            id: options
        }
    }

    Component {
        id: off
        ButtonOkCancel {
            onCancelClicked: element.closeElement()
            onOkClicked: {
                dataModel.ok()
                element.closeElement()
            }
        }
    }
}
