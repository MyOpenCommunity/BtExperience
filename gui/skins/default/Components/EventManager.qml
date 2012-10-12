import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

import "../js/Stack.js" as Stack
import "../js/ScreenSaver.js" as ScreenSaver


Item {
    id: eventManager

    property int alarms: privateProps.antintrusionModel === undefined ? 0 : loader.item.alarmsModel.count
    property bool isAntintrusionInserted: privateProps.antintrusionModel === undefined ? false : privateProps.antintrusionModel.status
    property bool autoOpen: privateProps.vctModel === undefined ? false : privateProps.vctModel.autoOpen
    property bool handsFree: privateProps.vctModel === undefined ? false : privateProps.vctModel.handsFree
    property bool vdeMute: privateProps.vctModel === undefined ? false : privateProps.vctModel.ringExclusion
    property int messages: privateProps.messagesModel === undefined ? 0 : privateProps.messagesModel.unreadMessages
    property int dangers: privateProps.dangersModel === undefined ? 0 : privateProps.dangersModel.openedDevices
    property bool scenarioRecording: privateProps.recordingModel === undefined ? false : privateProps.recordingModel.recording
    property bool playing: global.audioPlayer === undefined ? false : global.audioPlayer.playing

    property int clocks: 0 // TODO link to C++ model!
    property bool mute: false // TODO link to C++ model and check if property exists!

    anchors.fill: parent

    ScreenSaver {
        id: screensaver
        z: parent.z
    }

    // this is needed to manage the activation of the screensaver;
    // this function is used to send an event to reactivate the screensaver
    // even in those cases where an interaction with the user is not performed;
    // see comments in ScreenSaver.js file for more info on this subject
    function screensaverEvent() {
        // the updateLast call is needed to compute elapsed time correctly
        // see comments in ScreenSaver.js file for more info on this subject
        ScreenSaver.updateLast()
    }

    Component {
        id: callPopup
        ControlCall {
            // it is useful to call enableScreensaver here because attaching
            // it to callEnded signal may lead to unpredictable behavior in
            // some cases (see comment inside callEnding function in ControlCall.qml)
            onClosePopup: {
                enableScreensaver()
                global.audioState.disableState(AudioState.VdeRingtone)
                global.audioState.disableState(AudioState.ScsIntercomCall)
                global.audioState.disableState(AudioState.IpIntercomCall)
                global.audioState.disableState(AudioState.Mute)
            }
        }
    }

    function enableScreensaver() {
        screensaver.isEnabled = true
    }

    ObjectModel {
        id: listModel
        filters: [
            {objectId: ObjectInterface.IdCCTV},
            {objectId: ObjectInterface.IdIntercom},
            {objectId: ObjectInterface.IdAntintrusionSystem},
            {objectId: ObjectInterface.IdMessages},
            {objectId: ObjectInterface.IdDangers},
            {objectId: ObjectInterface.IdScenarioModulesNotifier}
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
                case ObjectInterface.IdScenarioModulesNotifier:
                    scenarioConnection.target = obj
                    privateProps.recordingModel = obj
                    break
                }
            }
        }
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
            screensaver.stopScreensaver()
            screensaver.isEnabled = false
            Stack.pushPage("VideoCamera.qml", {"camera": vctConnection.target})
        }
        onCallAnswered: {
            if (vctConnection.target.isIpCall)
                global.audioState.enableState(AudioState.IpVideoCall)
            else
                global.audioState.enableState(AudioState.ScsVideoCall)
        }
        onCallEnded: {
            enableScreensaver()
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
            screensaver.stopScreensaver()
            screensaver.isEnabled = false
            Stack.pushPage("IntercomPage.qml", {"callObject": intercomConnection.target})
        }
        onCallAnswered: {
            if (intercomConnection.target.isIpCall)
                global.audioState.enableState(AudioState.IpIntercomCall)
            else
                global.audioState.enableState(AudioState.ScsIntercomCall)
        }
        onCallEnded: {
            enableScreensaver()
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
            var p = privateProps.preparePopupPage()
            // adds antintrusion alarm
            p.addAlarmPopup(alarm.type, alarm.source, alarm.number, alarm.date_time)
        }
    }

    Connections {
        id: stopAndGoConnection
        target: null
        onStopAndGoDeviceChanged: {
            var p = privateProps.preparePopupPage()
            // adds stop&go alarm
            p.addStopAndGoPopup(stopGoDevice)
        }
    }

    Connections {
        id: messagesConnection
        target: null
        onUnreadMessagesChanged: {
            var p = privateProps.preparePopupPage()
            // updates number of unread messages
            p.updateUnreadMessages(messagesConnection.target.unreadMessages)
        }
    }

    Connections {
        id: scenarioConnection
        target: null
        onScenarioActivated: {
            var p = privateProps.preparePopupPage()
            // adds popup for scenario activation
            p.addScenarioActivationPopup(description)
        }
    }

    QtObject {
        id: privateProps

        property variant antintrusionModel: undefined
        property variant messagesModel: undefined
        property variant vctModel: undefined
        property variant dangersModel: undefined
        property variant recordingModel: undefined

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
        function preparePopupPage() {
            // we generate a screensaver "event" every time a popup arrives
            eventManager.screensaverEvent()

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
                privateProps.endActualCall(callPageName)
            }

            // if p doesn't point to Popup page, pushes it
            if (p._pageName !== "PopupPage")
                p = Stack.pushPage("PopupPage.qml")

            // returns pointer to PopupPage
            return p
        }
    }
}
