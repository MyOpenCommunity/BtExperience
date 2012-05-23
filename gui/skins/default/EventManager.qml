import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "js/Stack.js" as Stack


Item {
    id: eventManager
    anchors.fill: parent

    /************************************************************************
      *
      * CALIBRATION
      *
      **********************************************************************/
    // TODO

    /************************************************************************
      *
      * ANTINTRUSION ALARMS
      *
      **********************************************************************/
    FilterListModel {
        id: antintrusionModel
        categories: [ObjectInterface.Antintrusion]
    }

    QtObject {
        id: privateProps
        property variant model: antintrusionModel.getObject(0)
    }

    Connections {
        target: privateProps.model
        onNewAlarm: {
            Stack.currentPage().showAlarmPopup(alarm.type, alarm.zone, alarm.date_time)
        }
    }

    /************************************************************************
      *
      * SCREENSAVER
      *
      **********************************************************************/
    ScreenSaver {
        id: screensaver
        z: parent.z
    }

    /************************************************************************
      *
      * CALLS
      *
      **********************************************************************/
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

    // TODO: maybe it's possible to avoid to have a second FilterListModel in this
    // file?
    FilterListModel {
        id: vctModel
        filters: [
            {objectId: ObjectInterface.IdCCTV},
            {objectId: ObjectInterface.IdIntercom}
        ]
        Component.onCompleted: {
            for (var i = 0; i < vctModel.size; ++i) {
                var obj = vctModel.getObject(i)
                switch (obj.objectId) {
                case ObjectInterface.IdCCTV:
                    obj.incomingCall.connect(function() { return vctIncomingCall(obj); })
                    obj.callEnded.connect(enableScreensaver)
                    break
                case ObjectInterface.IdIntercom:
                    obj.incomingCall.connect(function() { return intercomIncomingCall(obj); })
                    break
                case ObjectInterface.Antintrusion:
                    // .......TODO
                    break
                }
            }
        }
    }
}
