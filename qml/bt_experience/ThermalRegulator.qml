import QtQuick 1.0


ListView {
    id: itemList
    y: 0
    x: 0
    height: 350
    width: 192
    currentIndex: -1
    signal loadComponent(string fileName)

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
                itemList.loadComponent(componentFile)
            }
        }

        states: State {
            name: "selected"
            when: ListView.isCurrentItem
            PropertyChanges { target: text; color: "#ffffff" }
            PropertyChanges { target: arrow_right; source: "common/freccia_dxS.png" }
            PropertyChanges { target: background; source: "common/tasto_menuS.png" }
        }
    }

    model: ListModel {
        ListElement {
            name: "unità centrale"
            componentFile: "ThermalCentralUnit.qml"
        }

        ListElement {
            name: "zona giorno"
            componentFile: "ThermalControlledProbe.qml"
        }

        ListElement {
            name: "zona notte"
            componentFile: "ThermalControlledProbe.qml"
        }

        ListElement {
            name: "zona taverna"
            componentFile: "ThermalControlledProbe.qml"
        }

        ListElement {
            name: "zona studio"
            componentFile: "5.qml"
        }
    }
}
