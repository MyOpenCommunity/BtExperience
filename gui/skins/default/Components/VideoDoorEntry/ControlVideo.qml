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

    signal nextClicked

    source: "../../images/common/bordo_video.svg"

    SvgImage {
        id: video

        source: "../../images/common/video.svg"
        anchors.centerIn: parent

        Rectangle {
            id: bg_video
            color: "red"
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

        defaultImageBg: "../../images/common/btn_cicla.svg"
        pressedImageBg: "../../images/common/btn_cicla_P.svg"
        shadowImage: "../../images/common/ombra_btn_cicla.svg"
        defaultImage: "../../images/common/ico_cicla.svg"
        pressedImage: "../../images/common/ico_cicla_P.svg"
        status: 0
        onClicked: nextClicked()
        anchors {
            right: video.right
            rightMargin: 6
            bottom: video.bottom
            bottomMargin: 7
        }
    }
}
