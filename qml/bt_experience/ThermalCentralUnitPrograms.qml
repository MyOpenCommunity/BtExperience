import QtQuick 1.1


MenuElement {
    id: element
    height: 455
    width: 245

    signal programSelected(string programName)

    onChildLoaded: {
        if (child.programSelected)
            child.programSelected.connect(childProgramSelected)
    }

    function childProgramSelected(programName) {
        element.programSelected(itemList.currentItem.text + " " + programName)
    }

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
            property alias text: text.text

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
                    anchors.right: arrow_right.left
                }

                Image {
                    id: arrow_right
                    opacity: componentFile ? 1 : 0
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
                    if (componentFile)
                        element.loadChild(name, componentFile)
                    else {
                        element.closeChild()
                        element.programSelected(name)
                    }
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
                name: "settimanale"
                componentFile: "ThermalCentralUnitWeekly.qml"
            }

            ListElement {
                name: "festivi"
                componentFile: "ThermalCentralUnitHolidays.qml"
            }

            ListElement {
                name: "vacanze"
                componentFile: "ThermalCentralUnitVacations.qml"
            }

            ListElement {
                name: "scenari"
                componentFile: "ThermalCentralUnitScenari.qml"
            }

            ListElement {
                name: "antigelo"
                componentFile: ""
            }

            ListElement {
                name: "manuale"
                componentFile: ""
            }

            ListElement {
                name: "off"
                componentFile: ""
            }

        }

    }
}
