import QtQuick 1.1

MenuElement {
    id: element
    height: 350
    width: 192

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1


        delegate: Item {
            id: itemDelegate
            height: 50
            width: background.sourceSize.width

            Image {
                anchors.fill: parent
                z: 0
                id: background
                source: "common/tasto_menu.png";
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
                    font.pixelSize: 13
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

