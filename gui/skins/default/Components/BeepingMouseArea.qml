/**
  * A beeping mouse area.
  *
  * Component that implements a mouse area that beeps on press.
  * It manages clicks and pressAndHolds independently.
  * If pressAndHoldEnabled flag is not set the held signal is never emitted.
  * In such a case clicking and holding always generate only clicks.
  * If the flag is true, clicks are managed in the usual way, while
  * pressAndHolds generate held signals (and no click is emitted).
  */

import QtQuick 1.1
import BtExperience 1.0


MouseArea {
    property bool pressAndHoldEnabled: false // set this to receive held signals

    signal clicked(variant mouse) // equivalent to MouseArea clicked
    signal held(variant mouse) // equivalent to MouseArea pressAndHold

    onPressed: {
        if (global.guiSettings.beep)
            global.beep()
        privateProps.heldManaged = false // resets internal flag
    }
    onPressAndHold: {
        if (pressAndHoldEnabled) {
            global.debugTiming.logTiming("PressAndHold on icon")
            privateProps.heldManaged = true // held event, must not emit click
            held(mouse)
        }
    }
    onReleased: {
        if (!pressAndHoldEnabled || !privateProps.heldManaged) {
            // if pressAndHold is not enabled emits a click
            // if pressAndHold is enabled emits a click only if held is not managed
            global.debugTiming.logTiming("Clicked on icon")
            clicked(mouse)
        }
    }

    QtObject {
        id: privateProps
        property bool heldManaged // internal flag to know if held was managed or not
    }
}
