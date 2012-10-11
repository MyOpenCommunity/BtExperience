import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0

Column {
    id: table
    property date viewDate: new Date()
    property bool showCurrency: false

    spacing: 3

    EnergyFunctions {
        id: energyFunctions
    }

    QtObject {
        id: privateProps
        property int textMargin: 10
        property int cellWidth: 152
        property int cellHeight: 44
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
        model: energiesCounters.linesWithGoal()

        delegate: Loader {
            sourceComponent: tableRowComponent

            Component {
                id: tableRowComponent
                Row {
                    id: tableRow
                    property variant itemObject: energiesCounters.getObjectWithGoal(model.index)
                    property variant monthItem: itemObject.getValue(EnergyData.CumulativeMonthValue, new Date(), EnergyData.Consumption)

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
                            text: itemObject.name
                        }

                        SvgImage {
                            id: energyIcon
                            source: "../../images/energy/" + energyFunctions.getIcon(itemObject.energyType, false)
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: 10
                            }
                        }
                    }

                    SvgImage {
                        function calculateDelta() {
                            if (tableRow.monthItem.isValid)
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
                            text: energyFunctions.formatValue(tableRow.monthItem)
                            font.pixelSize: 14
                            color: "white"
                        }
                        UbuntuLightText {
                            anchors {
                                left: parent.left
                                leftMargin: privateProps.textMargin + tableHeader.spacing + privateProps.cellWidth
                                verticalCenter: parent.verticalCenter
                            }
                            text: tableRow.monthItem.consumptionGoal.toFixed(itemObject.decimals) + " " + tableRow.monthItem.measureUnit
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
                                var delta = parent.calculateDelta()
                                return (delta > 0 ? "+" : "-") + " " + Math.abs(delta).toFixed(itemObject.decimals) +  " " + tableRow.monthItem.measureUnit
                            }

                            font.pixelSize: 16
                            color: "white"
                        }
                    }
                }
            }
        }
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData}]

        function linesWithGoal() {
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

