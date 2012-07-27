import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    width: 212

    PaginatorList {
        id: paginator
        currentIndex: -1
        width: column.width
        listHeight: Math.max(1, 50 * objectModel.count)

        delegate: MenuItemDelegate {
            name: model.name
            selectOnClick: false
            onClicked: {
                if (model.action === 1)
                    privateProps.startProgramming()
                else
                    privateProps.deleteProgram()
            }
        }

        model: objectModel

        ListModel {
            id: objectModel
        }
    }

    Rectangle {
        id: clickBlocker
        color: "silver"
        anchors.fill: parent
        visible: column.dataModel.status !== ScenarioModule.Locked
        opacity: 0.5

        MouseArea {
            anchors.fill: parent
        }
    }

    QtObject {
        id: privateProps

        function startProgramming() {
            console.log("Start programming")
        }

        function deleteProgram() {
            console.log("Delete program")
        }
    }

    Component.onCompleted: {
        objectModel.append({"name": qsTr("start programming"), "action": 1})
        objectModel.append({"name": qsTr("delete program"), "action": 2})
    }
}
