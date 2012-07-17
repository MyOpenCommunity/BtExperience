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
            defaultImage: "../../images/sound_diffusion/ico_indietro.svg"
            pressedImage: "../../images/sound_diffusion/ico_indietro_P.svg"
            onClicked: console.log("Previous track clicked")
            status: 0
        }

        ButtonImageThreeStates {
            id: playPauseButton
            defaultImageBg: "../../images/common/btn_99x35.svg"
            pressedImageBg: "../../images/common/btn_99x35_P.svg"
            shadowImage: "../../images/common/btn_shadow_99x35.svg"
            defaultImage: "../../images/sound_diffusion/ico_play.svg"
            pressedImage: "../../images/sound_diffusion/ico_play_P.svg"
            onClicked: control.playClicked()
            status: 0
        }

        ButtonImageThreeStates {
            defaultImageBg: "../../images/sound_diffusion/btn_45x35.svg"
            pressedImageBg: "../../images/sound_diffusion/btn_45x35_P.svg"
            shadowImage: "../../images/sound_diffusion/btn_45x35_shadow.svg"
            defaultImage: "../../images/sound_diffusion/ico_avanti.svg"
            pressedImage: "../../images/sound_diffusion/ico_avanti_P.svg"
            onClicked: console.log("Next track clicked")
            status: 0
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
