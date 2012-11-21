import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: background

    property variant itemObject
    property bool preview: false

    signal delegateClicked

    source: "../images/common/btn_file.svg"

    QtObject {
        id: privateProps

        function getPressedImage() {
            if (background.preview && itemObject.fileType !== FileObject.Directory)
                return itemObject.path
            else if (itemObject.fileType === FileObject.Audio)
                return "../images/common/ico_audio_P.svg"
            else if (itemObject.fileType === FileObject.Video)
                return "../images/common/ico_video_P.svg"
            else if (itemObject.fileType === FileObject.Image)
                return "../images/common/ico_foto_P.svg"
            else if (itemObject.fileType === FileObject.Unknown)
                return "../images/common/ico_file_P.svg"
            return ""
        }

        function getDefaultImage() {
            if (background.preview && itemObject.fileType !== FileObject.Directory)
                return itemObject.path
            else if (itemObject.fileType === FileObject.Audio)
                return "../images/common/ico_audio.svg"
            else if (itemObject.fileType === FileObject.Video)
                return "../images/common/ico_video.svg"
            else if (itemObject.fileType === FileObject.Image)
                return "../images/common/ico_foto.svg"
            else if (itemObject.fileType === FileObject.Unknown)
                return "../images/common/ico_file.svg"
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
            width: 25
            height: 25
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

        source: "../images/common/ico_apri_cartella.svg"
        visible: itemObject.fileType === FileObject.Directory
    }

    SvgImage {
        id: shadow
        anchors {
            left: background.left
            top: background.bottom
            right: background.right
        }
        source: "../images/common/ombra_btn_file.svg"
    }

    BeepingMouseArea {
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
                source: "../images/common/btn_file_P.svg"
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
                source: "../images/common/ico_apri_cartella_P.svg"
            }
        }
    ]
}
