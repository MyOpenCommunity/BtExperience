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
                    element.loadChild(clickedItem.name, clickedItem.componentFile)
                else {
                    element.closeChild()
                    element.programSelected(clickedItem.name)
                }
            }

            onPressed: {
                itemHighlighed.sourceComponent = menuItemComponent
                itemHighlighed.item.state = "selected"
                itemHighlighed.item.name = itemPressed.name
                itemHighlighed.item.hasChild = itemPressed.hasChild
                itemHighlighed.item.status = itemPressed.status
                itemHighlighed.item.x = itemPressed.x + element.x - 5
                itemHighlighed.item.y = itemPressed.y + element.y - 2
            }

            onReleased: {
                itemHighlighed.sourceComponent = undefined
            }

            Component {
                id: menuItemComponent
                MenuItem {
                    width: 222
                    height: 55
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
