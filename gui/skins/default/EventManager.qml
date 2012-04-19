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
    ObjectModel {
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
    // TODO
}
