import QtQuick 1.1
import QtQuick 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
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
            hasChild: model.componentFile !== ""

            onClicked: {
                if (model.componentFile !== "")
                    element.loadElement(model.componentFile, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        ListElement {
            name: "Brightness/Contrast"
            componentFile: "Brightness.qml"
        }
        ListElement {
            name: "screensaver"
            componentFile: "ScreenSaverList.qml"
        }
        ListElement {
            name: "transition effects"
            componentFile: "TransitionEffects.qml"
        }
        ListElement {
            name: "calibration"
            componentFile: ""
        }
        ListElement {
            name: "clean"
            componentFile: ""
        }

    }
}
