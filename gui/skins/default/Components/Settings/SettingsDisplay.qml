import QtQuick 1.1
import QtQuick 1.0
import Components 1.0

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
                if (model.name !== "")
                    column.loadColumn(model.component, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Brightness"), "component": brightness})
//            modelList.append({"name": qsTr("Transition effects"), "component": transitionEffects})
            modelList.append({"name": qsTr("Calibration"), "component": calibration})
            modelList.append({"name": qsTr("Clean"), "component": clean})
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
        id: calibration
        Item {}
    }

    Component {
        id: clean
        Item {}
    }
}
