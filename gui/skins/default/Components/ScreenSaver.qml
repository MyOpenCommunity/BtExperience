import QtQuick 1.1
import BtExperience 1.0
import "../js/ScreenSaver.js" as Script


Item {
    id: screensaver

    property variant screensaverComponent // the screensaver to be run
    property bool timeoutActive: true // if timeout is running or not
    property bool isEnabled: true // if screensaver is enabled or not

    anchors.fill: parent

    function stopScreensaver() {
        screensaver.state = ""
    }

    Component.onCompleted: {
        screensaverComponent = selectScreensaver()
    }

    Connections {
        target: global
        onLastTimePressChanged: manageScreensaverState()
    }

    // manages screensaver logic related to app and user events; it doesn't
    // consider mouse interaction once the screensaver activates
    // mouse interaction while running is managed inside MouseArea because
    // we need some logic to decide about passing the mouse event to items
    // below the screensaver or not
    function manageScreensaverState() {
        // if timeoutActive is false, screensaver must run indefinitely
        if (!timeoutActive) {
            if (screensaver.state === "running")
                return
            screensaver.state = "running"
            return
        }
        // if isEnabled is false, screensaver can never run
        if (!isEnabled) {
            if (screensaver.state === "")
                return
            screensaver.state = ""
            return
        }
        // if running, we have to check if an app generated event has been issued
        if (screensaver.state === "running") {
            if (!Script.elapsed(global.guiSettings.timeOutInSeconds)) {
                // timeout is not elapsed due to an app generated event: set state to default
                if (screensaver.state === "")
                    return
                screensaver.state = ""
            }
            // running and internal event timeout elapsed: remains in running state
            return
        }
        // here we are in default state, timeoutActive is true and isEnabled is true
        // checks if timeout is elapsed due to internal or user event and acts accordingly
        if (Script.elapsed(global.guiSettings.timeOutInSeconds, global.lastTimePress)) {
            // timeout is elapsed; we set screensaver state to running
            if (screensaver.state === "running")
                return
            screensaver.state = "running"
            return
        }
    }

    function selectScreensaver() {
        switch (global.guiSettings.screensaverType)
        {
        case GuiSettings.Rectangles:
            return flashyRectangles
        case GuiSettings.Slideshow:
            return slideshow
        default:
            return bouncingLogo
        }
    }

    Connections {
        target: global.guiSettings
        onScreensaverTypeChanged: {
            screensaverComponent = selectScreensaver()
        }
    }

    // if screensaver is running we must not pass mouse events to objects below
    // the screensaver; on the other hand, while screensaver is in default state
    // it must be "transparent" and pass everything below;
    // this function manages such magic
    // NOTE: accept means NOT passing event to other items
    function acceptMouseEvent() {
        // doesn't accept event if in default state
        if (screensaver.state === "")
            return false
        // if timeoutActive is false doesn't accept event
        if (!timeoutActive)
            return false
        // if isEnabled is false doesn't accept event
        if (!isEnabled)
            return false

        // we are here if we are in running state, screensaver is enabled
        // and timeoutActive is true: accepts event (i.e. event is neutralized)
        return true
    }

    MouseArea {
        anchors.fill: parent
        // please note that inside the condition we make assignments to avoid
        // using a script block; if mouse event is accepted (i.e. neutralized),
        // we return in default state (the screensaver stops due to user interaction)
        onPressed: if (mouse.accepted = acceptMouseEvent()) screensaver.state = ""
        onReleased: if (mouse.accepted = acceptMouseEvent()) screensaver.state = ""
    }

    Loader {
        id: component
        anchors.fill: parent
        z: screensaver.z + 1
    }

    states: [
        State {
            name: "running"
            PropertyChanges {
                target: component
                sourceComponent: screensaverComponent
            }
        }
    ]

    onStateChanged: {
        if (state === "running")
            global.audioState.enableState(AudioState.Screensaver)
        else
            global.audioState.disableState(AudioState.Screensaver)
    }

    Component {
        id: bouncingLogo
        ScreenSaverBouncingImage {}
    }

    Component {
        id: flashyRectangles
        ScreenSaverRectangles {}
    }

    Component {
        id: slideshow
        ScreensaverSlideshow {}
    }
}
