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
import BtObjects 1.0
import "../../js/logging.js" as Log


SvgImage {
    id: control

    property alias time: timeLabel.text
    property alias song: songLabel.text
    property alias album: albumLabel.text
    property int playerStatus: -1

    signal playClicked
    signal nextClicked
    signal previousClicked

    source: "../../images/sound_diffusion/bg_player.svg"

    UbuntuMediumText {
        id: text1
        anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 6
        }

        text: "Media player"
        font.pixelSize: 14
        color: "#444546"
    }

    SvgImage {
        id: infoBox
        source: "../../images/sound_diffusion/bg_testo.svg"
        anchors {
            top: text1.bottom
            left: parent.left
            leftMargin: 6
        }

        UbuntuLightText {
            id: timeLabel
            anchors {
                top: parent.top
                topMargin: 6
                right: parent.right
                rightMargin: 6
            }
            text: "99:59"
            color: "#656565"
        }

        Column {
            anchors {
                top: parent.top
                topMargin: 6
                left: parent.left
                leftMargin: 6
            }

            spacing: 5

            UbuntuLightText {
                id: songLabel
                text: "This is a very long song title which I like very much"
                font.pixelSize: 12
                color: "#656565"
                width: infoBox.width - 50
                elide: Text.ElideRight
            }

            UbuntuLightText {
                id: albumLabel
                text: "This is a very looong album name, really one of my favorites"
                font.pixelSize: 16
                color: "#656565"
                width: infoBox.width - 35
                elide: Text.ElideRight
            }
        }
    }

    Row {
        spacing: 4
        anchors {
            top: infoBox.bottom
            topMargin: 6
            left: parent.left
            leftMargin: 6
        }

        ButtonImageThreeStates {
            defaultImageBg: "../../images/sound_diffusion/btn_45x35.svg"
            pressedImageBg: "../../images/sound_diffusion/btn_45x35_P.svg"
            shadowImage: "../../images/sound_diffusion/btn_45x35_shadow.svg"
            defaultImage: "../../images/common/ico_previous_track.svg"
            pressedImage: "../../images/common/ico_previous_track_P.svg"
            onPressed: control.previousClicked()
        }

        ButtonImageThreeStates {
            id: playPauseButton
            defaultImageBg: "../../images/common/btn_99x35.svg"
            pressedImageBg: "../../images/common/btn_99x35_P.svg"
            shadowImage: "../../images/common/btn_shadow_99x35.svg"
            defaultImage: "../../images/sound_diffusion/ico_play.svg"
            pressedImage: "../../images/sound_diffusion/ico_play_P.svg"
            onPressed: control.playClicked()
        }

        ButtonImageThreeStates {
            defaultImageBg: "../../images/sound_diffusion/btn_45x35.svg"
            pressedImageBg: "../../images/sound_diffusion/btn_45x35_P.svg"
            shadowImage: "../../images/sound_diffusion/btn_45x35_shadow.svg"
            defaultImage: "../../images/common/ico_next_track.svg"
            pressedImage: "../../images/common/ico_next_track_P.svg"
            onPressed: control.nextClicked()
        }
    }

    states: [
        State {
            name: "paused"
            when: playerStatus === MultiMediaPlayer.Paused
            PropertyChanges {
                target: playPauseButton
                defaultImage: "../../images/sound_diffusion/ico_play.svg"
                pressedImage: "../../images/sound_diffusion/ico_play_P.svg"
            }
        },
        State {
            name: "playing"
            when: playerStatus === MultiMediaPlayer.Playing
            PropertyChanges {
                target: playPauseButton
                defaultImage: "../../images/sound_diffusion/ico_pause.svg"
                pressedImage: "../../images/sound_diffusion/ico_pause_P.svg"
            }
        }
    ]
}
