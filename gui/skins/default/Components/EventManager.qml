import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../js/Stack.js" as Stack
import "../js/ScreenSaver.js" as ScreenSaver


Item {
    id: eventManager

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

    function vctIncomingCall(vctObject) {
        console.log("EventManager::vctIncomingCall")
        screensaver.stopScreensaver()
        screensaver.isEnabled = false
        console.log("Opening call page with object: " + vctObject)
        Stack.openPage("VideoCamera.qml", {"camera": vctObject})
    }

    function intercomIncomingCall(obj) {
        screensaver.stopScreensaver()
        screensaver.isEnabled = false
        Stack.currentPage().installPopup(callPopup)
        Stack.currentPage().popupLoader.item.dataObject = obj
        Stack.currentPage().popupLoader.item.state = "ringing"
    }

    Component {
        id: callPopup
        ControlCall {
            // it is useful to call enableScreensaver here because attaching
            // it to callEnded signal may lead to unpredictable behavior in
            // some cases (see comment inside callEnding function in ControlCall.qml)
            onClosePopup: enableScreensaver()
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
            {objectId: ObjectInterface.IdAntintrusionSystem}
        ]
        Component.onCompleted: {
            for (var i = 0; i < listModel.count; ++i) {
                var obj = listModel.getObject(i)
                switch (obj.objectId) {
                case ObjectInterface.IdCCTV:
                    vctConnection.target = obj
                    break
                case ObjectInterface.IdIntercom:
                    intercomConnection.target = obj
                    break
                case ObjectInterface.IdAntintrusionSystem:
                    antintrusionConnection.target = obj
                    break
                }
            }
        }
    }

    Connections {
        id: vctConnection
        target: null
        onIncomingCall: {
            console.log("EventManager::vctIncomingCall")
            screensaver.stopScreensaver()
            screensaver.isEnabled = false
            Stack.openPage("VideoCamera.qml", {"camera": vctConnection.target})
        }
        onCallEnded: enableScreensaver()
    }

    Connections {
        id: intercomConnection
        target: null
        onIncomingCall: {
            screensaver.stopScreensaver()
            screensaver.isEnabled = false
            Stack.currentPage().installPopup(callPopup)
            Stack.currentPage().popupLoader.item.dataObject = intercomConnection.target
            Stack.currentPage().popupLoader.item.state = "ringing"
        }
    }

    Connections {
        id: antintrusionConnection
        target: null
        onNewAlarm: {
            // we generate a screensaver "event" every time an alarm arrives
            eventManager.screensaverEvent()
            Stack.currentPage().showAlarmPopup(alarm.type, alarm.source, alarm.number, alarm.date_time)
        }
    }
}
