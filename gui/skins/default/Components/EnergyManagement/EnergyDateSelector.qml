import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Row {
    id: selector
    property date monthDate: new Date()
    property date yearDate: new Date()
    property date dayDate: new Date()

    spacing: 4


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

        // Month functions
        function previousMonth() {
            selector.monthDate = _previousMonth(selector.monthDate)
        }

        function _previousMonth(d) {
            var month = d.getMonth()
            if (month === 0) {
                d.setFullYear(d.getFullYear() - 1)
                d.setMonth(11)
            }
            else {
                d.setMonth(month -1)
            }
            return d
        }

        function nextMonth() {
            selector.monthDate = _nextMonth(selector.monthDate)
        }

        function _nextMonth(d) {
            var month = d.getMonth()
            if (month === 11) {
                d.setFullYear(d.getFullYear() + 1)
                d.setMonth(0)
            }
            else {
                d.setMonth(month + 1)
            }
            return d
        }

        function previousMonthEnabled() {
            return selector.isEnergyMonthValid(_previousMonth(selector.monthDate))
        }

        function nextMonthEnabled(){
            return selector.isEnergyMonthValid(_nextMonth(selector.monthDate))
        }

        // Year functions
        function previousYear() {
            selector.yearDate = _previousYear(selector.yearDate)
        }

        function _previousYear(d) {
            d.setFullYear(d.getFullYear() - 1)
            return d
        }

        function nextYear() {
            selector.yearDate = _nextYear(selector.yearDate)
        }

        function _nextYear(d) {
            d.setFullYear(d.getFullYear() + 1)
            return d
        }

        function previousYearEnabled() {
            return selector.isEnergyYearValid(_previousYear(selector.yearDate))
        }

        function nextYearEnabled() {
            return selector.isEnergyYearValid(_nextYear(selector.yearDate))
        }


        // Day functions
        function previousDay() {
            selector.dayDate = _previousDay(selector.dayDate)
        }

        function daysInMonth(month, year) {
            return new Date(year, month + 1, 0).getDate()
        }

        function _previousDay(d) {
            if (d.getDate() === 1) {
                d = _previousMonth(d)
                d.setDate(daysInMonth(d.getMonth(), d.getFullYear()))
            }
            else
                d.setDate(d.getDate() - 1)
            return d
        }

        function nextDay() {
            selector.dayDate = _nextDay(selector.dayDate)
        }

        function _nextDay(d) {
            var day = d.getDate() + 1
            if (day > daysInMonth(d.getMonth(), d.getFullYear())) {
                d.setDate(1)
                return _nextMonth(d)
            }

            d.setDate(d.getDate() + 1)
            return d
        }

        function previousDayEnabled() {
            return selector.isEnergyDayValid(_previousDay(selector.dayDate))
        }

        function nextDayEnabled() {
            return selector.isEnergyDayValid(_nextDay(selector.dayDate))
        }
    }

    ButtonImageThreeStates {
        id: previousButton
        repetionOnHold: true
        defaultImageBg: "../../images/energy/btn_freccia.svg"
        pressedImageBg: "../../images/energy/btn_freccia_P.svg"
        shadowImage: "../../images/energy/ombra_btn_freccia.svg"
        defaultImage: "../../images/common/ico_freccia_sx.svg"
        pressedImage: "../../images/common/ico_freccia_sx_P.svg"

        onClicked: privateProps.previousMonth()
        enabled: privateProps.previousMonthEnabled()

        Rectangle {
            z: 1
            anchors.fill: parent
            color: "silver"
            opacity: 0.6
            visible: parent.enabled === false
        }
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
            text: Qt.formatDateTime(selector.monthDate, qsTr("MM/yyyy"))
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
        repetionOnHold: true
        defaultImageBg: "../../images/energy/btn_freccia.svg"
        pressedImageBg: "../../images/energy/btn_freccia_P.svg"
        shadowImage: "../../images/energy/ombra_btn_freccia.svg"
        defaultImage: "../../images/common/ico_freccia_dx.svg"
        pressedImage: "../../images/common/ico_freccia_dx_P.svg"

        onClicked: privateProps.nextMonth()
        enabled: privateProps.nextMonthEnabled()

        Rectangle {
            z: 1
            anchors.fill: parent
            color: "silver"
            opacity: 0.6
            visible: parent.enabled === false
        }
    }

    states: [
        State {
            name: "year"
            PropertyChanges { target: textLabel; text: qsTr("year") }
            PropertyChanges { target: dateLabel; text: Qt.formatDateTime(selector.yearDate, qsTr("yyyy")) }
            PropertyChanges { target: previousButton; onClicked: privateProps.previousYear() }
            PropertyChanges { target: previousButton; enabled: privateProps.previousYearEnabled() }
            PropertyChanges { target: nextButton; onClicked: privateProps.nextYear() }
            PropertyChanges { target: nextButton; enabled: privateProps.nextYearEnabled() }
        },
        State {
            name: "day"
            PropertyChanges { target: textLabel; text: qsTr("day") }
            PropertyChanges { target: dateLabel; text: Qt.formatDateTime(selector.dayDate, qsTr("dd/MM/yyyy")) }
            PropertyChanges { target: previousButton; onClicked: privateProps.previousDay() }
            PropertyChanges { target: previousButton; enabled: privateProps.previousDayEnabled() }
            PropertyChanges { target: nextButton; onClicked: privateProps.nextDay() }
            PropertyChanges { target: nextButton; enabled: privateProps.nextDayEnabled() }
        }
    ]
}
