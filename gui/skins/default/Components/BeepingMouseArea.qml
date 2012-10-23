import QtQuick 1.1
import BtExperience 1.0

MouseArea {
    onPressed: {
        if (global.guiSettings.beep)
            global.beep()
    }
    onClicked: global.debugTiming.logTiming("Clicked on icon")
}
