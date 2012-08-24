import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log


MenuColumn {
    id: column

    Component {
        id: programListSplit
        ProgramListSplit {}
    }

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
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(
                            programListSplit,
                            name,
                            dataModel)
            }
        }

        ButtonOkCancel {
            onCancelClicked: column.closeColumn()
            onOkClicked: {
                dataModel.apply()
                column.closeColumn()
            }
        }
    }
}
