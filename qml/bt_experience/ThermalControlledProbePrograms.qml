import QtQuick 1.1

MenuElement {
    id: element
    height: 260
    width: 245

    signal programSelected(string programName)

    ListView {
        id: itemList
        y: 0
        x: 0
        anchors.fill: parent
        currentIndex: -1
        interactive: false

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

            Item {
                anchors.fill: parent
                z: 1

                Text {
                    id: text
                    text: name
                    font.family: semiBoldFont.name
                    font.pixelSize: 15
                    wrapMode: "WordWrap"
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    anchors.right: parent.right
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    itemList.currentIndex = index
                    element.programSelected(name)
                }
            }

            states: State {
                name: "selected"
                when: itemDelegate.ListView.isCurrentItem
                PropertyChanges { target: text; color: "#ffffff" }
                PropertyChanges { target: background; source: "common/tasto_menuS.png" }
            }
        }

        model: ListModel {
            ListElement {
                name: "auto"
            }

            ListElement {
                name: "antigelo"
            }

            ListElement {
                name: "manuale"
            }

            ListElement {
                name: "off"
            }

        }

    }
}


