import QtQuick 1.1
import QtQuick 1.0
import Components 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            name: model.name
            hasChild: model.component !== undefined
                      && model.component !== null

            onClicked: {
                if (model.name !== "") {
                    if (model.type === "column")
                        column.loadColumn(model.component, model.name)
                    else
                        Stack.pushPage("Calibration.qml")
                }
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Brightness"), "component": brightness, "type": "column"})
//            modelList.append({"name": qsTr("Transition effects"), "component": transitionEffects})
            modelList.append({"name": qsTr("Calibration"), "component": undefined, "type": "page"})
            modelList.append({"name": qsTr("Clean"), "component": clean, "type": "column"})
        }
    }

    Component {
        id: brightness
        Brightness {}
    }

//    Component {
//        id: transitionEffects
//        TransitionEffects {}
//    }

    Component {
        id: clean
        Item {}
    }
}
