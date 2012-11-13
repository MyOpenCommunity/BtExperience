import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

import "../../js/datetime.js" as DateTime

Row {
    id: selector
    property date selectedDate: new Date()
    property variant energyData: undefined

    // updates back the real data
    onSelectedDateChanged: privateProps.selectedDate = selector.selectedDate

    spacing: 4

    Timer {
        id: updateTimer
        interval: 600
        repeat: false
        onTriggered: {
            selector.selectedDate = privateProps.selectedDate
        }
    }

    EnergyFunctions {
        id: energyFunctions
    }

    QtObject {
        id: privateProps

        property date selectedDate: new Date()

        // Month functions
        function previousMonth() {
            privateProps.selectedDate = DateTime.previousMonth(privateProps.selectedDate)
            updateTimer.restart()
        }

        function nextMonth() {
            privateProps.selectedDate = DateTime.nextMonth(privateProps.selectedDate)
            updateTimer.restart()
        }

        function previousMonthEnabled() {
            return energyFunctions.isEnergyMonthValid(DateTime.previousMonth(privateProps.selectedDate))
        }

        function nextMonthEnabled(){
            return energyFunctions.isEnergyMonthValid(DateTime.nextMonth(privateProps.selectedDate))
        }

        // Year functions
        function previousYear() {
            privateProps.selectedDate = DateTime.previousYear(privateProps.selectedDate)
            updateTimer.restart()
        }

        function nextYear() {
            privateProps.selectedDate = DateTime.nextYear(privateProps.selectedDate)
            updateTimer.restart()
        }

        function previousYearEnabled() {
            var d = DateTime.previousYear(privateProps.selectedDate)
            return energyFunctions.isEnergyYearValid(d) && energyData.isValidDate(d)
        }

        function nextYearEnabled() {
            return energyFunctions.isEnergyYearValid(DateTime.nextYear(privateProps.selectedDate))
        }

        // Day functions
        function previousDay() {
            privateProps.selectedDate = DateTime.previousDay(privateProps.selectedDate)
            updateTimer.restart()
        }

        function nextDay() {
            privateProps.selectedDate = DateTime.nextDay(privateProps.selectedDate)
            updateTimer.restart()
        }

        function previousDayEnabled() {
            return energyFunctions.isEnergyDayValid(DateTime.previousDay(privateProps.selectedDate))
        }

        function nextDayEnabled() {
            return energyFunctions.isEnergyDayValid(DateTime.nextDay(privateProps.selectedDate))
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
            text: Qt.formatDateTime(privateProps.selectedDate, qsTr("MM/yyyy"))
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

    states: [
        State {
            name: "year"
            PropertyChanges { target: textLabel; text: qsTr("year") }
            PropertyChanges { target: dateLabel; text: Qt.formatDateTime(privateProps.selectedDate, qsTr("yyyy")) }
            PropertyChanges { target: previousButton; onClicked: privateProps.previousYear() }
            PropertyChanges { target: previousButton; enabled: privateProps.previousYearEnabled() }
            PropertyChanges { target: nextButton; onClicked: privateProps.nextYear() }
            PropertyChanges { target: nextButton; enabled: privateProps.nextYearEnabled() }
        },
        State {
            name: "day"
            PropertyChanges { target: textLabel; text: qsTr("day") }
            PropertyChanges { target: dateLabel; text: Qt.formatDateTime(privateProps.selectedDate, qsTr("dd/MM/yyyy")) }
            PropertyChanges { target: previousButton; onClicked: privateProps.previousDay() }
            PropertyChanges { target: previousButton; enabled: privateProps.previousDayEnabled() }
            PropertyChanges { target: nextButton; onClicked: privateProps.nextDay() }
            PropertyChanges { target: nextButton; enabled: privateProps.nextDayEnabled() }
        },
        State {
            name: "lastyear"
            PropertyChanges { target: textLabel; text: qsTr("year") }
            AnchorChanges { target: textLabel; anchors.top: undefined; anchors.verticalCenter: parent.verticalCenter }
            PropertyChanges { target: dateLabel; text: "" }
            PropertyChanges { target: previousButton; enabled: false }
            PropertyChanges { target: nextButton; enabled: false }
        }

    ]
}
