import QtQuick 1.1
import BtObjects 1.0

import "../../js/RowColumnHelpers.js" as Helper


Row {
    id: timeValue

    property variant pageRef

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
            pageRef.graphType = EnergyData.CumulativeDayGraph
        }
    }

    TimeValueItem {
        id: selMonth
        label: qsTr("month")
        onClicked: {
            selDay.state = ""
            selMonth.state = "selected"
            selYear.state = ""
            pageRef.graphType = EnergyData.CumulativeMonthGraph
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
            pageRef.graphType = EnergyData.CumulativeYearGraph
        }
    }

    TimeValueItem {
        label: qsTr("")
        state: "legend"
    }

    TimeValueItem {
        id: selUnit
        label: pageRef.inCurrency ? qsTr("kWh") : qsTr("euro")
        onClicked: pageRef.inCurrency = !pageRef.inCurrency
    }

    TimeValueItem {
        id: selGraph
        label: pageRef.graphVisible ? qsTr("sheet") : qsTr("graph")
        onClicked: pageRef.graphVisible = !pageRef.graphVisible
    }
}
