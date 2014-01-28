/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
    property bool lastItemReached: !energyFunctions.isEnergyMonthValid(DateTime.nextMonth(viewDate)) &&
                                   (energiesCounters.linesWithGoal < (privateProps.currentPage + 1) * privateProps.maxRows)
    property bool firstItemReached: !energyFunctions.isEnergyMonthValid(DateTime.previousMonth(viewDate)) &&
                                    privateProps.currentPage === 0

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
                    right: parent.right
                    rightMargin: privateProps.textMargin
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 14
                text: qsTr("line")
                horizontalAlignment: Text.AlignHCenter
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
                    right: parent.right
                    rightMargin: privateProps.textMargin
                }
                font.pixelSize: 14
                text: qsTr("consumption") + " " + Qt.formatDateTime(table.viewDate, "MM/yyyy")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
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
                    right: parent.right
                    rightMargin: privateProps.textMargin
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 14
                text: qsTr("Goal")
                horizontalAlignment: Text.AlignHCenter
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
                    right: parent.right
                    rightMargin: privateProps.textMargin
                    verticalCenter: parent.verticalCenter
                }
                font.pixelSize: 14
                text: qsTr("delta")
                horizontalAlignment: Text.AlignHCenter
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
                        property variant monthItem: monthItemValue.item

                        EnergyItemObject {
                            id: monthItemValue
                            energyData: tableRow.itemObject
                            valueType: EnergyData.CumulativeMonthValue
                            date: table.viewDate
                            measureType: showCurrency ? EnergyData.Currency : EnergyData.Consumption
                        }

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
                            Item {
                                id: consumptionValueText
                                width: tableHeader.spacing + privateProps.cellWidth - spacing / 3
                                height: parent.height
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }
                                UbuntuLightText {
                                    anchors {
                                        fill: parent
                                        rightMargin: privateProps.textMargin
                                    }
                                    text: tableRow.hasRate() ?
                                              monthItemValue.measureType === EnergyData.Currency ?
                                                  energyFunctions.formatCurrency(tableRow.monthItem) :
                                                  energyFunctions.formatValue(tableRow.monthItem)
                                          : "---"
                                    font.pixelSize: 14
                                    color: "white"
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Item {
                                id: goalValueText
                                width: tableHeader.spacing + privateProps.cellWidth - spacing / 3
                                height: parent.height
                                anchors {
                                    left: consumptionValueText.right
                                    verticalCenter: parent.verticalCenter
                                }
                                UbuntuLightText {
                                    anchors {
                                        fill: parent
                                        rightMargin: privateProps.textMargin
                                    }
                                    text: tableRow.hasRate() ? tableRow.monthItem.consumptionGoal.toFixed(tableRow.itemObject.decimals) + " " + tableRow.monthItem.measureUnit : "---"
                                    font.pixelSize: 14
                                    color: "white"
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Item {
                                width: tableHeader.spacing + privateProps.cellWidth - spacing / 3
                                height: parent.height
                                anchors {
                                    left: goalValueText.right
                                    verticalCenter: parent.verticalCenter
                                }
                                UbuntuMediumText {
                                    anchors {
                                        fill: parent
                                        rightMargin: privateProps.textMargin
                                    }
                                    text: {
                                        if (!tableRow.hasRate())
                                            return "---"
                                        var delta = line.calculateDelta()
                                        return (delta > 0 ? "+" : "-") + " " + Math.abs(delta).toFixed(tableRow.itemObject.decimals) +  " " + tableRow.monthItem.measureUnit
                                    }
                                    font.pixelSize: 16
                                    color: "white"
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                }
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

