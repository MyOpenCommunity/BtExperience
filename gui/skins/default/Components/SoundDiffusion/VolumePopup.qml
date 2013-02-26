import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

SvgImage {
    id: volumePopup

    property int volume: 50
    property bool mute: false

    source: "../../images/common/regola_volume/bg_regola_volume.svg"
    opacity: 0

    onVolumeChanged: {
        volumePopup.state = "volumeChanged"
        hidingTimer.restart() // don't use start or popup will blink when pressedAndHold
    }
    onMuteChanged: {
        volumePopup.state = "volumeChanged"
        hidingTimer.restart() // don't use start or popup will blink when pressedAndHold
    }

    UbuntuLightText {
        text: qsTr("mute")
        color: "white"
        font.pixelSize: volumePopup.height / 100 * 20
        font.capitalization: Font.AllUppercase
        anchors {
            top: volumePopup.top
            topMargin: Math.round(volumePopup.height / 100 * 10)
            left: volumePopup.left
            leftMargin: Math.round(volumePopup.width / 100 * 7)
        }
    }

    UbuntuLightText {
        text: volumePopup.volume
        color: "white"
        font.pixelSize: volumePopup.height / 100 * 20
        anchors {
            top: volumePopup.top
            topMargin: Math.round(volumePopup.height / 100 * 10)
            right: volumePopup.right
            rightMargin: Math.round(volumePopup.width / 100 * 7)
        }
    }

    SvgImage {
        id: muteIcon

        source: volumePopup.mute ? "../../images/common/regola_volume/ico_mute.svg" : "../../images/common/regola_volume/ico_volume.svg"
        anchors {
            top: volumePopup.top
            topMargin: Math.round(volumePopup.height / 100 * 50)
            left: volumePopup.left
            leftMargin: Math.round(volumePopup.width / 100 * 7)
        }
    }

    SvgImage {
        source: "../../images/common/bg_regola_dimmer.svg"
        anchors {
            verticalCenter: muteIcon.verticalCenter
            left: muteIcon.right
            leftMargin: Math.round(volumePopup.width / 100 * 2)
        }

        Rectangle {
            height: parent.height + 2
            width: parent.width * (volumePopup.volume < 1 ? 1 : volumePopup.volume) / 100 + 4
            radius: 100
            smooth: true
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: -2
            }
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#a9abad"
                }
                GradientStop {
                    position: 1.0
                    color: "#5c5c5c"
                }
            }
            Behavior on width {
                NumberAnimation { duration: 200 }
            }
        }
    }

    Timer {
        id: hidingTimer

        interval: 2000
        onTriggered: volumePopup.state = ""
    }

    states: [
        State {
            name: "volumeChanged"
            PropertyChanges { target: volumePopup; opacity: 1 }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                target: volumePopup
                property: "opacity"
                duration: 400
            }
        }
    ]
}
