import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import BtExperience 1.0
import "../js/Stack.js" as Stack
import "../js/ScreenSaver.js" as ScreenSaver


Item {
    id: eventManager

    property int alarms: privateProps.alarmsModel === undefined ? 0 : privateProps.alarmsModel.count
    property bool isAntintrusionInserted: privateProps.antintrusionModel === undefined ? false : privateProps.antintrusionModel.status
    property bool autoOpen: privateProps.vctModel === undefined ? false : privateProps.vctModel.autoOpen
    property int messages: privateProps.messagesModel === undefined ? 0 : privateProps.messagesModel.unreadMessages

    property int clocks: 0 // TODO link to C++ model!
    property bool autoAnswer: false // TODO link to C++ model!
    property bool vdeMute: false // TODO link to C++ model!
    property bool scenarioRecording: false // TODO link to C++ model and check if property exists!
    property bool playing: false // TODO link to C++ model and check if property exists!
    property bool mute: false // TODO link to C++ model and check if property exists!
    property int dangers: 0 // TODO link to C++ model and check if property exists!

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
            {objectId: ObjectInterface.IdMessages}
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
                    privateProps.alarmsModel = obj.alarms
                    break
                case ObjectInterface.IdMessages:
                    privateProps.messagesModel = obj
                    break
                }
            }
        }
    }

    Connections {
        id: vctConnection
        target: null
        onIncomingCall: {
            // VdeRingtone state should always be enabled to stop multimedia playback during call
            if (!global.guiSettings.ringExclusion)
                global.ringtoneManager.playRingtoneAndKeepState(global.ringtoneManager.ringtoneFromType(vctConnection.target.ringtone), AudioState.VdeRingtone)
            else
                global.audioState.enableState(AudioState.VdeRingtone)

            console.log("EventManager::vctIncomingCall")
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
    }

    Connections {
        id: intercomConnection
        target: null
        onIncomingCall: {
            // VdeRingtone state should always be enabled to stop multimedia playback during call
            if (!global.guiSettings.ringExclusion)
                global.ringtoneManager.playRingtoneAndKeepState(global.ringtoneManager.ringtoneFromType(intercomConnection.target.ringtone), AudioState.VdeRingtone)
            else
                global.audioState.enableState(AudioState.VdeRingtone)

            screensaver.stopScreensaver()
            screensaver.isEnabled = false
            Stack.currentPage().installPopup(callPopup)
            Stack.currentPage().popupLoader.item.dataObject = intercomConnection.target
            Stack.currentPage().popupLoader.item.state = "callFrom"
        }
        onCallAnswered: {
            if (intercomConnection.target.isIpCall)
                global.audioState.enableState(AudioState.IpIntercomCall)
            else
                global.audioState.enableState(AudioState.ScsIntercomCall)
        }
        onIncomingFloorCall: {
            if (!global.guiSettings.ringExclusion)
                global.ringtoneManager.playRingtone(global.ringtoneManager.ringtoneFromType(intercomConnection.target.ringtone), AudioState.FloorCall)
        }
    }

    Connections {
        id: antintrusionConnection
        target: null
        onNewAlarm: {
            // we generate a screensaver "event" every time an alarm arrives
            eventManager.screensaverEvent()
            var p = privateProps.getPopupPage()
            p.addAlarmPopup(alarm.type, alarm.source, alarm.number, alarm.date_time)
            global.ringtoneManager.playRingtone(global.ringtoneManager.ringtoneFromType(RingtoneManager.Alarm), AudioState.Ringtone)
        }
    }

    QtObject {
        id: privateProps

        property variant alarmsModel: undefined
        property variant antintrusionModel: undefined
        property variant messagesModel: undefined
        property variant vctModel: undefined

        function getPopupPage() {
            // gets current page
            var p = Stack.currentPage()
            // if current page is vct, pops it
            if (p._pageName === "VideoCamera") {
                p.endCall()
                Stack.popPage()
            }
            // if actual page is not popup one, pushes it
            if (p._pageName !== "PopupPage")
                Stack.pushPage("PopupPage.qml")
            // now, popup page is on top of the stack, returns it
            return Stack.currentPage()
        }
    }
}
