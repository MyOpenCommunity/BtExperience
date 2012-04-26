import QtQuick 1.1
import QtQuick 1.0
import Components 1.0

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
            hasChild: model.componentFile !== ""

            onClicked: {
                if (model.name !== "")
                    column.loadColumn(model.comp, model.name)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Brightness"), "comp": brightness})
            modelList.append({"name": qsTr("Screensaver List"), "comp": screenSaverList})
            modelList.append({"name": qsTr("Transition effects"), "comp": transitionEffects})
            modelList.append({"name": qsTr("Calibration"), "comp": calibration})
            modelList.append({"name": qsTr("Clean"), "comp": clean})
        }
    }

    Component {
        id: brightness
        Brightness {}
    }

    Component {
        id: screenSaverList
        ScreenSaverList {}
    }

    Component {
        id: transitionEffects
        TransitionEffects {}
    }

    Component {
        id: calibration
        Item {}
    }

    Component {
        id: clean
        Item {}
    }
}
