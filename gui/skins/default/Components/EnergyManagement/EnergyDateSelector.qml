import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Row {
    id: selector
    property date date: new Date()

    spacing: 4

    function isEnergyMonthValid(d) {
        var year = d.getFullYear()
        var month = d.getMonth()

        var currentDate = new Date()
        var cur_year = currentDate.getFullYear()
        var cur_month = currentDate.getMonth()

        if (year === cur_year && month <= cur_month)
            return true
        if (year === cur_year - 1)
            return true

        if (year === cur_year - 2 && month > cur_month)
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
        // TODO: implement!
        return false
    }

    QtObject {
        id: privateProps

        // Month functions
        function previousMonth() {
            selector.date = _previousMonth(selector.date)
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
            selector.date = _nextMonth(selector.date)
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
            return selector.isEnergyMonthValid(_previousMonth(selector.date))
        }

        function nextMonthEnabled(){
            return selector.isEnergyMonthValid(_nextMonth(selector.date))
        }

        // Year functions
        function previousYear() {
            selector.date = _previousYear(selector.date)
        }

        function _previousYear(d) {
            d.setFullYear(d.getFullYear() - 1)
            return d
        }

        function nextYear() {
            selector.date = _nextYear(selector.date)
        }

        function _nextYear(d) {
            d.setFullYear(d.getFullYear() + 1)
            return d
        }

        function previousYearEnabled() {
            return selector.isEnergyYearValid(_previousYear(selector.date))
        }

        function nextYearEnabled() {
            return selector.isEnergyYearValid(_nextYear(selector.date))
        }

    }

    ButtonImageThreeStates {
        id: previousButton
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
            font.pixelSize: 13
            text: Qt.formatDateTime(selector.date, qsTr("MM/yyyy"))
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
            PropertyChanges { target: dateLabel; text: Qt.formatDateTime(selector.date, qsTr("yyyy")) }
            PropertyChanges { target: previousButton; onClicked: privateProps.previousYear() }
            PropertyChanges { target: previousButton; enabled: privateProps.previousYearEnabled() }
            PropertyChanges { target: nextButton; onClicked: privateProps.nextYear() }
            PropertyChanges { target: nextButton; enabled: privateProps.nextYearEnabled() }
        }
    ]
}
