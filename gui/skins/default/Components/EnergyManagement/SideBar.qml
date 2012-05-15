import QtQuick 1.1
import BtObjects 1.0

import "../../js/RowColumnHelpers.js" as Helper


Rectangle {
    id: bg

    property variant pageRef

    color: "gray"
    width: 200
    radius: 4

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
                if (pageRef.graphType === EnergyData.CumulativeDayGraph)
                    return Qt.formatDateTime(pageRef.timepoint, "dd/MM/yyyy")
                else if (pageRef.graphType === EnergyData.CumulativeMonthGraph)
                    return Qt.formatDateTime(pageRef.timepoint, "MM/yyyy")
                else if (pageRef.graphType === EnergyData.CumulativeYearGraph)
                    return Qt.formatDateTime(pageRef.timepoint, "yyyy")
            }

            function getTimeInterval() {
                if (pageRef.graphType === EnergyData.CumulativeDayGraph)
                    return "day"
                else if (pageRef.graphType === EnergyData.CumulativeMonthGraph)
                    return "month"
                else if (pageRef.graphType === EnergyData.CumulativeYearGraph)
                    return "year"
            }

            function plusTimepoint() {
                if (pageRef.graphType === EnergyData.CumulativeDayGraph) {
                    var d = new Date(pageRef.timepoint)
                    d.setDate(d.getDate() + 1)
                    if (d > new Date())
                        return
                    pageRef.timepoint = new Date(d)
                }
                else if (pageRef.graphType === EnergyData.CumulativeMonthGraph) {
                    var m = new Date(pageRef.timepoint)
                    m.setMonth(m.getMonth() + 1)
                    if (m > new Date())
                        return
                    pageRef.timepoint = new Date(m)
                }
                else if (pageRef.graphType === EnergyData.CumulativeYearGraph) {
                    var y = new Date(pageRef.timepoint)
                    y.setFullYear(y.getFullYear() + 1)
                    if (y > new Date())
                        return
                    pageRef.timepoint = new Date(y)
                }
            }

            function minusTimepoint() {
                if (pageRef.graphType === EnergyData.CumulativeDayGraph) {
                    var d = new Date(pageRef.timepoint)
                    d.setDate(d.getDate() - 1)
                    pageRef.timepoint = new Date(d)
                }
                else if (pageRef.graphType === EnergyData.CumulativeMonthGraph) {
                    var m = new Date(pageRef.timepoint)
                    m.setMonth(m.getMonth() - 1)
                    pageRef.timepoint = new Date(m)
                }
                else if (pageRef.graphType === EnergyData.CumulativeYearGraph) {
                    var y = new Date(pageRef.timepoint)
                    y.setFullYear(y.getFullYear() - 1)
                    pageRef.timepoint = new Date(y)
                }
            }
        }

        Rectangle {
            id: consumption

            color: "transparent"
            width: parent.width * 9 / 10
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
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

            Rectangle {
                color: "light gray"
                height: 40
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                Text {
                    text: (instantValue.isValid ? instantValue.value : 0) + " " + qsTr("Wh")
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
            value: pageRef.cumulativeValue
            // TODO da dove si recupera il valore max?
            maxValue: 120
            unit: "kWh"

            function getCumulativeState() {
                if (pageRef.graphType === EnergyData.CumulativeDayGraph)
                    return "cumDay"
                else if (pageRef.graphType === EnergyData.CumulativeMonthGraph)
                    return "cumMonth"
                else if (pageRef.graphType === EnergyData.CumulativeYearGraph)
                    return "cumYear"
            }
        }

        ConsumptionBox {
            id: averageConsumption
            state: getAverageState()
            width: parent.width * 9 / 10
            anchors.horizontalCenter: parent.horizontalCenter
            // TODO implementare (come si recupera il valore medio sul periodo?)
            value: pageRef.averageValue
            // TODO da dove si recupera il valore max?
            maxValue: 120
            unit: "kWh"

            function getAverageState() {
                if (pageRef.graphType === EnergyData.CumulativeDayGraph)
                    return "avgDay"
                else if (pageRef.graphType === EnergyData.CumulativeMonthGraph)
                    return "avgMonth"
                else if (pageRef.graphType === EnergyData.CumulativeYearGraph)
                    return "avgYear"
            }
        }
    }
}
