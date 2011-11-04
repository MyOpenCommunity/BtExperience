import QtQuick 1.1

MenuElement {
    id: element
    height: 350
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }
    onChildAnimation: {
        itemList.transparent = running ? false : true
    }

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false
        property bool transparent: true

        delegate: MenuItemDelegate {
            showStatus: true
            onClicked: {
                var clickedItem = modelList.get(index)
                element.loadChild(clickedItem.name, clickedItem.componentFile)
            }
        }

        model: ListModel {
            id: modelList
            ListElement {
                name: "lampada scrivania"
                isOn: true
                componentFile: "Light.qml"
            }

            ListElement {
                name: "lampadario soggiorno"
                isOn: false
                componentFile: "Light.qml"
            }

            ListElement {
                name: "faretti soggiorno"
                isOn: false
                componentFile: "Dimmer.qml"
            }

            ListElement {
                name: "lampada da terra soggiorno"
                isOn: false
                componentFile: "Light.qml"
            }

            ListElement {
                name: "abat jour"
                isOn: true
                componentFile: "Light.qml"
            }

            ListElement {
                name: "abat jour"
                isOn: true
                componentFile: "Light.qml"
            }

            ListElement {
                name: "lampada studio"
                isOn: true
                componentFile: "Light.qml"
            }
        }
    }

}

