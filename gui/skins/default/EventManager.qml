import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "js/Stack.js" as Stack


Item {
    id: eventManager
    anchors.fill: parent

    // TODO CALIBRATION

    ScreenSaver {
        id: screensaver
        z: parent.z
    }

    function vctIncomingCall(vctObject) {
        console.log("EventManager::vctIncomingCall")
        screensaver.stopScreensaver()
        screensaver.isEnabled = false
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

    FilterListModel {
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
                    obj.incomingCall.connect(function() { return vctIncomingCall(obj); })
                    obj.callEnded.connect(enableScreensaver)
                    break
                case ObjectInterface.IdIntercom:
                    obj.incomingCall.connect(function() { return intercomIncomingCall(obj); })
                    break
                case ObjectInterface.IdAntintrusionSystem:
                    antintrusionConnection.target = obj
                    break
                }
            }
        }
    }

    Connections {
        id: antintrusionConnection
        target: null
        onNewAlarm: {
            Stack.currentPage().showAlarmPopup(alarm.type, alarm.source, alarm.date_time)
        }
    }
}
