/**
  * The page responsible for popup management.
  */

import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Popup 1.0
import BtExperience 1.0
import "js/Stack.js" as Stack
import "js/datetime.js" as DateTime
import "js/popup.js" as PopupLogic
import "js/navigation.js" as Navigation


BasePage {
    id: page

    opacity: 0
    _pageName: "PopupPage"

    Timer {
        id: dismissTimer

        running: false
        interval: 2000
        repeat: false
        onTriggered: privateProps.dismissTimerTriggered()
    }

    Component {
        id: generalPopupComponent
        ControlPopup {
            id: popupControl

            onDismissClicked: privateProps.update(PopupLogic.dismiss())
            onConfirmClicked: privateProps.navigate(PopupLogic.confirm())
        }
    }

    Component {
        id: scenarioPopupComponent
        FeedbackPopup {
            isOk: true
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: constants.alertTransitionDuration }
    }

    function updateUnreadMessages(unreadMessages) {
        privateProps.update(PopupLogic.updateUnreadMessages(unreadMessages))
    }

    function addAlarmPopup(type, zone, number, dateTime) {
        var dt = DateTime.format(dateTime)["time"] + " - " + DateTime.format(dateTime)["date"]

        var t = privateProps.antintrusionNames.get('ALARM_TYPE', type)

        var z = ""
        // computes zone description
        if (type === AntintrusionAlarm.Technical)
            z = zone.name
        else if (number >= 1 && number <= 8 && zone !== null)
            z = qsTr("zone") + " " + zone.name
        else
            z = qsTr("zone") + " " + number

        privateProps.update(PopupLogic.addAlarmPopup(t, z, dt))

        // rings the bell
        global.ringtoneManager.playRingtone(global.ringtoneManager.ringtoneFromType(RingtoneManager.Alarm), AudioState.Ringtone)
    }

    function addStopAndGoPopup(device) {
        if (device.status === StopAndGo.Unknown || device.status === StopAndGo.Closed) // not interesting
            return

        // status description
        var t = privateProps.energyManagementNames.get('STOP_GO_STATUS', device.status)

        privateProps.update(PopupLogic.addStopAndGoPopup(device.name, t))

        // rings the bell
        global.ringtoneManager.playRingtone(global.ringtoneManager.ringtoneFromType(RingtoneManager.Alarm), AudioState.Ringtone)
    }

    function addScenarioActivationPopup(description) {
        privateProps.update(PopupLogic.addScenarioActivationPopup(description))
    }

    function addThresholdExceededPopup(energyDevice) {
        privateProps.update(PopupLogic.addThresholdExceededPopup(energyDevice))
    }

    function addGoalReachedPopup(energyDevice) {
        privateProps.update(PopupLogic.addGoalReachedPopup(energyDevice))
    }

    function addMonthlyReportNotification() {
        privateProps.update(PopupLogic.addMonthlyReportNotification())
    }

    function addAlarmClockTriggering(device) {
        privateProps.update(PopupLogic.addAlarmClockPopup(device))
        device.ringingChanged.connect(removeAlarmClockPopup)
    }

    function removeAlarmClockPopup() {
        privateProps.update(PopupLogic.removeAlarmClockPopup())
    }

    // needed to translate antintrusion names in alarm popups
    QtObject {
        id: privateProps

        property QtObject antintrusionNames: AntintrusionNames {}
        property QtObject energyManagementNames: EnergyManagementNames {}

        property variant alarmClock

        function dismissTimerTriggered() {
            var p = PopupLogic.highestPriorityPopup()
            if (p["_kind"] === "scenario")
                privateProps.update(PopupLogic.dismiss())
        }

        function navigate(data) {
            if (data === "") {
                // no navigation data, simply closes the popup page
                closePopup()
                return
            }

            if (data === "Antintrusion") {
                Stack.goToPage("Antintrusion.qml", {navigationTarget: Navigation.ALARM_LOG})
            }

            if (data === "Supervision") {
                Stack.goToPage("EnergyManagement.qml", {navigationTarget: Navigation.SUPERVISION})
            }

            if (data === "Messages") {
                Stack.goToPage("Messages.qml")
            }

            if (data === "GlobalView") {
                Stack.goToPage("EnergyGlobalView.qml")
            }

            if (data[0] === "ThresholdExceeded") {
                Stack.pushPageBelow("EnergyDataGraph.qml", {energyData: data[1], state: "day"}).setComponentOnGraphLoader()
                closePopup()
                return
            }

            if (data[0] === "GoalReached") {
                Stack.pushPageBelow("EnergyDataGraph.qml", {energyData: data[1]})
                closePopup()
                return
            }
        }

        function update(data) {
            if (data === undefined) {
                // no data to show, we can pop the page
                closePopup()
                return
            }

            if (data["_kind"] === "scenario") {
                installPopup(scenarioPopupComponent)

                popupLoader.item.text = data.line1
            }
            else {
                installPopup(generalPopupComponent)

                popupLoader.item.title = data.title
                popupLoader.item.line1 = data.line1
                popupLoader.item.line2 = data.line2
                popupLoader.item.line3 = data.line3
                popupLoader.item.confirmText = data.confirmText
                popupLoader.item.dismissText = data.dismissText
            }

            if (data["_kind"] === "scenario")
                dismissTimer.start()

            if (page.opacity < 1)
                page.opacity = 1
        }

        function closePopup() {
            Stack.popPage()
        }
    }
}
