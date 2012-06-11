import QtQuick 1.1
import BtObjects 1.0

import "../../js/RowColumnHelpers.js" as Helper


Item {
    id: bg
    width: 200

    property variant avgValue
    property variant cumValue
    property int graphType
    property variant value
    property date timepoint

    signal timepointChanged(variant dt)

    Rectangle {
        color: "gray"
        anchors.fill: parent
        radius: 4
        opacity: 0.5
    }

    Column {
        id: sidebar
        spacing: 20
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }

        onChildrenChanged: Helper.updateColumnChildren(sidebar)
        onVisibleChanged: Helper.updateColumnChildren(sidebar)
        onHeightChanged: Helper.updateColumnChildren(sidebar)

        PeriodItem {
            width: parent.width * 9 / 10
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            timepoint: getTimepoint()
            state: getTimeInterval()
            onMinusClicked: minusTimepoint()
            onPlusClicked: plusTimepoint()

            function getTimepoint() {
                if (bg.graphType === EnergyData.CumulativeDayGraph)
                    return Qt.formatDateTime(bg.timepoint, "dd/MM/yyyy")
                else if (bg.graphType === EnergyData.CumulativeMonthGraph)
                    return Qt.formatDateTime(bg.timepoint, "MM/yyyy")
                else if (bg.graphType === EnergyData.CumulativeYearGraph)
                    return Qt.formatDateTime(bg.timepoint, "yyyy")
            }

            function getTimeInterval() {
                if (bg.graphType === EnergyData.CumulativeDayGraph)
                    return "day"
                else if (bg.graphType === EnergyData.CumulativeMonthGraph)
                    return "month"
                else if (bg.graphType === EnergyData.CumulativeYearGraph)
                    return "year"
            }

            function plusTimepoint() {
                if (bg.graphType === EnergyData.CumulativeDayGraph) {
                    var d = new Date(bg.timepoint)
                    d.setDate(d.getDate() + 1)
                    if (d > new Date())
                        return
                    bg.timepointChanged(new Date(d))
                }
                else if (bg.graphType === EnergyData.CumulativeMonthGraph) {
                    var m = new Date(bg.timepoint)
                    m.setMonth(m.getMonth() + 1)
                    if (m > new Date())
                        return
                    bg.timepointChanged(new Date(m))
                }
                else if (bg.graphType === EnergyData.CumulativeYearGraph) {
                    var y = new Date(bg.timepoint)
                    y.setFullYear(y.getFullYear() + 1)
                    if (y > new Date())
                        return
                    bg.timepointChanged(new Date(y))
                }
            }

            function minusTimepoint() {
                if (bg.graphType === EnergyData.CumulativeDayGraph) {
                    var d = new Date(bg.timepoint)
                    d.setDate(d.getDate() - 1)
                    bg.timepointChanged(new Date(d))
                }
                else if (bg.graphType === EnergyData.CumulativeMonthGraph) {
                    var m = new Date(bg.timepoint)
                    m.setMonth(m.getMonth() - 1)
                    bg.timepointChanged(new Date(m))
                }
                else if (bg.graphType === EnergyData.CumulativeYearGraph) {
                    var y = new Date(bg.timepoint)
                    y.setFullYear(y.getFullYear() - 1)
                    bg.timepointChanged(new Date(y))
                }
            }
        }

        Rectangle {
            id: consumption

            color: "transparent"
            width: parent.width * 9 / 10
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter

            UbuntuLightText {
                text: qsTr("instant consumption")
                color: "white"
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Image {
                source: "../../images/common/bg_paginazione.png"
                height: 40
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                UbuntuLightText {
                    text: bg.value.isValid ? bg.value.value + " " + qsTr("Wh") : "---"
                    color: "black"
                    anchors {
                        fill: parent
                        centerIn: parent
                    }
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        ConsumptionBox {
            id: cumulativeConsumption
            state: getCumulativeState()
            width: parent.width * 9 / 10
            anchors.horizontalCenter: parent.horizontalCenter
            // TODO implementare (il valore recuperato è corretto?)
            value: bg.cumValue
            // TODO da dove si recupera il valore max?
            maxValue: 120
            unit: "kWh"

            function getCumulativeState() {
                if (bg.graphType === EnergyData.CumulativeDayGraph)
                    return "cumDay"
                else if (bg.graphType === EnergyData.CumulativeMonthGraph)
                    return "cumMonth"
                else if (bg.graphType === EnergyData.CumulativeYearGraph)
                    return "cumYear"
            }
        }

        ConsumptionBox {
            id: averageConsumption
            state: getAverageState()
            width: parent.width * 9 / 10
            anchors.horizontalCenter: parent.horizontalCenter
            // TODO implementare (come si recupera il valore medio sul periodo?)
            value: bg.avgValue
            // TODO da dove si recupera il valore max?
            maxValue: 120
            unit: "kWh"

            function getAverageState() {
                if (bg.graphType === EnergyData.CumulativeDayGraph)
                    return "avgDay"
                else if (bg.graphType === EnergyData.CumulativeMonthGraph)
                    return "avgMonth"
                else if (bg.graphType === EnergyData.CumulativeYearGraph)
                    return "avgYear"
            }
        }
    }
}
