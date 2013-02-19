import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../../js/logging.js" as Log


SvgImage {
    id: control
    property string radioName: "Radio Cassadritta - Your favorite hardcore techno music station"
    property int radioFrequency: 10870
    property int stationNumber: 3

    signal nextTrack
    signal previousTrack

    source: "../../images/sound_diffusion/bg_player.svg"

    UbuntuMediumText {
        id: text1
        anchors {
            top: parent.top
            topMargin: 10
            left: parent.left
            leftMargin: 6
        }

        text: qsTr("radio FM")
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

        SvgImage {
            id: radioNumBox
            source: "../../images/sound_diffusion/bg_numero_radio.svg"
            anchors {
                top: parent.top
                topMargin: 6
                right: parent.right
                rightMargin: 6
            }

            UbuntuLightText {
                anchors.centerIn: parent
                text: stationNumber
                color: "white"
            }
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
                text: formatFrequency(control.radioFrequency)
                color: "#656565"
            }

            UbuntuLightText {
                text: radioName
                font.pixelSize: 16
                color: "#656565"
                width: infoBox.width - 35
                elide: Text.ElideRight
            }
        }
    }

    Row {
        anchors {
            top: infoBox.bottom
            topMargin: 6
            left: parent.left
            leftMargin: 6
        }
        ButtonImageThreeStates {
            defaultImageBg: "../../images/common/btn_99x35.svg"
            pressedImageBg: "../../images/common/btn_99x35_P.svg"
            shadowImage: "../../images/common/btn_shadow_99x35.svg"
            defaultImage: "../../images/sound_diffusion/ico_indietro.svg"
            pressedImage: "../../images/sound_diffusion/ico_indietro_P.svg"
            onPressed: previousTrack()
        }

        ButtonImageThreeStates {
            defaultImageBg: "../../images/common/btn_99x35.svg"
            pressedImageBg: "../../images/common/btn_99x35_P.svg"
            shadowImage: "../../images/common/btn_shadow_99x35.svg"
            defaultImage: "../../images/sound_diffusion/ico_avanti.svg"
            pressedImage: "../../images/sound_diffusion/ico_avanti_P.svg"
            onPressed: nextTrack()
        }
    }

    function formatFrequency(freq) {
        if (freq === -1)
            return "--.-"
        else
        {
            var s = freq.toString()
            // add a dot "." before the last two digits
            return s.slice(0, s.length - 2) + "." + s.slice(s.length - 2)
        }
    }
}
