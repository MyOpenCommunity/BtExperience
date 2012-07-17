import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.VideoDoorEntry 1.0 // some controls are VDE specific
import "js/Stack.js" as Stack


Page {
    id: videoCamera

    property QtObject camera: null

    property alias title: controlVideo.label

    source: "images/videocitofonia.jpg"
    showSystemsButton: true

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
        onLeftClicked: videoCamera.camera.answerCall()
        onRightClicked: privateProps.endCall()
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
        onPlusClicked: console.log("onVolume+ to be implemented")
        onMinusClicked: console.log("onVolume- to be implemented")
        onMuteClicked: console.log("onMute to be implemented")
    }

    ControlPullDownVideo {
        // this is placed after controlVolume to be on top of it when the
        // menu pulls down
        id: controlPullDownVideo

        camera: videoCamera.camera
        anchors {
            // anchors are set considering that ControlPullDownVideo contains
            // a loader, so its dimensions are not well defined
            left: controlCallManager.left
            top: controlVideo.top
        }
    }

    QtObject {
        id: privateProps

        function endCall(callback) {
            if (callback)
                camera.callEnded.disconnect(Stack.popPage)
            camera.endCall()
            if (callback)
                callback()
        }
    }

    // the following functions overwrite the ones in Page to terminate the
    // call when home and back buttons are clicked: this is the reason they
    // are "public"
    function homeButtonClicked() {
        privateProps.endCall(Stack.backToHome)
    }

    function backButtonClicked() {
        privateProps.endCall(Stack.popPage)
    }

    Component.onCompleted: {
        camera.callEnded.connect(Stack.popPage)
        toolbar.z = 1
        navigationBar.z = 1
    }
}
