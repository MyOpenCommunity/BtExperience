import QtQuick 1.1
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import Components.VideoDoorEntry 1.0 // some controls are VDE specific
import "js/Stack.js" as Stack


Page {
    id: control

    property QtObject camera: null

    property alias title: controlVideo.label

    source: "images/videocitofonia.jpg"
    showSystemsButton: true

    Connections {
        id: connDataObject
        target: control.camera
        onMuteChanged: {
            if (connDataObject.target.mute)
                global.audioState.enableState(AudioState.Mute)
            else
                global.audioState.disableState(AudioState.Mute)
        }
        onVolumeChanged: {
            global.audioState.setVolume(connDataObject.target.volume)
        }
    }

    ControlCallManager {
        id: controlCallManager

        // a videocamera component "appears" when a call is ringing: we may
        // assume a ringing state; state must be updated during the call
        // (callAnswered, callEnded, ...)
        state: "answerReject"
        anchors {
            right: parent.right
            rightMargin: 28
            bottom: parent.bottom
            bottomMargin: 22
        }
        onLeftClicked: {
            state = "terminate"
            control.camera.answerCall()
        }
        onRightClicked: control.endCall()
    }

    ControlVideo {
        // assumes video stream is rendered on top of application in the right
        // place
        id: controlVideo

        label: qsTr("CAMERA EXTERNAL PLACE #1")
        anchors {
            right: controlCallManager.left
            rightMargin: 16
            bottom: parent.bottom
            bottomMargin: 22
        }
        onNextClicked: camera.nextCamera()
    }

    ControlTextCommand {
        id: controlStairLight

        text: qsTr("stairlight")
        anchors {
            right: parent.right
            rightMargin: 28
            bottom: controlCallManager.top
            bottomMargin: 4
        }
        onPressed: camera.stairLightActivate()
        onReleased: camera.stairLightRelease()
    }

    ControlTextCommand {
        id: controlLock

        text: qsTr("door lock")
        anchors {
            right: parent.right
            rightMargin: 28
            bottom: controlStairLight.top
            bottomMargin: 4
        }
        onPressed: camera.openLock()
        onReleased: camera.releaseLock()
    }

    ControlSliderMute {
        id: controlVolume

        property variant dataObject: control.camera
        description: qsTr("volume")
        percentage: 50
        anchors {
            // anchors are set considering that ControlPullDownVideo contains
            // a loader, so its dimensions are not well defined; topMargin
            // assumes ControlPullDownVideo height is 35
            right: parent.right
            rightMargin: 28
            top: controlVideo.top
            topMargin: 35 + 10
        }
        onPlusClicked: if (dataObject) dataObject.volume += 5
        onMinusClicked: if (dataObject) dataObject.volume -= 5
        onMuteClicked: if (dataObject) dataObject.mute = !dataObject.mute
    }

    ControlPullDownVideo {
        // this is placed after controlVolume to be on top of it when the
        // menu pulls down
        id: controlPullDownVideo

        camera: control.camera
        anchors {
            // anchors are set considering that ControlPullDownVideo contains
            // a loader, so its dimensions are not well defined
            left: controlCallManager.left
            top: controlVideo.top
        }
    }

    function endCall(callback, page) {
        if (callback)
            camera.callEnded.disconnect(Stack.popPage)
        camera.endCall()
        if (callback) {
            if (page)
                callback(page)
            else
                callback()
        }
    }

    // the following functions overwrite the ones in Page to terminate the
    // call when home and back buttons are clicked: this is the reason they
    // are "public"
    function homeButtonClicked() {
        control.endCall(Stack.backToHome)
    }

    function backButtonClicked() {
        if (control.camera.autoSwitch)
            control.endCall(Stack.goToPage, "VideoDoorEntry.qml")
        else
            control.endCall(Stack.popPage)
    }

    Component.onCompleted: {
        camera.callEnded.connect(Stack.popPage)
        toolbar.z = 1
        navigationBar.z = 1
    }
}
