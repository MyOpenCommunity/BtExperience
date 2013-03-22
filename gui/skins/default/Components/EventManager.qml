import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

import "../js/Stack.js" as Stack
import "../js/EventManager.js" as Script
import "../js/navigation.js" as Navigation


Item {
    id: eventManager

    property int alarms: privateProps.antintrusionModel === undefined ? 0 : loader.item.alarmsModel.count
    property bool antintrusionPresent: privateProps.antintrusionModel !== undefined
    property bool isAntintrusionInserted: privateProps.antintrusionModel === undefined ? false : privateProps.antintrusionModel.status
    property bool autoOpen: privateProps.vctModel === undefined ? false : privateProps.vctModel.autoOpen
    property bool handsFree: privateProps.vctModel === undefined ? false : privateProps.vctModel.handsFree
    property bool vdeMute: privateProps.vctModel === undefined ? false : privateProps.vctModel.ringExclusion
    property bool vdeTeleloop: privateProps.vctModel === undefined ? false : privateProps.vctModel.associatedTeleloopId
    property int messages: privateProps.messagesModel === undefined ? 0 : privateProps.messagesModel.unreadMessages
    property int dangers: privateProps.dangersModel === undefined ? 0 : privateProps.dangersModel.openedDevices
    property bool scenarioRecording: privateProps.recordingModel === undefined ? false : privateProps.recordingModel.recording
    property bool playing: global.audioVideoPlayer === undefined ? false : !global.audioVideoPlayer.stopped
    property bool mute: global.audioState === null ? false : (global.audioState.state === AudioState.LocalPlaybackMute)
    property int clocks: privateProps.clocksModel === null ? 0 : privateProps.clocksModel.clocks

    property variant scenarioRecorder: privateProps.recordingModel === undefined ? undefined : privateProps.recordingModel.recorder
    property bool notificationsEnabled: true
    property bool clockRinging: privateProps.clocksModel === null ?
                                    false :
                                    (privateProps.clocksModel.alarmActive || privateProps.clocksModel.beepAlarmActive)

    signal changePageDone

    anchors.fill: parent

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
            {objectId: ObjectInterface.IdAlarmClockNotifier},
            {objectId: ObjectInterface.IdPlatformSettings}
        ]
        Component.onCompleted: {
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
                case ObjectInterface.IdPlatformSettings:
                    systemTimeChanged.target = obj
                    break
                }
            }
        }
    }

    ObjectModel {
        id: energiesFamilies
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
    }

    Timer {
        id: monthlyReportTimer

        property bool notify: false
        property int goals: 0 // lines with a consumption goal enabled

        repeat: true
        interval: 10 * 60 * 1000 // first shot in 10 minutes
        running: true
        onTriggered: {
            updateTimer()
            if (goals === 0)
                return
            if (!global.guiSettings.energyPopup)
                return
            if (!notify)
                return
            privateProps.addNotification({"type": Script.MONTHLY_REPORT_ARRIVING})
        }

        // function to update triggering interval and notify property
        //
        // the interval property is an int, so it can handle values only in the
        // range [-2147483648, 2147483647]; a month can have more than 2147483647ms
        // so we cannot set the interval to the next month 1st day, but we have to
        // update the interval every day
        function updateTimer() {
            // stops the timer
            monthlyReportTimer.stop()
            // computes if it is first month day
            var n = new Date()
            var dayInMonth = n.getDate()
            if (dayInMonth === 1)
                notify = true // it is 1st, so notify
            // computes next day 1s after midnight
            var n2 = new Date(n.getFullYear(), n.getMonth(), dayInMonth + 1, 0, 0, 1, 0)
            // updates interval to trigger tomorrow at midnight
            monthlyReportTimer.interval = n2.getTime() - n.getTime()
            // restarts timer
            monthlyReportTimer.start()
        }
    }

    Connections {
        id: systemTimeChanged
        target: null
        onSystemTimeChanged: monthlyReportTimer.updateTimer()
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
        onIncomingCall: privateProps.addNotification({"type": Script.VCT_INCOMING_CALL})
        onCallAnswered: {
            if (vctConnection.target.teleloop)
                global.audioState.enableState(AudioState.Teleloop)
            if (vctConnection.target.isIpCall)
                global.audioState.enableState(AudioState.IpVideoCall)
            else
                global.audioState.enableState(AudioState.ScsVideoCall)
        }
        onCallEnded: {
            global.audioState.disableState(AudioState.VdeRingtone)
            global.audioState.disableState(AudioState.ScsVideoCall)
            global.audioState.disableState(AudioState.IpVideoCall)
            global.audioState.disableState(AudioState.Mute)
            global.audioState.disableState(AudioState.Teleloop)
        }
        onRingtoneReceived: {
            if (!notificationsEnabled) {
                console.log("Notifications disabled, ignore VDE ringtone")
                return
            }

            // VdeRingtone state should always be enabled to stop multimedia playback during call
            if (!vctConnection.target.ringExclusion)
                global.ringtoneManager.playRingtoneAndKeepState(global.ringtoneManager.ringtoneFromType(vctConnection.target.ringtone), AudioState.VdeRingtone)
            else
                global.audioState.enableState(AudioState.VdeRingtone)
        }
        onCallInProgressChanged: {
            if (vctConnection.target.callInProgress) {
                global.screenState.enableState(ScreenState.ForcedNormal)
            } else {
                global.screenState.enableState(ScreenState.Normal)
                global.screenState.disableState(ScreenState.ForcedNormal)
            }
        }
    }

    Connections {
        id: intercomConnection
        target: null
        onIncomingCall: privateProps.addNotification({"type": Script.INTERCOM_INCOMING_CALL})
        onCallAnswered: {
            global.audioState.disableState(AudioState.SenderPagerCall)
            global.audioState.disableState(AudioState.ReceiverPagerCall)
            if (intercomConnection.target.teleloop)
                global.audioState.enableState(AudioState.Teleloop)
            if (intercomConnection.target.isIpCall)
                global.audioState.enableState(AudioState.IpIntercomCall)
            else
                global.audioState.enableState(AudioState.ScsIntercomCall)
        }
        onCallEnded: {
            global.audioState.disableState(AudioState.SenderPagerCall)
            global.audioState.disableState(AudioState.ReceiverPagerCall)
            global.audioState.disableState(AudioState.VdeRingtone)
            global.audioState.disableState(AudioState.ScsIntercomCall)
            global.audioState.disableState(AudioState.IpIntercomCall)
            global.audioState.disableState(AudioState.Mute)
            global.audioState.disableState(AudioState.Teleloop)
        }
        onRingtoneReceived: {
            if (!notificationsEnabled) {
                console.log("Notifications disabled, ignore intercom ringtone")
                return
            }

            // VdeRingtone state should always be enabled to stop multimedia playback during call
            if (!intercomConnection.target.getRingExclusion())
                global.ringtoneManager.playRingtoneAndKeepState(global.ringtoneManager.ringtoneFromType(intercomConnection.target.ringtone), AudioState.VdeRingtone)
            else
                global.audioState.enableState(AudioState.VdeRingtone)
        }
        onFloorRingtoneReceived: {
            if (!notificationsEnabled) {
                console.log("Notifications disabled, ignore floor call ringtone")
                return
            }

            if (!intercomConnection.target.getRingExclusion())
                global.ringtoneManager.playRingtone(global.ringtoneManager.ringtoneFromType(intercomConnection.target.ringtone), AudioState.FloorCall)
        }
        onMicrophoneOnRequested: global.audioState.enableState(AudioState.SenderPagerCall)
        onSpeakersOnRequested: global.audioState.enableState(AudioState.ReceiverPagerCall)
        onCallInProgressChanged: {
            if (intercomConnection.target.callInProgress) {
                global.screenState.enableState(ScreenState.ForcedNormal)
            } else {
                global.screenState.enableState(ScreenState.Normal)
                global.screenState.disableState(ScreenState.ForcedNormal)
            }
        }
    }

    Connections {
        id: antintrusionConnection
        target: null
        onNewAlarm: privateProps.addNotification({"type": Script.ALARM_ARRIVING, "data": alarm})
    }

    Connections {
        id: stopAndGoConnection
        target: null
        onStopAndGoDeviceChanged: privateProps.addNotification({"type": Script.STOP_GO_DEVICE_CHANGING, "data": stopGoDevice})
    }

    Connections {
        id: energiesConnection
        target: null
        onThresholdChanged: privateProps.addNotification({"type": Script.THRESHOLD_EXCEEDING, "data": energyDevice})
        onGoalReached: privateProps.addNotification({"type": Script.GOAL_REACHING, "data": energyDevice})
        onGoalsEnabledChanged: monthlyReportTimer.goals = goals
    }

    Connections {
        id: messagesConnection
        target: null
        onNewUnreadMessages: privateProps.addNotification({"type": Script.UNREAD_MESSAGES_UPDATING})
    }

    function resendAlarmStarted() {
        privateProps.clocksModel.reemitAlarmStarted()
    }

    Connections {
        id: clocksConnection
        target: null
        onRingAlarmClock: {
            if (!notificationsEnabled) {
                console.log("Notifications disabled, ignore alarm clock")
                return
            }

            global.ringtoneManager.playRingtoneAndKeepState(global.extraPath + "10/alarm.wav", AudioState.Ringtone)
        }
        onAlarmStarted: privateProps.addNotification({"type": Script.ALARM_CLOCK_TRIGGERING, "data": alarmClock})
        onAlarmActiveChanged: {
            if (clocksConnection.target.alarmActive)
                global.screenState.enableState(ScreenState.ForcedNormal)
            else
                global.screenState.disableState(ScreenState.ForcedNormal)
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
        onCommandSent: privateProps.addNotification({"type": Script.SCENARIO_ACTIVATION, "data": description})
        onScenarioModuleChanged: {
            if (scenario.status === ScenarioModule.Editing)
                Stack.backToHome()
        }
        onScenarioProgrammingStopped: Stack.goToPage("Settings.qml", {navigationTarget: Navigation.SCENARIO, navigationData: scenario})
    }

    Connections {
        target: global.hardwareKeys
        onPressed: {
            // call default external point on hardware key 2, turn off screen on hardware key 3
            if (index === 1 && vctConnection.target) {
                vctConnection.target.openLock()
            } else if (index === 2 && global.defaultExternalPlace) {
                if (cctvModel.count === 0)
                    return
                var camera = cctvModel.getObject(0)
                if (camera.callInProgress)
                    camera.nextCamera()
                else
                    camera.cameraOn(global.defaultExternalPlace)
            } else if (index == 3) {
                switch (global.screenState.state) {
                case ScreenState.ScreenOff:
                case ScreenState.Screensaver:
                {
                    global.screenState.simulateClick()
                    break;
                }
                case ScreenState.Normal:
                case ScreenState.Freeze:
                case ScreenState.PasswordCheck:
                {
                    // go to screen-off state
                    global.screenState.disableState(ScreenState.Normal);
                    global.screenState.disableState(ScreenState.Freeze);
                    global.screenState.disableState(ScreenState.PasswordCheck);
                    break;
                }
                case ScreenState.ForcedNormal:
                case ScreenState.Calibration:
                {
                    // Ignore button press
                    break;
                }
                }
            }
        }
        onReleased: {
            if (index === 1 && vctConnection.target) {
                vctConnection.target.releaseLock()
            }
        }
    }

    Connections {
        target: global.screenState
        onDisplayPasswordCheck: Stack.pushPage("PasswordCheck.qml")
    }

    ObjectModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    onChangePageDone: {
        while (Script.delayedNotifications.length) {
            var notify = Script.delayedNotifications[0]
            Script.delayedNotifications.shift()

            privateProps.dispatchNotification(notify)
        }
    }

    QtObject {
        id: privateProps

        property variant antintrusionModel: undefined
        property variant messagesModel: undefined
        property variant vctModel: undefined
        property variant dangersModel: undefined
        property variant recordingModel: undefined
        property variant clocksModel: undefined

        function stopVideoPlayer() {
            if (Stack.currentPage()._pageName === "VideoPlayer")
                Stack.popPage()
        }

        function addNotification(notify) {
            if (!notificationsEnabled) {
                console.log("Notification disabled, type: " + notify["type"])
                return
            }
            if (Stack.isPageChanging(changePageDone) || global.screenState.state === ScreenState.Calibration)
                Script.delayedNotifications.push(notify)
            else
                dispatchNotification(notify)
        }

        function dispatchNotification(notify) {
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
            if (p._pageName !== "PopupPage") {
                if (checkVideoPage()) {
                    p = Stack.pushPageBelow("PopupPage.qml")
                    // See vctIncomingCall()
                    Stack.currentPage().player.terminate()
                    Stack.popPage()
                }
                else
                    p = Stack.pushPage("PopupPage.qml")
            }

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

        // checks if the password page is on top; in this case a vct call must be
        // placed below it
        function checkPasswordPage() {
            var p = Stack.currentPage()

            if (p._pageName === "PasswordCheck")
                return true

            return false
        }

        function checkVideoPage() {
            return Stack.currentPage()._pageName === "VideoPlayer"
        }

        function monthlyReportArriving() {
            var p = privateProps.preparePopupPage(false)
            // adds monthly report notification
            p.addMonthlyReportNotification()
        }

        function vctIncomingCall() {
            if (checkCallInProgress("VideoCamera"))
                return
            global.screenState.enableState(ScreenState.ForcedNormal)
            if (checkPasswordPage()) {
                Stack.pushPageBelow("VideoCamera.qml", {"camera": vctConnection.target})
            }
            else if (checkVideoPage()) {
                Stack.pushPageBelow("VideoCamera.qml", {"camera": vctConnection.target})

                // In case we receive a call during video reproduction, we need
                // to stop the video. If we only rely on VideoPage to do the
                // cleanup, we incorrectly show the playing icon in the toolbar.
                // The events are the following:
                // 1. Call in: setup video camera page and pop video player
                // 2. Ringtone: pause video player and play ringtone
                // 3. Video camera page shown: player now is paused, so shown in the toolbar
                // 4. Animation finishes: video player resets the internal playlist
                // 5. End call: player resumes (due to audio state machine)
                // 6. Player is stopped.
                // See bug #20428
                Stack.currentPage().player.terminate()
                Stack.popPage()
            }
            else
                Stack.pushPage("VideoCamera.qml", {"camera": vctConnection.target})
        }

        function intercomIncomingCall() {
            if (checkCallInProgress("IntercomPage"))
                return
            global.screenState.enableState(ScreenState.ForcedNormal)
            if (checkPasswordPage()) {
                Stack.pushPageBelow("IntercomPage.qml", {"callObject": intercomConnection.target})
            }
            else if (checkVideoPage()) {
                Stack.pushPageBelow("IntercomPage.qml", {"callObject": intercomConnection.target})
                // See vctIncomingCall()
                Stack.currentPage().player.terminate()
                Stack.popPage()
            }
            else
                Stack.pushPage("IntercomPage.qml", {"callObject": intercomConnection.target})
        }

        function alarmArriving(alarm) {
            global.screenState.enableState(ScreenState.Normal)
            var p = privateProps.preparePopupPage(true)
            // adds antintrusion alarm
            p.addAlarmPopup(alarm.type, alarm.source, alarm.number, alarm.date_time)
        }

        function stopAndGoDeviceChanging(stopGoDevice) {
            if (stopGoDevice.status === StopAndGo.Unknown || stopGoDevice.status === StopAndGo.Closed) // not interesting
                return

            global.screenState.enableState(ScreenState.Normal)
            var p = privateProps.preparePopupPage(false)
            // adds stop&go alarm
            p.addStopAndGoPopup(stopGoDevice)
        }

        function thresholdExceeding(energyDevice) {
            var s = global.screenState.state
            global.screenState.enableState(ScreenState.Normal)
            // rings the bell
            if (global.guiSettings.energyThresholdBeep) {
                if (energyDevice.thresholdLevel === 0)
                    global.ringtoneManager.playRingtone(global.extraPath + "10/drin.wav", AudioState.Ringtone)
                else if (energyDevice.thresholdLevel === 1)
                    global.ringtoneManager.playRingtone(global.extraPath + "10/drin2.wav", AudioState.Ringtone)
                else if (energyDevice.thresholdLevel === 2)
                    global.ringtoneManager.playRingtone(global.extraPath + "10/drin3.wav", AudioState.Ringtone)
            }
            if (s < ScreenState.Normal) {
                // navigates to energy data detail page; we don't have a way to
                // compute the right family for our energyData object, so let's
                // take the first electricity family in the hypothesis there is
                // only one of them
                for (var i = 0; i < energiesFamilies.count; ++i) {
                    var f = energiesFamilies.getObject(i)
                    if (f.objectKey == EnergyFamily.Electricity)
                        Stack.pushPage("EnergyDataDetail.qml", {"family": f})
                }
            }
        }

        function goalReaching(energyDevice) {
            var s = global.screenState.state
            global.screenState.enableState(ScreenState.Normal)
            // rings the bell
            global.ringtoneManager.playRingtone(global.extraPath + "10/drin2.wav", AudioState.Ringtone)
            // opens popup only if we are below normal screen state
            if (s < ScreenState.Normal) {
                var p = privateProps.preparePopupPage(false)
                // adds goal alarm
                p.addGoalReachedPopup(energyDevice)
            }
        }

        function unreadMessagesUpdate() {
            global.screenState.enableState(ScreenState.Normal)
            var p = privateProps.preparePopupPage(false)
            // updates number of unread messages
            p.updateUnreadMessages(messagesConnection.target.unreadMessages)
        }

        function scenarioActivation(description) {
            global.screenState.enableState(ScreenState.Normal)
            var p = privateProps.preparePopupPage(false)
            // adds popup for scenario activation
            p.addScenarioActivationPopup(description)
        }

        function alarmClockTriggering(alarmClock) {
            var p = privateProps.preparePopupPage(false)
            // adds alarm clock triggering
            p.addAlarmClockTriggering(alarmClock)
        }
    }
}
