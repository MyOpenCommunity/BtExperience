import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    Image {
        id: background
        source: "../../images/common/bg_paginazione.png"
        width: parent.width
        height: parent.height
    }

    QtObject {
        id: privateProps
        function getMonthName(index) {
            switch (index) {
            case 0:
                return qsTr("January")
            case 1:
                return qsTr("February")
            case 2:
                return qsTr("March")
            case 3:
                return qsTr("April")
            case 4:
                return qsTr("May")
            case 5:
                return qsTr("June")
            case 6:
                return qsTr("July")
            case 7:
                return qsTr("August")
            case 8:
                return qsTr("September")
            case 9:
                return qsTr("October")
            case 10:
                return qsTr("November")
            case 11:
                return qsTr("December")
            }
        }
        property int currentIndex: -1
    }

    Column {
        ControlSwitch {
            text: qsTr("goals enabled")
            status: dataModel.goalsEnabled === true ? 0 : 1
            onPressed: dataModel.goalsEnabled = !dataModel.goalsEnabled
        }

        Component {
            id: panelComponent
            SettingsEnergyGoalPanel {
            }
        }

        PaginatorColumn {
            maxHeight: 300
            onCurrentPageChanged: column.closeChild()
            Repeater {
                MenuItem {
                    name: privateProps.getMonthName(index)
                    description: dataModel.goals[index].toFixed(dataModel.decimals) + " " + dataModel.cumulativeUnit
                    hasChild: true
                    isSelected: privateProps.currentIndex === index
                    onTouched: {
                        privateProps.currentIndex = index
                        column.loadColumn(panelComponent, privateProps.getMonthName(index), dataModel, {monthIndex: index})
                    }
                }
                model: 12
            }
        }
    }
}

