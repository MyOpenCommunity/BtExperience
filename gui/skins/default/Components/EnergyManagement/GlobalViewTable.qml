import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0

import "../../js/Stack.js" as Stack
import "../../js/datetime.js" as DateTime

Column {
    id: table
    property date viewDate: new Date()
    property bool showCurrency

    function scrollLeft() {
        if (privateProps.currentPage > 0)
            privateProps.currentPage -= 1
        else
            viewDate = DateTime.previousMonth(viewDate)
    }

    function scrollRight() {
        if (energiesCounters.linesWithGoal > (privateProps.currentPage + 1) * privateProps.maxRows)
            privateProps.currentPage += 1
        else {
            var currentDate = new Date()
            if (viewDate.getFullYear() < currentDate.getFullYear() ||
                viewDate.getFullYear() == currentDate.getFullYear() && viewDate.getMonth() < currentDate.getMonth()) {
                viewDate = DateTime.nextMonth(viewDate)
                privateProps.currentPage = 0
            }
        }
    }

    spacing: 3

    EnergyFunctions {
        id: energyFunctions
    }

    QtObject {
        id: privateProps
        property int textMargin: 10
        property int cellWidth: 152
        property int cellHeight: 44
        property int maxRows: 6
        property int currentPage: 0
    }

    Row {
        id: tableHeader
        spacing: 3
        Rectangle {
            width: 191
            height: privateProps.cellHeight
            color: "#e6e6e6"
            UbuntuLightText {
                anchors {
                    left: parent.left
                    leftMargin: privateProps.textMargin
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 14
                text: qsTr("line")
            }
        }
        Rectangle {
            width: privateProps.cellWidth
            height: privateProps.cellHeight
            color: "#e6e6e6"
            UbuntuLightText {
                anchors {
                    left: parent.left
                    leftMargin: privateProps.textMargin
                    verticalCenter: parent.verticalCenter
                    rightMargin: privateProps.textMargin
                    right:parent.right
                }
                font.pixelSize: 14
                text: qsTr("consumption") + " " + Qt.formatDateTime(table.viewDate, "MM/yyyy")
                wrapMode: Text.WordWrap
            }
        }
        Rectangle {
            width: privateProps.cellWidth
            height: privateProps.cellHeight
            color: "#e6e6e6"
            UbuntuLightText {
                anchors {
                    left: parent.left
                    leftMargin: privateProps.textMargin
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 14
                text: qsTr("objective")
            }
        }
        Rectangle {
            width: privateProps.cellWidth
            height: privateProps.cellHeight
            color: "#e6e6e6"
            UbuntuLightText {
                anchors {
                    left: parent.left
                    leftMargin: privateProps.textMargin
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 14
                text: qsTr("delta")
            }
        }
    }


    Repeater {
        model: Math.min(privateProps.maxRows, energiesCounters.linesWithGoal - privateProps.currentPage * privateProps.maxRows)

        delegate: Item {
                    width: tableRow.width
                    height: tableRow.height

                    Row {
                        id: tableRow
                        property variant itemObject: energiesCounters.getObjectWithGoal(model.index + privateProps.currentPage * privateProps.maxRows)
                        property variant monthItem: itemObject.getValue(EnergyData.CumulativeMonthValue, table.viewDate,
                                                                        showCurrency ? EnergyData.Currency : EnergyData.Consumption)

                        function hasRate() {
                            if (monthItem !== undefined && monthItem.rate !== null)
                                return true
                            return false
                        }

                        height: privateProps.cellHeight
                        spacing: 3
                        SvgImage {
                            id: btnLine
                            source: "../../images/energy/btn_line_table.svg"
                            UbuntuLightText {
                                anchors {
                                    left: parent.left
                                    leftMargin: privateProps.textMargin
                                    verticalCenter: parent.verticalCenter
                                }
                                text: tableRow.itemObject.name
                            }

                            SvgImage {
                                id: energyIcon
                                source: "../../images/energy/" + energyFunctions.getIcon(tableRow.itemObject.energyType, false)
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                    rightMargin: 10
                                }
                            }
                        }

                        SvgImage {
                            id: line
                            function calculateDelta() {
                                if (tableRow.monthItem!== undefined && tableRow.monthItem.isValid)
                                    return tableRow.monthItem.value - tableRow.monthItem.consumptionGoal

                                return 0
                            }

                            source: {
                                if (calculateDelta() > 0)
                                    return "../../images/energy/btn_row_table_red.svg"
                                return "../../images/energy/btn_row_table_green.svg"
                            }
                            width: tableHeader.width - btnLine.width - spacing
                            UbuntuLightText {
                                anchors {
                                    left: parent.left
                                    leftMargin: privateProps.textMargin
                                    verticalCenter: parent.verticalCenter
                                }
                                text: tableRow.hasRate() ? energyFunctions.formatValue(tableRow.monthItem) : qsTr("---")
                                font.pixelSize: 14
                                color: "white"
                            }
                            UbuntuLightText {
                                anchors {
                                    left: parent.left
                                    leftMargin: privateProps.textMargin + tableHeader.spacing + privateProps.cellWidth
                                    verticalCenter: parent.verticalCenter
                                }
                                text: tableRow.hasRate() ? tableRow.monthItem.consumptionGoal.toFixed(tableRow.itemObject.decimals) + " " + tableRow.monthItem.measureUnit : qsTr("---")
                                font.pixelSize: 14
                                color: "white"
                            }

                            UbuntuMediumText {
                                anchors {
                                    left: parent.left
                                    leftMargin: privateProps.textMargin + (tableHeader.spacing + privateProps.cellWidth) * 2
                                    verticalCenter: parent.verticalCenter
                                }
                                text: {
                                    if (!tableRow.hasRate())
                                        return qsTr("---")
                                    var delta = parent.calculateDelta()
                                    return (delta > 0 ? "+" : "-") + " " + Math.abs(delta).toFixed(tableRow.itemObject.decimals) +  " " + tableRow.monthItem.measureUnit
                                }

                                font.pixelSize: 16
                                color: "white"
                            }
                        }
                        states: State {
                            name: "pressed"
                            PropertyChanges {
                                target: btnLine
                                source: "../../images/energy/btn_line_table_p.svg"
                            }
                            PropertyChanges {
                                target: line
                                source: "../../images/energy/btn_row_table_p.svg"
                            }
                            PropertyChanges {
                                target: energyIcon
                                source: "../../images/energy/" + energyFunctions.getIcon(tableRow.itemObject.energyType, true)
                            }
                        }
                    }

                    BeepingMouseArea {
                        anchors.fill: parent
                        onPressed: tableRow.state = "pressed"
                        onReleased: tableRow.state = ""
                        onClicked: Stack.pushPage("EnergyDataGraph.qml", {"energyData": tableRow.itemObject})
                    }
                }

    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData}]
        property int linesWithGoal: calculateLines()

        function calculateLines() {
            var lines = 0
            for (var i = 0; i < energiesCounters.count; i += 1) {
                var energyData = energiesCounters.getObject(i)
                if (!energyData.goalsEnabled)
                    continue

                for (var j = 0; j < energyData.goals.length; j += 1)
                    if (energyData.goals[j] > 0) {
                        lines += 1
                        break
                    }
            }
            return lines
        }

        function getObjectWithGoal(index) {
            var lines = 0
            for (var i = 0; i < energiesCounters.count; i += 1) {
                var energyData = energiesCounters.getObject(i)
                if (!energyData.goalsEnabled)
                    continue

                for (var j = 0; j < energyData.goals.length; j += 1)
                    if (energyData.goals[j] > 0) {
                        lines += 1
                        break
                    }

                if (lines === index + 1)
                    return energyData
            }
            return null
        }
    }
}

