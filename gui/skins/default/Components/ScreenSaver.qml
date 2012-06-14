import QtQuick 1.1
import BtExperience 1.0
import "../js/ScreenSaver.js" as Script


Item {
    id: screensaver

    property variant screensaverComponent
    property bool timeoutActive: true
    property bool isEnabled: true

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

    function manageScreensaverState() {
        // if timeoutActive is false, screensaver must run indefinitely
        if (!timeoutActive) {
            if (screensaver.state === "running")
                return
            screensaver.state = "running"
            return
        }
        // timeoutActive is true; we check if timeout is elapsed and set the
        // screensaver accordingly
        if (Script.elapsed(global.lastTimePress, global.guiSettings.timeOutInSeconds) && isEnabled) {
            // timeout is elapsed; we set screensaver state to running
            if (screensaver.state === "running")
                return
            screensaver.state = "running"
        }
        else {
            // timeout is not elapsed; we set screensaver state to default (not running)
            if (screensaver.state === "")
                return
            screensaver.state = ""
        }
    }

    function selectScreensaver() {
        switch (global.guiSettings.screensaverType)
        {
        case GuiSettings.Rectangles:
            return flashyRectangles
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

    function acceptMouseEvent() {
        // doesn't accept event if in default state
        if (screensaver.state === "")
            return false
        // if timeoutActive is false doesn't accept event
        if (!timeoutActive)
            return false
        // we are here if we are in running state and timeoutActive is true
        // accepts event
        return true
    }

    MouseArea {
        anchors.fill: parent
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

    Component {
        id: bouncingLogo
        ScreenSaverBouncingImage {}
    }

    Component {
        id: flashyRectangles
        ScreenSaverRectangles {}
    }
}
