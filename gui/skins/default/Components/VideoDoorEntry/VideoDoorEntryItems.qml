import QtQuick 1.1
import Components 1.0
import "../../js/logging.js" as Log


MenuColumn {
    id: column
    height: Math.max(1, 50 * itemList.count)
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                column.loadColumn(clickedItem.component, clickedItem.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("CCTV"), "component": cctv})
            modelList.append({"name": qsTr("intercom"), "component": intercom})
            modelList.append({"name": qsTr("pager"), "component": pager})
        }
    }

    Component {
        id: cctv
        CCTV {}
    }

    Component {
        id: intercom
        InterCom {}
    }

    Component {
        id: pager
        Pager {}
    }
}
