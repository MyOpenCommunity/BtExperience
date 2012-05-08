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
        // TODO load the right screensaver depending on configuration
        screensaverComponent: bouncingLogo
        z: parent.z
    }

    Component {
        id: bouncingLogo
        ScreenSaverBouncingImage {}
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

    function enableScreensaver() {
        screensaver.isEnabled = true
    }

    // TODO: maybe it's possible to avoid to have a second FilterListModel in this
    // file?
    FilterListModel {
        id: vctModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
        Component.onCompleted: {
            var obj = vctModel.getObject(0)
            obj.incomingCall.connect(function() { return vctIncomingCall(obj); })
            obj.callEnded.connect(enableScreensaver)
        }
    }
}
