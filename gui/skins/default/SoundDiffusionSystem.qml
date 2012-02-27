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
            status: false
        }
        ListElement {
            name: "camera"
            status: true
        }

        ListElement {
            name: "bagno"
            status: false
        }

        ListElement {
            name: "soggiorno"
            status: false
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
            status: itemObject.status === true ? 1 : 0
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
