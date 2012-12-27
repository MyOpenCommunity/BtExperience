/**
  * A control that implements buttons to manage a call.
  * This is the advanced version of ControlCallManager.
  * A text is present on the upper left part of the control,
  * while an additional image is on the upper right part of it.
  * Unlike the base control (which have only two states), this
  * control has several states:
  *     - callFrom: when an incoming call is ringing
  *     - callTo: when an outgoing call is ringing
  *     - noAnswer: when a call is unanswered
  *     - activeCall: a call is in progress, both talkers can speak
  *     - muteOn: a call is in progress, but only other talker can speak
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


ControlCallManager {
    id: control

    property alias place: caption2.text

    source: "../../images/common/bg_panel_212x100.svg"

    UbuntuLightText {
        id: caption1

        anchors {
            top: parent.top
            topMargin: 7
            left: parent.left
            leftMargin: 11
        }
        font.pixelSize: 12
        color: "white"
        text: qsTr("Incoming call from")
    }

    UbuntuMediumText {
        id: caption2

        anchors {
            top: caption1.bottom
            topMargin: 1
            left: parent.left
            leftMargin: 11
        }
        font.pixelSize: 14
        color: "white"
        text: qsTr("Site #1")
    }

    SvgImage {
        id: callImage
        source: "../../images/common/bg_chiamata_attiva.svg"
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: 7
        }
    }

    states: [
        State {
            name: "callFrom"
            extend: "answerReject"
        },
        State {
            name: "callTo"
            extend: "terminate"
            PropertyChanges { target: caption1; visible: false }
            PropertyChanges { target: caption2; text: qsTr("Call in progress"); anchors.topMargin: 7 }
            PropertyChanges { target: callImage; source: "../../images/common/bg_chiamata_incorso.svg" }
            AnchorChanges { target: caption2; anchors.top: parent.top }
        },
        State {
            name: "noAnswer"
            extend: "terminate"
            PropertyChanges { target: caption1; visible: false }
            PropertyChanges { target: caption2; text: qsTr("No answer"); anchors.topMargin: 7 }
            PropertyChanges { target: callImage; source: "../../images/common/ico_nessuna_risposta.svg" }
            AnchorChanges { target: caption2; anchors.top: parent.top }
        },
        State {
            name: "activeCall"
            extend: "terminate"
            PropertyChanges { target: caption1; visible: false }
            PropertyChanges { target: caption2; text: qsTr("Active call"); anchors.topMargin: 7 }
            PropertyChanges { target: callImage; source: "../../images/common/bg_chiamata_attiva.svg" }
            AnchorChanges { target: caption2; anchors.top: parent.top }
        },
        State {
            name: "muteOn"
            extend: "terminate"
            PropertyChanges { target: caption1; visible: false }
            PropertyChanges { target: caption2; text: qsTr("Mute on"); anchors.topMargin: 7 }
            PropertyChanges { target: callImage; source: "../../images/common/bg_chiamata_incorso.svg" }
            AnchorChanges { target: caption2; anchors.top: parent.top }
        }
    ]
}
