import QtQuick 1.1


Item {
    id: screensaver

    property variant screensaverComponent
    property bool timeoutActive: true

    anchors.fill: parent

    Connections {
        target: global
        onLastTimePressChanged: {
            // if state is already running skips
            if (screensaver.state === "running")
                return
            // if timeoutActive is false, screensaver must run indefinitely
            if (!timeoutActive) {
                screensaver.state = "running"
                return
            }
            // we are here if we are in default state and timeoutActive is true
            // checks timeout and (eventually) sets state to running
            if (global.lastTimePress > global.guiSettings.timeOutInSeconds)
                screensaver.state = "running"
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
        z: screesaver.z + 1
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
}
