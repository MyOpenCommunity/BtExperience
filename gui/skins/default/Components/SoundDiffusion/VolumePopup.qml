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
            topMargin: volumePopup.height / 100 * 10
            left: volumePopup.left
            leftMargin: volumePopup.width / 100 * 7
        }
    }

    UbuntuLightText {
        text: volumePopup.volume
        color: "white"
        font.pixelSize: volumePopup.height / 100 * 20
        anchors {
            top: volumePopup.top
            topMargin: volumePopup.height / 100 * 10
            right: volumePopup.right
            rightMargin: volumePopup.width / 100 * 7
        }
    }

    SvgImage {
        id: muteIcon

        source: volumePopup.mute ? "../../images/common/regola_volume/ico_mute.svg" : "../../images/common/regola_volume/ico_volume.svg"
        anchors {
            top: volumePopup.top
            topMargin: volumePopup.height / 100 * 50
            left: volumePopup.left
            leftMargin: volumePopup.width / 100 * 7
        }
    }

    SvgImage {
        source: "../../images/common/bg_regola_dimmer.svg"
        anchors {
            verticalCenter: muteIcon.verticalCenter
            left: muteIcon.right
            leftMargin: volumePopup.width / 100 * 2
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
