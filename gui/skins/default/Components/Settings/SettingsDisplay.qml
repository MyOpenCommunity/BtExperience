import QtQuick 1.1
import Components 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    QtObject {
        id: privateProps

        function description(name) {
            if (name === qsTr("Brightness"))
                return global.screenState.normalBrightness + " %"

            return ""
        }
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            name: model.name
            hasChild: model.type === "column"
            description: privateProps.description(model.name)
            onDelegateTouched: {
                if (model.type === "column")
                    column.loadColumn(model.component, model.name)
                else {
                    resetSelection()
                    column.closeChild()
                    Stack.pushPage(model.component)
                }
            }
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Brightness"), "component": brightness, "type": "column"})
            modelList.append({"name": qsTr("Calibration"), "component": "Calibration.qml", "type": "page"})
            modelList.append({"name": qsTr("Clean"), "component": "Clean.qml", "type": "page"})
        }
    }

    Component {
        id: brightness
        Brightness {}
    }
}
