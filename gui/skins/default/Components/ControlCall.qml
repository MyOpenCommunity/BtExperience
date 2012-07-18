import QtQuick 1.1
import Components.Text 1.0
import Components.VideoDoorEntry 1.0 // some controls are VDE specific


SvgImage {
    id: control

    property variant dataObject: undefined
    property string where // used only to make calls

    signal closePopup

    source: "../images/common/bg_btn_rispondi_L.svg"

    onDataObjectChanged: {
        if (dataObject !== undefined) {
            dataObject.callAnswered.connect(privateProps.callAnswered)
            dataObject.callEnded.connect(privateProps.callEnding)
            connDataObject.target = dataObject
        }
    }

    Connections {
        id: connDataObject
        target: null
        onMuteChanged: {
            if (connDataObject.target.mute) {
                privateProps.oldState = control.state
                control.state = "muteOn"
            }
            else
                control.state = privateProps.oldState
        }
    }

    ButtonTextImageThreeStates {
        id: buttonCommand

        text: qsTr("push to talk")
        defaultImageBg: "../images/common/btn_cercapersone.svg"
        pressedImageBg: "../images/common/btn_cercapersone_P.svg"
        shadowImage: "../images/common/ombra_btn_cercapersone.svg"
        defaultImage: "../images/common/ico_cercapersone.svg"
        pressedImage: "../images/common/ico_cercapersone_P.svg"
        anchors {
            top: parent.top
            topMargin: 7
            left: parent.left
            leftMargin: 7
        }

        onClicked: {
            if (dataObject !== undefined) {
                dataObject.startCall(where)
                control.state = "callTo"
            }
        }
    }

    ControlTextImageCallManager {
        id: callManager

        place: (dataObject === undefined) ? "" : dataObject.talker
        // this component "appears" when a call is ringing: we may
        // assume a ringing state; state must be updated during the call
        // (callAnswered, callEnded, ...)
        state: "callFrom"
        visible: false
        anchors {
            top: parent.top
            left: parent.left
        }
        onLeftClicked: {
            if (dataObject !== undefined) {
                dataObject.answerCall()
                control.state = "activeCall"
            }
        }
        onRightClicked: {
            if (dataObject !== undefined)
                dataObject.endCall()
            closePopup()
        }
    }

    ControlSliderMute {
        id: controlVolume

        description: qsTr("volume")
        percentage: (dataObject === undefined) ? 0 : dataObject.volume
        visible: false
        anchors {
            top: callManager.bottom
        }
        onPlusClicked: if (dataObject) dataObject.volume += 5
        onMinusClicked: if (dataObject) dataObject.volume -= 5
        onMuteClicked: if (dataObject) dataObject.mute = !dataObject.mute
    }

    states: [
        State {
            name: "callFrom"
            PropertyChanges {
                target: control
                height: callManager.height + controlVolume.height
            }
            PropertyChanges {
                target: buttonCommand
                visible: false
            }
            PropertyChanges {
                target: callManager
                visible: true
                state: "callFrom"
            }
            PropertyChanges {
                target: controlVolume
                visible: true
                state: "mute"
                muteEnabled: false
            }
        },
        State {
            name: "callTo"
            PropertyChanges {
                target: control
                height: callManager.height + controlVolume.height
            }
            PropertyChanges {
                target: buttonCommand
                visible: false
            }
            PropertyChanges {
                target: callManager
                visible: true
                state: "callTo"
            }
            PropertyChanges {
                target: controlVolume
                visible: true
                state: "mute"
                muteEnabled: false
            }
        },
        State {
            name: "noAnswer"
            PropertyChanges {
                target: control
                height: callManager.height + controlVolume.height
            }
            PropertyChanges {
                target: buttonCommand
                visible: false
            }
            PropertyChanges {
                target: callManager
                visible: true
                state: "noAnswer"
            }
            PropertyChanges {
                target: controlVolume
                visible: true
                state: "mute"
                muteEnabled: false
            }
        },
        State {
            name: "activeCall"
            PropertyChanges {
                target: control
                height: callManager.height + controlVolume.height
            }
            PropertyChanges {
                target: buttonCommand
                visible: false
            }
            PropertyChanges {
                target: callManager
                visible: true
                state: "activeCall"
            }
            PropertyChanges {
                target: controlVolume
                visible: true
            }
        },
        State {
            name: "muteOn"
            PropertyChanges {
                target: control
                height: callManager.height + controlVolume.height
            }
            PropertyChanges {
                target: buttonCommand
                visible: false
            }
            PropertyChanges {
                target: callManager
                visible: true
                state: "muteOn"
            }
            PropertyChanges {
                target: controlVolume
                visible: true
                state: "mute"
            }
        }
    ]

    QtObject {
        id: privateProps

        property string oldState: ""

        function callAnswered() {
            control.state = "activeCall"
        }

        function callEnding() {
            control.state = ""
            // it is useful to call closePopup as the very last function: this
            // object is destroyed very shortly after the call returns and doing
            // stuff may lead to random crashes
            closePopup()
        }
    }
}
