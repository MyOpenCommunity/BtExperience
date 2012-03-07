import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: system
    width: 212
    height: itemList.height

    ListModel {
        id: objectModelTemp
        ListElement {
            name: "Generale"
            status: -1
        }
        ListElement {
            name: "camera"
            status: 1
        }

        ListElement {
            name: "bagno"
            status: 0
        }

        ListElement {
            name: "soggiorno"
            status: 0
        }
    }


    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList
        height: 50 * count
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: objectModelTemp.get(index)

            active: system.animationRunning === false
            status: itemObject.status
            hasChild: true
            onClicked: {
                console.log("delegate clicked " + index)
                system.loadElement("SoundAmbient.qml", itemObject.name,
                                    objectModelTemp.get(model.index))
            }
        }

        model: objectModelTemp
    }
}
