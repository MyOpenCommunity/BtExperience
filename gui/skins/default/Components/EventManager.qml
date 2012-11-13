import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

import "../js/Stack.js" as Stack
import "../js/TurnOffMonitor.js" as TurnOff
import "../js/EventManager.js" as Script


Item {
    id: eventManager

    property int alarms: privateProps.antintrusionModel === undefined ? 0 : loader.item.alarmsModel.count
    property bool antintrusionPresent: privateProps.antintrusionModel !== undefined
    property bool isAntintrusionInserted: privateProps.antintrusionModel === undefined ? false : privateProps.antintrusionModel.status
    property bool autoOpen: privateProps.vctModel === undefined ? false : privateProps.vctModel.autoOpen
    property bool handsFree: privateProps.vctModel === undefined ? false : privateProps.vctModel.handsFree
    property bool vdeMute: privateProps.vctModel === undefined ? false : privateProps.vctModel.ringExclusion
    property int messages: privateProps.messagesModel === undefined ? 0 : privateProps.messagesModel.unreadMessages
    property int dangers: privateProps.dangersModel === undefined ? 0 : privateProps.dangersModel.openedDevices
    property bool scenarioRecording: privateProps.recordingModel === undefined ? false : privateProps.recordingModel.recording
    property bool playing: global.audioPlayer === undefined ? false : global.audioPlayer.playing
    property bool mute: global.audioState === null ? false : (global.audioState.state === AudioState.LocalPlaybackMute || global.audioState.state === AudioState.Mute)
    property bool clocksEnabled: privateProps.clocksModel === null ? false : privateProps.clocksModel.enabled

    signal changePageDone

    anchors.fill: parent

    Component {
        id: callPopup
        ControlCall {
            onClosePopup: {
                privateProps.monitorEvent()
                turnOffMonitor.isEnabled = true
                global.audioState.disableState(AudioState.VdeRingtone)
                global.audioState.disableState(AudioState.ScsIntercomCall)
                global.audioState.disableState(AudioState.IpIntercomCall)
                global.audioState.disableState(AudioState.Mute)
            }
        }
    }

    ObjectModel {
        id: listModel
        filters: [
            {objectId: ObjectInterface.IdCCTV},
            {objectId: ObjectInterface.IdIntercom},
            {objectId: ObjectInterface.IdAntintrusionSystem},
            {objectId: ObjectInterface.IdMessages},
            {objectId: ObjectInterface.IdDangers},
            {objectId: ObjectInterface.IdEnergies},
            {objectId: ObjectInterface.IdScenarioModulesNotifier},
            {objectId: ObjectInterface.IdAlarmClockNotifier}
        ]
        Component.onCompleted: {
            privateProps.updateTimerInterval()
            monthlyReportTimer.start()
            for (var i = 0; i < listModel.count; ++i) {
                var obj = listModel.getObject(i)
                switch (obj.objectId) {
                case ObjectInterface.IdCCTV:
                    vctConnection.target = obj
                    privateProps.vctModel = obj
                    break
                case ObjectInterface.IdIntercom:
                    intercomConnection.target = obj
                    break
                case ObjectInterface.IdAntintrusionSystem:
                    antintrusionConnection.target = obj
                    privateProps.antintrusionModel = obj
                    break
                case ObjectInterface.IdMessages:
                    messagesConnection.target = obj
                    privateProps.messagesModel = obj
                    break
                case ObjectInterface.IdDangers:
                    stopAndGoConnection.target = obj
                    privateProps.dangersModel = obj
                    break
                case ObjectInterface.IdEnergies:
                    energiesConnection.target = obj
                    break
                case ObjectInterface.IdScenarioModulesNotifier:
                    scenarioConnection.target = obj
                    privateProps.recordingModel = obj
                    break
                case ObjectInterface.IdAlarmClockNotifier:
                    clocksConnection.target = obj
                    privateProps.clocksModel = obj
                    break
                }
            }
        }
    }

    Timer {
        id: monthlyReportTimer
        repeat: true
        onTriggered: {
            if (!global.guiSettings.energyPopup)
                return

            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.MONTHLY_REPORT_ARRIVING})
            }
            else
                privateProps.monthlyReportArriving()
        }
    }

    TurnOffMonitor {
        id: turnOffMonitor
        z: parent.z
    }

    Loader {
        id: loader
        sourceComponent: privateProps.antintrusionModel !== undefined ? alarmsModelComponent : undefined
    }

    Component {
        id: alarmsModelComponent
        Item {
            property alias alarmsModel: alarmsModelObjModel
            ObjectModel {
                id: alarmsModelObjModel
                source: privateProps.antintrusionModel.alarms
            }
        }
    }

    Connections {
        id: vctConnection
        target: null
        onIncomingCall: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.VCT_INCOMING_CALL})
            }
            else
                privateProps.vctIncomingCall()
        }
        onCallAnswered: {
            if (vctConnection.target.isIpCall)
                global.audioState.enableState(AudioState.IpVideoCall)
            else
                global.audioState.enableState(AudioState.ScsVideoCall)
        }
        onCallEnded: {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            global.audioState.disableState(AudioState.VdeRingtone)
            global.audioState.disableState(AudioState.ScsVideoCall)
            global.audioState.disableState(AudioState.IpVideoCall)
            global.audioState.disableState(AudioState.Mute)
        }
        onRingtoneReceived: {
            // VdeRingtone state should always be enabled to stop multimedia playback during call
            if (!vctConnection.target.ringExclusion)
                global.ringtoneManager.playRingtoneAndKeepState(global.ringtoneManager.ringtoneFromType(vctConnection.target.ringtone), AudioState.VdeRingtone)
            else
                global.audioState.enableState(AudioState.VdeRingtone)
        }
    }

    Connections {
        id: intercomConnection
        target: null
        onIncomingCall: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.INTERCOM_INCOMING_CALL})
            }
            else
                privateProps.intercomIncomingCall()
        }
        onCallAnswered: {
            if (intercomConnection.target.isIpCall)
                global.audioState.enableState(AudioState.IpIntercomCall)
            else
                global.audioState.enableState(AudioState.ScsIntercomCall)
        }
        onCallEnded: {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            global.audioState.disableState(AudioState.VdeRingtone)
            global.audioState.disableState(AudioState.ScsIntercomCall)
            global.audioState.disableState(AudioState.IpIntercomCall)
            global.audioState.disableState(AudioState.Mute)
        }
        onRingtoneReceived: {
            // VdeRingtone state should always be enabled to stop multimedia playback during call
            if (!intercomConnection.target.getRingExclusion())
                global.ringtoneManager.playRingtoneAndKeepState(global.ringtoneManager.ringtoneFromType(intercomConnection.target.ringtone), AudioState.VdeRingtone)
            else
                global.audioState.enableState(AudioState.VdeRingtone)
        }
        onFloorRingtoneReceived: {
            if (!intercomConnection.target.getRingExclusion())
                global.ringtoneManager.playRingtone(global.ringtoneManager.ringtoneFromType(intercomConnection.target.ringtone), AudioState.FloorCall)
        }
    }

    Connections {
        id: antintrusionConnection
        target: null
        onNewAlarm: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.ALARM_ARRIVING, "data": alarm})
            }
            else
                privateProps.alarmArriving(alarm)
        }
    }

    Connections {
        id: stopAndGoConnection
        target: null
        onStopAndGoDeviceChanged: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.STOP_GO_DEVICE_CHANGING, "data": stopGoDevice})
            }
            else
                privateProps.stopAndGoDeviceChanging(stopGoDevice)
        }
    }

    Connections {
        id: energiesConnection
        target: null
        onThresholdExceeded: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.THRESHOLD_EXCEEDING, "data": energyDevice})
            }
            else
                privateProps.thresholdExceeding(energyDevice)
        }
        onGoalReached: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.GOAL_REACHING, "data": energyDevice})
            }
            else
                privateProps.goalReaching(energyDevice)
        }
    }

    Connections {
        id: messagesConnection
        target: null
        onUnreadMessagesChanged: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.UNREAD_MESSAGES_UPDATING})
            }
            else
                privateProps.unreadMessagesUpdate()
        }
    }

    Connections {
        id: clocksConnection
        target: null
        onRingAlarmClock: {
            global.ringtoneManager.playRingtoneAndKeepState(global.extraPath + "10/alarm.wav", AudioState.Ringtone)
        }
        onAlarmStarted: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.ALARM_CLOCK_TRIGGERING, "data": alarmClock})
            }
            else
                privateProps.alarmClockTriggering(alarmClock)
        }
        onBeepAlarmActiveChanged: {
            if (clocksConnection.target.beepAlarmActive)
                global.audioState.enableState(AudioState.Ringtone)
            else
                global.audioState.disableState(AudioState.Ringtone)
        }
    }

    Connections {
        id: scenarioConnection
        target: null
        onScenarioActivated: {
            if (Stack.isPageChanging(changePageDone)) {
                Script.delayedNotifications.push({"type": Script.SCENARIO_ACTIVATION, "data": description})
            }
            else
                privateProps.scenarioActivation(description)
        }
    }

    Connections {
        target: global.hardwareKeys
        onPressed: {
            if (!cctvModel.count === 0)
                return

            // call default external point on hardware key 2
            if (index === 2)
                cctvModel.getObject(0).cameraOn(global.defaultExternalPlace)
        }
    }

    ObjectModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    onChangePageDone: {
        if (Script.delayedNotifications.length === 0)
            return

        var notify = Script.delayedNotifications[0]
        Script.delayedNotifications.shift()

        if (notify["type"] === Script.ALARM_ARRIVING)
            privateProps.alarmArriving(notify["data"])
        else if (notify["type"] === Script.GOAL_REACHING)
            privateProps.goalReaching(notify["data"])
        else if (notify["type"] === Script.MONTHLY_REPORT_ARRIVING)
            privateProps.monthlyReportArriving()
        else if (notify["type"] === Script.VCT_INCOMING_CALL)
            privateProps.vctIncomingCall()
        else if (notify["type"] === Script.INTERCOM_INCOMING_CALL)
            privateProps.intercomIncomingCall()
        else if (notify["type"] === Script.STOP_GO_DEVICE_CHANGING)
            privateProps.stopAndGoDeviceChanging(notify["data"])
        else if (notify["type"] === Script.THRESHOLD_EXCEEDING)
            privateProps.thresholdExceeding(notify["data"])
        else if (notify["type"] === Script.SCENARIO_ACTIVATION)
            privateProps.scenarioActivation(notify["data"])
        else if (notify["type"] === Script.ALARM_CLOCK_TRIGGERING)
            privateProps.alarmClockTriggering(notify["data"])
        else if (notify["type"] === Script.UNREAD_MESSAGES_UPDATING)
            privateProps.unreadMessagesUpdate()
    }

    QtObject {
        id: privateProps

        property variant antintrusionModel: undefined
        property variant messagesModel: undefined
        property variant vctModel: undefined
        property variant dangersModel: undefined
        property variant recordingModel: undefined
        property variant clocksModel: undefined

        // ends the right call type
        function endActualCall(pagename) {
            if (pagename === "VideoCamera")
                if (vctConnection.target)
                    vctConnection.target.endCall()
            if (pagename === "IntercomPage")
                if (intercomConnection.target)
                    intercomConnection.target.endCall()
        }

        // prepares the popup page to show a popup
        //
        // when a popup arrives, we need show it, but only under certain
        // conditions; if those conditions are not met we must put the popup
        // page under the current page and add them to it: when the page above closes
        // the popup page will automagically appear showing all popups
        function preparePopupPage(closeOpenCall) {
            // gets current page (if popups are still to be managed we assume
            // popup page is at the top of the stack; exceptions will be treated
            // separately in subsequent ifs)
            var p = Stack.currentPage()

            // if current page is vct or intercom, pushes PopupPage below it and ends call
            if (p._pageName === "VideoCamera" || p._pageName === "IntercomPage") {
                // records what is the current call page
                var callPageName = p._pageName

                // rings alarm
                global.ringtoneManager.playRingtone(global.ringtoneManager.ringtoneFromType(RingtoneManager.Alarm), AudioState.Ringtone)

                // eventually pushes popup page below vct page (vct close is asynchronous)
                if (Stack.findPage("PopupPage") === null)
                    Stack.pushPageBelow("PopupPage.qml")

                // gets popup page
                p = Stack.findPage("PopupPage")

                // Must stay here because it emits callEnded signal, close is
                // asynchronous, so some time may pass before page is actually
                // closed
                if (closeOpenCall)
                    privateProps.endActualCall(callPageName)
            }

            // if p doesn't point to Popup page, pushes it
            if (p._pageName !== "PopupPage")
                p = Stack.pushPage("PopupPage.qml")

            if (!p) // something bad happened
                console.log("PopupPage not opened.")

            // returns pointer to PopupPage
            return p
        }

        // if a call is in progress the corresponding page is at the top of the
        // stack; keep in mind that is not possible that a vct call arrives when
        // an intercom call is in progress or viceversa: bt_processes end actual
        // call before starting a new call
        function checkCallInProgress(type) {
            var p = Stack.currentPage()

            // if there is a call already in progress of the right type returns true
            if (p._pageName === type)
                return true

            // no call in progress returns false
            return false
        }

        function updateTimerInterval() {
            monthlyReportTimer.stop()
            var n = new Date()
            var n2 = new Date(n.getFullYear(), n.getMonth() + 1, 1)
            var delta = n2.getTime() - n.getTime()
            if (delta <= 0)
                n2 = new Date(n.getFullYear(), n.getMonth() + 2, 1)
            delta = n2.getTime() - n.getTime()
            monthlyReportTimer.interval = delta
        }

        // this is needed to manage the activation of the monitor;
        // this function is used to send an event to reactivate the monitor
        // even in those cases where an interaction with the user is not performed;
        // see comments in TurnOffMonitor.js file for more info on this subject
        function monitorEvent() {
            // the updateLast call is needed to compute elapsed time correctly
            // see comments in TurnOffMonitor.js file for more info on this subject
            TurnOff.updateLast()
        }

        function monthlyReportArriving() {
            privateProps.updateTimerInterval()
            var p = privateProps.preparePopupPage(false)
            // adds monthly report notification
            p.addMonthlyReportNotification()
        }

        function vctIncomingCall() {
            turnOffMonitor.isEnabled = false
            if (checkCallInProgress("VideoCamera"))
                return
            Stack.pushPage("VideoCamera.qml", {"camera": vctConnection.target})
        }

        function intercomIncomingCall() {
            if (checkCallInProgress("IntercomPage"))
                return
            turnOffMonitor.isEnabled = false
            Stack.pushPage("IntercomPage.qml", {"callObject": intercomConnection.target})
        }

        function alarmArriving(alarm) {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            var p = privateProps.preparePopupPage(true)
            // adds antintrusion alarm
            p.addAlarmPopup(alarm.type, alarm.source, alarm.number, alarm.date_time)
        }

        function stopAndGoDeviceChanging(stopGoDevice) {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            var p = privateProps.preparePopupPage(false)
            // adds stop&go alarm
            p.addStopAndGoPopup(stopGoDevice)
        }

        function thresholdExceeding(energyDevice) {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            var p = privateProps.preparePopupPage(false)
            // adds threshold alarm
            p.addThresholdExceededPopup(energyDevice)
        }

        function goalReaching(energyDevice) {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            var p = privateProps.preparePopupPage(false)
            // adds goal alarm
            p.addGoalReachedPopup(energyDevice)
        }

        function unreadMessagesUpdate() {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            var p = privateProps.preparePopupPage(false)
            // updates number of unread messages
            p.updateUnreadMessages(messagesConnection.target.unreadMessages)
        }

        function scenarioActivation(description) {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            var p = privateProps.preparePopupPage(false)
            // adds popup for scenario activation
            p.addScenarioActivationPopup(description)
        }

        function alarmClockTriggering(alarmClock) {
            privateProps.monitorEvent()
            turnOffMonitor.isEnabled = true
            var p = privateProps.preparePopupPage(false)
            // adds alarm clock triggering
            p.addAlarmClockTriggering(alarmClock)
        }
    }
}
