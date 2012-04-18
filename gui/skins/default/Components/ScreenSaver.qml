import QtQuick 1.1



Item {
    id: screensaver

    property variant screensaverComponent
    property int w: global.mainWidth
    property int h: global.mainHeight
    property bool timeoutActive: true

    width: w
    height: h
    z: 20

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
        z: 21
        anchors {
            fill: parent
        }
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
