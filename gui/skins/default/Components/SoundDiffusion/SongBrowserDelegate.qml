import QtQuick 1.1
import Components.Text 1.0
import BtObjects 1.0
import Components 1.0

SvgImage {
    id: background

    property variant itemObject

    signal delegateClicked

    source: "../../images/sound_diffusion/btn_file.svg"

    QtObject {
        id: privateProps

        function getPressedImage() {
            if (itemObject.fileType === FileObject.Audio)
                return "../../images/sound_diffusion/ico_file_audio_P.svg"
            return ""
        }

        function getDefaultImage() {
            if (itemObject.fileType === FileObject.Audio)
                return "../../images/sound_diffusion/ico_file_audio.svg"
            return ""
        }
    }

    Item {
        id: iconSpacing
        width: 25
        height: 25
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }

        SvgImage {
            id: icon
            anchors.fill: parent
            source: privateProps.getDefaultImage()
        }
    }

    UbuntuLightText {
        id: entryName
        text: itemObject.name
        width: 335
        elide: Text.ElideRight
        color: "#5a5a5a"
        anchors {
            left: iconSpacing.right
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
    }

    SvgImage {
        id: rightArrow
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }

        source: "../../images/sound_diffusion/ico_apri_cartella.svg"
        visible: itemObject.fileType === FileObject.Directory
    }

    SvgImage {
        id: shadow
        anchors {
            left: background.left
            top: background.bottom
            right: background.right
        }
        source: "../../images/sound_diffusion/btn_file_shadow.svg"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: delegateClicked()
    }

    states: [
        State {
            name: "pressed"
            when: mouseArea.pressed
            PropertyChanges {
                target: background
                source: "../../images/sound_diffusion/btn_file_P.svg"
            }
            PropertyChanges {
                target: icon
                source: privateProps.getPressedImage()
            }
            PropertyChanges {
                target: entryName
                color: "white"
            }
            PropertyChanges {
                target: rightArrow
                source: "../../images/sound_diffusion/ico_apri_cartella_P.svg"
            }
        }
    ]
}
