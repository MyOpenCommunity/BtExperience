import QtQuick 1.1
import BtExperience 1.0
import "../js/TurnOffMonitor.js" as Script


Item {
    id: control

    property bool timeoutActive: true // if timeout is running or not
    property bool isEnabled: true // if control is enabled or not

    anchors.fill: parent

    function stopControl() {
        control.state = ""
    }

    Connections {
        target: global
        onLastTimePressChanged: manageControlState()
    }

    Connections {
        target: global.hardwareKeys
        onPressed: {
            // turn off monitor on hw key 3 press
            if (index === 3)
                state = "running"
        }
    }

    // manages control logic related to app and user events; it doesn't
    // consider mouse interaction once the control activates
    // mouse interaction while running is managed inside MouseArea because
    // we need some logic to decide about passing the mouse event to items
    // below the control or not
    function manageControlState() {
        // if timeoutActive is false, control must run indefinitely
        if (!timeoutActive) {
            if (control.state === "running")
                return
            control.state = "running"
            return
        }
        // if isEnabled is false, control can never run
        if (!isEnabled) {
            if (control.state === "")
                return
            control.state = ""
            return
        }
        // if running, we have to check if an app generated event has been issued
        if (control.state === "running") {
            if (!Script.elapsed(60)) {
                // timeout is not elapsed due to an app generated event: set state to default
                if (control.state === "")
                    return
                control.state = ""
            }
            // running and internal event timeout elapsed: remains in running state
            return
        }
        // here we are in default state, timeoutActive is true and isEnabled is true
        // checks if timeout is elapsed due to internal or user event and acts accordingly
        if (Script.elapsed(60, global.lastTimePress)) {
            // timeout is elapsed; we set control state to running
            if (control.state === "running")
                return
            control.state = "running"
            return
        }
    }

    // if control is running we must not pass mouse events to objects below
    // the control; on the other hand, while control is in default state
    // it must be "transparent" and pass everything below;
    // this function manages such magic
    // NOTE: accept means NOT passing event to other items
    function acceptMouseEvent() {
        // doesn't accept event if in default state
        if (control.state === "")
            return false
        // if timeoutActive is false doesn't accept event
        if (!timeoutActive)
            return false
        // if isEnabled is false doesn't accept event
        if (!isEnabled)
            return false

        // we are here if we are in running state, control is enabled
        // and timeoutActive is true: accepts event (i.e. event is neutralized)
        return true
    }

    MouseArea {
        anchors.fill: parent
        // please note that inside the condition we make assignments to avoid
        // using a script block; if mouse event is accepted (i.e. neutralized),
        // we return in default state (the control stops due to user interaction)
        onPressed: if (mouse.accepted = acceptMouseEvent()) control.state = ""
        onReleased: if (mouse.accepted = acceptMouseEvent()) control.state = ""
    }

    Loader {
        id: component
        anchors.fill: parent
        z: control.z + 1
    }

    states: [
        State {
            name: "running"
            PropertyChanges {
                target: component
                sourceComponent: darkRect
            }
        }
    ]

    onStateChanged: {
        if (state === "running") {
            global.monitorOff = true
            global.audioState.enableState(AudioState.Screensaver)
        }
        else {
            global.monitorOff = false
            global.audioState.disableState(AudioState.Screensaver)
        }
    }

    Component {
        id: darkRect
        Rectangle {
            color: "black"
            width: 1024
            height: 600
        }
    }
}
