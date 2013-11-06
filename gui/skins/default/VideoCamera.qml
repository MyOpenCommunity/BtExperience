/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import Components.VideoDoorEntry 1.0 // some controls are VDE specific
import "js/Stack.js" as Stack


/**
  * \ingroup VideoDoorEntry
  *
  * \brief Page managing a video call.
  *
  * This page contain all controls needed to manage a video call and the
  * area used by the video grabber to render the video stream. The stream is
  * rendered using the chroma-key technique on the color #010203
  */
Page {
    id: control

    /** type:QtObject The camera the page interacts with. */
    property QtObject camera: null

    property alias title: controlVideo.label

    source: "images/background/video_door_entry.jpg"
    showSystemsButton: true
    _pageName: "VideoCamera"

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
            global.audioState.setVolume(AudioState.VdeCallVolume, connDataObject.target.volume)
        }
    }

    Connections {
        target: toolbar
        onToolbarNavigationClicked: {
            privateProps.exitPath = 2
            controlVideo.color = "black"
            camera.endCall()
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
        onLeftClicked: control.camera.answerCall()
        onRightClicked: control.endCall()

        Connections {
            target: control.camera
            onCallAnswered: {
                controlCallManager.state = control.camera.teleloop ? "teleloop" : "terminate"
                controlCallManager.updateVolumeState()
            }
            onMuteChanged: controlCallManager.updateVolumeState()
        }

        function updateVolumeState() {
            if (state == "terminate") {
                controlVolume.muteEnabled = true
                if (control.camera.mute)
                    controlVolume.state = "mute"
                else
                    controlVolume.state = ""
            } else {
                controlVolume.muteEnabled = false
                controlVolume.state = "mute"
            }
        }
    }

    ControlVideo {
        // assumes video stream is rendered on top of application in the right
        // place
        id: controlVideo

        moveArrowsVisible: camera.movingCamera
        label: camera.talker
        anchors {
            right: controlCallManager.left
            rightMargin: 16
            bottom: parent.bottom
            bottomMargin: 22
        }
        onNextClicked: camera.nextCamera()
        onLeftArrowPressed: camera.moveLeftPress()
        onLeftArrowReleased: camera.moveLeftRelease()
        onRightArrowPressed: camera.moveRightPress()
        onRightArrowReleased: camera.moveRightRelease()
        onUpArrowPressed: camera.moveUpPress()
        onUpArrowReleased: camera.moveUpRelease()
        onDownArrowPressed: camera.moveDownPress()
        onDownArrowReleased: camera.moveDownRelease()
        Timer {
            id: redTimer
            interval: 1500
            onTriggered: controlVideo.color = "#010203"
        }
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
        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }
    }

    ControlImageCommand {
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
        Behavior on opacity {
            NumberAnimation { duration: 400 }
        }
    }

    ControlSliderMute {
        id: controlVolume

        property variant dataObject: control.camera
        description: qsTr("volume")
        percentage: dataObject.volume
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
        onMinusClicked: {
            if (!dataObject)
                return
            if (dataObject.volume <= 5)
                dataObject.mute = true
            else
                dataObject.volume -= 5
        }
        onMuteClicked: if (dataObject) dataObject.mute = !dataObject.mute
        onSliderClicked: dataObject.volume = Math.round(desiredPercentage / 5) * 5
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
        onOpened: {
            controlStairLight.opacity = 0
            controlLock.opacity = 0
        }

        onClosed: {
            controlStairLight.opacity = 1
            controlLock.opacity = 1
        }
    }

    function endCall() {
        privateProps.exitPath = 4
        controlVideo.color = "black"
        camera.endCall()
    }

    // the following functions overwrite the ones in Page to terminate the
    // call when home and back buttons are clicked: this is the reason they
    // are "public"
    function homeButtonClicked() {
        privateProps.exitPath = 3
        controlVideo.color = "black"
        camera.endCall()
    }

    function backButtonClicked() {
        privateProps.exitPath = 1
        controlVideo.color = "black"
        camera.endCall()
    }

    function callEndedCallback() {
        // depending on how we end the call we have to do different things
        if (privateProps.exitPath === 1) {
            // in case we exited the call through the back button, we have to
            // check if it was an autoswitch call or not; in the former case
            // returns back to where we were, in the latter one we go to the
            // VideoDoorEntry page
            privateProps.exitPath = 0
            if (control.camera.autoSwitch) {
                Stack.popPage()
            }
            else {
                Stack.goToPage("VideoDoorEntry.qml")
            }
            return
        }

        if (privateProps.exitPath === 2) {
            // in case we exited the call through the play button on the toolbar
            // we do nothing: navigation is already managed in the toolbar
            privateProps.exitPath = 0
            return
        }

        if (privateProps.exitPath === 3) {
            // in case we exited the call through the home button, we obviously
            // have to go to the home page
            privateProps.exitPath = 0
            Stack.backToHome()
            return
        }

        // in all other cases we come back to where we went from
        privateProps.exitPath = 0
        Stack.popPage()
    }

    QtObject {
        id: privateProps

        // we may exit from a call through different paths
        // this value tells us what was the followed path, so we can take
        // proper further action
        //
        // values:
        //      0 - timeout
        //      1 - click on back button
        //      2 - click on play button
        //      3 - click on home button
        //      4 - click on terminate button
        property int exitPath: 0
    }

    Connections {
        target: camera
        onCallEnded: control.callEndedCallback()
    }

    Connections {
        target: global.hardwareKeys
        onPressed: {
            if (!control.camera || !control.camera.callInProgress)
                return

            // answer call on hw key 0 press, open lock on hw key 1
            if (index === 0) {
                if (control.camera.callActive)
                    control.camera.endCall()
                else
                    control.camera.answerCall()
            }
        }
    }

    Component.onCompleted: {
        redTimer.running = true
        toolbar.z = 1
        navigationBar.z = 1
        control.camera.volume = global.audioState.getVolume(AudioState.VdeCallVolume)
        controlCallManager.updateVolumeState()
    }
}
