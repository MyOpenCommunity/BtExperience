import QtQuick 1.0


MenuElement {
    id: element
    height: 300
    width: 192

    signal programSelected(string programName)

    ListView {
        id: itemList
        y: 0
        x: 0
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: Item {
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

                Text {
                    id: text
                    text: name
                    font.family: semiBoldFont.name
                    font.pixelSize: 13
                    wrapMode: "WordWrap"
                    anchors.left: parent.left
                    anchors.leftMargin: 10
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
                    element.programSelected(name)
                }
            }

            states: State {
                name: "selected"
                when: ListView.isCurrentItem
            }
        }

        model: ListModel {
            ListElement {
                name: "settimanale"
            }

            ListElement {
                name: "festivi"
            }

            ListElement {
                name: "vacanze"
            }

            ListElement {
                name: "scenari"
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
