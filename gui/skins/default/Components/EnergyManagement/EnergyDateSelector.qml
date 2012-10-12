import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

import "../../js/datetime.js" as DateTime

Row {
    id: selector
    // because we have an unique date for month, year and day, we use aliases to
    // avoid wasting memoty and mantain a separate API.

    property date monthDate: new Date()
    property alias yearDate: selector.monthDate
    property alias dayDate: selector.monthDate

    // updates back the real datas
    onMonthDateChanged: privateProps.monthDate = selector.monthDate
    onYearDateChanged: privateProps.yearDate = selector.yearDate
    onDayDateChanged: privateProps.dayDate = selector.dayDate

    spacing: 4

    Timer {
        id: updateTimer
        interval: 600
        repeat: false
        onTriggered: {
            selector.monthDate = privateProps.monthDate
            selector.yearDate = privateProps.yearDate
            selector.dayDate = privateProps.dayDate
        }
    }

    function isEnergyMonthValid(d) {
        var year = d.getFullYear()
        var month = d.getMonth()

        var currentDate = new Date()
        var cur_year = currentDate.getFullYear()
        var cur_month = currentDate.getMonth()

        if (year === cur_year && month <= cur_month)
            return true

        if (year === cur_year - 1 && month > cur_month)
            return true

        return false
    }

    function isEnergyYearValid(d) {
        var year = d.getFullYear()
        var cur_year = new Date().getFullYear()

        if (year <= cur_year && year >= cur_year - 12)
            return true

        return false
    }

    function isEnergyDayValid(d) {
        var currentDate = new Date()
        if (d.getTime() > currentDate.getTime())
            return false

        var year = d.getFullYear()
        var month = d.getMonth()
        var day = d.getDate()

        var cur_year = currentDate.getFullYear()
        var cur_month = currentDate.getMonth()
        var cur_day = currentDate.getDate()

        if (year === cur_year)
            return true
        if (year === cur_year -1 && month > cur_month)
            return true

        if (year === cur_year -1 && month === cur_month && day > cur_day)
            return true

        return false
    }

    QtObject {
        id: privateProps

        property date _date: new Date()
        property alias monthDate: privateProps._date
        property alias yearDate: privateProps._date
        property alias dayDate: privateProps._date

        // Month functions
        function previousMonth() {
            privateProps.monthDate = DateTime.previousMonth(privateProps.monthDate)
            updateTimer.restart()
        }

        function nextMonth() {
            privateProps.monthDate = DateTime.nextMonth(privateProps.monthDate)
            updateTimer.restart()
        }

        function previousMonthEnabled() {
            return selector.isEnergyMonthValid(DateTime.previousMonth(privateProps.monthDate))
        }

        function nextMonthEnabled(){
            return selector.isEnergyMonthValid(DateTime.nextMonth(privateProps.monthDate))
        }

        // Year functions
        function previousYear() {
            privateProps.yearDate = DateTime.previousYear(privateProps.yearDate)
            updateTimer.restart()
        }

        function nextYear() {
            privateProps.yearDate = DateTime.nextYear(privateProps.yearDate)
            updateTimer.restart()
        }

        function previousYearEnabled() {
            return selector.isEnergyYearValid(DateTime.previousYear(privateProps.yearDate))
        }

        function nextYearEnabled() {
            return selector.isEnergyYearValid(DateTime.nextYear(privateProps.yearDate))
        }

        // Day functions
        function previousDay() {
            privateProps.dayDate = DateTime.previousDay(privateProps.dayDate)
            updateTimer.restart()
        }

        function nextDay() {
            privateProps.dayDate = DateTime.nextDay(privateProps.dayDate)
            updateTimer.restart()
        }

        function previousDayEnabled() {
            return selector.isEnergyDayValid(DateTime.previousDay(privateProps.dayDate))
        }

        function nextDayEnabled() {
            return selector.isEnergyDayValid(DateTime.nextDay(privateProps.dayDate))
        }
    }

    ButtonImageThreeStates {
        id: previousButton
        repetitionOnHold: true
        defaultImageBg: "../../images/energy/btn_freccia.svg"
        pressedImageBg: "../../images/energy/btn_freccia_P.svg"
        shadowImage: "../../images/energy/ombra_btn_freccia.svg"
        defaultImage: "../../images/common/ico_freccia_sx.svg"
        pressedImage: "../../images/common/ico_freccia_sx_P.svg"

        onClicked: privateProps.previousMonth()
        enabled: privateProps.previousMonthEnabled()
    }

    SvgImage {
        source: "../../images/energy/btn_selectDMY.svg"

        UbuntuLightText {
            id: textLabel
            text: qsTr("month")
            font.pixelSize: 14
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
        }

        UbuntuLightText {
            id: dateLabel
            font.pixelSize: 14
            text: Qt.formatDateTime(privateProps.monthDate, qsTr("MM/yyyy"))
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: textLabel.bottom
                topMargin: 5
            }
        }

        SvgImage {
            anchors {
                left: parent.left
                top: parent.bottom
                right: parent.right
            }
            source: "../../images/energy/ombra_btn_selectDMY.svg"
        }
    }

    ButtonImageThreeStates {
        id: nextButton
        repetitionOnHold: true
        defaultImageBg: "../../images/energy/btn_freccia.svg"
        pressedImageBg: "../../images/energy/btn_freccia_P.svg"
        shadowImage: "../../images/energy/ombra_btn_freccia.svg"
        defaultImage: "../../images/common/ico_freccia_dx.svg"
        pressedImage: "../../images/common/ico_freccia_dx_P.svg"

        onClicked: privateProps.nextMonth()
        enabled: privateProps.nextMonthEnabled()
    }

    onStateChanged: {
        privateProps._date = new Date(); // reset the day/month/year to the current one
    }

    states: [
        State {
            name: "year"
            PropertyChanges { target: textLabel; text: qsTr("year") }
            PropertyChanges { target: dateLabel; text: Qt.formatDateTime(privateProps.yearDate, qsTr("yyyy")) }
            PropertyChanges { target: previousButton; onClicked: privateProps.previousYear() }
            PropertyChanges { target: previousButton; enabled: privateProps.previousYearEnabled() }
            PropertyChanges { target: nextButton; onClicked: privateProps.nextYear() }
            PropertyChanges { target: nextButton; enabled: privateProps.nextYearEnabled() }
        },
        State {
            name: "day"
            PropertyChanges { target: textLabel; text: qsTr("day") }
            PropertyChanges { target: dateLabel; text: Qt.formatDateTime(privateProps.dayDate, qsTr("dd/MM/yyyy")) }
            PropertyChanges { target: previousButton; onClicked: privateProps.previousDay() }
            PropertyChanges { target: previousButton; enabled: privateProps.previousDayEnabled() }
            PropertyChanges { target: nextButton; onClicked: privateProps.nextDay() }
            PropertyChanges { target: nextButton; enabled: privateProps.nextDayEnabled() }
        }
    ]
}
