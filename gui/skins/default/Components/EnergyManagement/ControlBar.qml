import QtQuick 1.1
import BtObjects 1.0

import "../../js/RowColumnHelpers.js" as Helper


Row {
    id: bg

    property bool inCurrency
    property bool graphVisible

    signal graphVisibleChanged(bool visibility)
    signal inCurrencyChanged(bool value)
    signal graphTypeChanged(int value)

    onChildrenChanged: Helper.updateRowChildren(timeValue)
    onVisibleChanged: Helper.updateRowChildren(timeValue)
    onWidthChanged: Helper.updateRowChildren(timeValue)

    TimeValueItem {
        label: qsTr("time")
        state: "legend"
    }

    TimeValueItem {
        id: selDay
        label: qsTr("day")
        onClicked: {
            selDay.state = "selected"
            selMonth.state = ""
            selYear.state = ""
            bg.graphTypeChanged(EnergyData.CumulativeDayGraph)
        }
    }

    TimeValueItem {
        id: selMonth
        label: qsTr("month")
        onClicked: {
            selDay.state = ""
            selMonth.state = "selected"
            selYear.state = ""
            bg.graphTypeChanged(EnergyData.CumulativeMonthGraph)
        }
    }

    TimeValueItem {
        id: selYear
        label: qsTr("year")
        state: "selected"
        onClicked: {
            selDay.state = ""
            selMonth.state = ""
            selYear.state = "selected"
            bg.graphTypeChanged(EnergyData.CumulativeYearGraph)
        }
    }

    TimeValueItem {
        label: qsTr("")
        state: "legend"
    }

    TimeValueItem {
        id: selUnit
        label: bg.inCurrency ? qsTr("kWh") : qsTr("euro")
        onClicked: bg.inCurrencyChanged(!bg.inCurrency)
    }

    TimeValueItem {
        id: selGraph
        label: bg.graphVisible ? qsTr("sheet") : qsTr("graph")
        onClicked: bg.graphVisibleChanged(!bg.graphVisible)
    }
}
