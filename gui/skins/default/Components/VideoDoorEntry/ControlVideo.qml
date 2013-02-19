/**
  * A control to use as base for video stream from a camera.
  * The control has a status bar containing a description and a button to
  * loop between the various cameras.
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: bg

    property alias label: statusLabel.text
    property alias nextButtonVisible: nextButton.visible
    property alias color: bg_video.color

    signal nextClicked

    source: "../../images/common/bordo_video.svg"

    SvgImage {
        id: video

        source: "../../images/common/video.svg"
        anchors.centerIn: parent

        Rectangle {
            id: bg_video
            color: "black"
            width: 640
            height: 480
            anchors.centerIn: parent
        }
    }

    SvgImage {
        id: statusBar

        source: "../../images/common/bg_nome_video.svg"
        anchors {
            left: video.left
            right: video.right
            bottom: video.bottom
        }
    }

    UbuntuMediumText {
        id: statusLabel

        text: "Posto Esterno 1"
        font.pixelSize: 16
        color: "white"
        anchors {
            centerIn: statusBar
        }
    }

    ButtonImageThreeStates {
        id: nextButton

        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/ico_cicla.svg"
        pressedImage: "../../images/common/ico_cicla_P.svg"
        onPressed: nextClicked()
        anchors {
            right: video.right
            rightMargin: 6
            bottom: video.bottom
            bottomMargin: 7
        }
    }
}
