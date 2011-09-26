import QtQuick 1.1

MenuElement {
    id: element
    height: 455
    width: 245

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


        delegate: Item {
            id: itemDelegate
            height: 65
            width: 245

            Image {
                anchors.fill: parent
                z: 0
                id: background
                source: "common/tasto_menu.png";
            }

            Rectangle {
                id: bgRectangle
                visible: itemList.transparent === false ? true : false
                color: "white"
                anchors.fill: parent
                z: -1
            }

            Item {
                anchors.fill: parent
                z: 1

                Image {
                    id: icon_status
                    source: isOn === true ? "common/on.png" :"common/off.png";
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                }

                Text {
                    id: text
                    text: name
                    font.family: semiBoldFont.name
                    font.pixelSize: 15
                    wrapMode: "WordWrap"
                    anchors.left: icon_status.right
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    anchors.right: arrow_right.left
                }

                Image {
                    id: arrow_right
                    source: "common/freccia_dx.png"
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    itemList.currentIndex = index
                    element.loadChild(name, componentFile)
                }
            }

            states: State {
                name: "selected"
                when: itemDelegate.ListView.isCurrentItem
                PropertyChanges { target: text; color: "#ffffff" }
                PropertyChanges { target: arrow_right; source: "common/freccia_dxS.png" }
                PropertyChanges { target: background; source: "common/tasto_menuS.png" }
            }
        }

        model: ListModel {
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

