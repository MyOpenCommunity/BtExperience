/**
  * The page responsible for popup management.
  */

import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import BtExperience 1.0
import "js/Stack.js" as Stack
import "js/datetime.js" as DateTime
import "js/popup.js" as PopupLogic
import "js/navigation.js" as Navigation


BasePage {
    id: page

    opacity: 0

    Timer {
        id: dismissTimer

        running: false
        interval: 2000
        repeat: false
        onTriggered: privateProps.dismissTimerTriggered()
    }

    Component {
        id: popupComponent
        ControlPopup {
            id: popupControl

            onDismissClicked: privateProps.update(PopupLogic.dismiss())
            onConfirmClicked: privateProps.navigate(PopupLogic.confirm())
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: constants.alertTransitionDuration }
    }

    Component.onCompleted: {
        popupLoader.sourceComponent = popupComponent
        state = "popup"
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
            z = qsTr("aux") + " " + number
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
        privateProps.update(PopupLogic.addThresholdExceededPopup(energyDevice.name, energyDevice.thresholdLevel))
    }

    function addGoalReachedPopup(energyDevice) {
        privateProps.update(PopupLogic.addGoalReachedPopup(energyDevice.name, energyDevice.goalLevel))
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
                popupLoader.sourceComponent = undefined
                Stack.goToPage("Antintrusion.qml", {"navigationTarget": Navigation.ALARM_LOG})
            }

            if (data === "Supervision") {
                popupLoader.sourceComponent = undefined
                Stack.goToPage("EnergyManagement.qml", {"navigationTarget": Navigation.SUPERVISION})
            }

            if (data === "Messages") {
                popupLoader.sourceComponent = undefined
                Stack.goToPage("Messages.qml")
            }

            if (data === "GlobalView") {
                popupLoader.sourceComponent = undefined
                Stack.goToPage("EnergyGlobalView.qml")
            }
        }

        function update(data) {
            if (data === undefined) {
                // no data to show, we can pop the page
                closePopup()
                return
            }

            popupLoader.item.title = data.title
            popupLoader.item.line1 = data.line1
            popupLoader.item.line2 = data.line2
            popupLoader.item.line3 = data.line3
            popupLoader.item.confirmText = data.confirmText
            popupLoader.item.dismissText = data.dismissText

            if (data["_kind"] === "scenario")
                dismissTimer.start()

            if (page.opacity < 1)
                page.opacity = 1
        }

        function closePopup() {
            popupLoader.sourceComponent = undefined
            Stack.popPage()
        }
    }
}
