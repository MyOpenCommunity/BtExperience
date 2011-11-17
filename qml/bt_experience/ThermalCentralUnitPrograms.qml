import QtQuick 1.1


MenuElement {
    id: element
    height: 350
    width: 212

    signal programSelected(string programName)

    onChildLoaded: {
        if (child.programSelected)
            child.programSelected.connect(childProgramSelected)
    }

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    function childProgramSelected(programName) {
        element.programSelected(modelList.get(itemList.currentIndex).name + " " + programName)
    }

    ListView {
        id: itemList
        y: 0
        x: 0
        anchors.fill: parent
        currentIndex: -1
        interactive: false


        delegate: MenuItemDelegate {
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                if (clickedItem.componentFile)
                    element.loadElement(clickedItem.componentFile, clickedItem.name)
                else {
                    element.closeChild()
                    element.programSelected(clickedItem.name)
                }
            }
        }

        model: ListModel {
            id: modelList
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
