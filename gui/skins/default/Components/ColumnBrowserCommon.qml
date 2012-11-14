import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "../js/Stack.js" as Stack


MenuColumn {
    id: column

    property alias text: caption.text
    property alias paginator: paginator
    property bool upnp
    property variant theModel
    property bool imageOnly: false
    property alias bgHeight: imageBg.height

    signal selected(variant item)

    SvgImage {
        id: imageBg
        source: "../images/common/bg_browse.svg"
    }

    ButtonImageThreeStates {
        id: backButton

        defaultImageBg: "../images/common/btn_66x35.svg"
        pressedImageBg: "../images/common/btn_66x35_P.svg"
        shadowImage: "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_back.svg"
        pressedImage: "../images/common/ico_back_P.svg"
        anchors {
            top: imageBg.top
            topMargin: 6
            left: imageBg.left
            leftMargin: 10
        }

        onClicked: theModel.exitDirectory()
        status: 0
    }

    ButtonImageThreeStates {
        id: photoButton

        visible: !column.imageOnly
        defaultImageBg: "../images/common/btn_tipo_file.svg"
        pressedImageBg: "../images/common/btn_tipo_file_P.svg"
        selectedImageBg: "../images/common/btn_tipo_file_S.svg"
        shadowImage: "../images/common/ombra_btn_tipo_file.svg"
        defaultImage: "../images/common/ico_foto.svg"
        pressedImage: "../images/common/ico_foto_P.svg"
        selectedImage: "../images/common/ico_foto_P.svg"
        anchors {
            top: imageBg.top
            topMargin: 6
            right: imageBg.right
            rightMargin: 10
        }

        onClicked: {
            privateProps.activeButton = 3
            theModel.filter = FileObject.Image | FileObject.Directory
        }
        status: privateProps.activeButton === 3
    }

    ButtonImageThreeStates {
        id: videoButton

        visible: !column.imageOnly
        defaultImageBg: "../images/common/btn_tipo_file.svg"
        pressedImageBg: "../images/common/btn_tipo_file_P.svg"
        selectedImageBg: "../images/common/btn_tipo_file_S.svg"
        shadowImage: "../images/common/ombra_btn_tipo_file.svg"
        defaultImage: "../images/common/ico_video.svg"
        pressedImage: "../images/common/ico_video_P.svg"
        selectedImage: "../images/common/ico_video_P.svg"
        anchors {
            top: imageBg.top
            topMargin: 6
            right: photoButton.left
        }

        onClicked: {
            privateProps.activeButton = 2
            theModel.filter = FileObject.Video | FileObject.Directory
        }
        status: privateProps.activeButton === 2
    }

    ButtonImageThreeStates {
        id: audioButton

        visible: !column.imageOnly
        defaultImageBg: "../images/common/btn_tipo_file.svg"
        pressedImageBg: "../images/common/btn_tipo_file_P.svg"
        selectedImageBg: "../images/common/btn_tipo_file_S.svg"
        shadowImage: "../images/common/ombra_btn_tipo_file.svg"
        defaultImage: "../images/common/ico_audio.svg"
        pressedImage: "../images/common/ico_audio_P.svg"
        selectedImage: "../images/common/ico_audio_P.svg"
        anchors {
            top: imageBg.top
            topMargin: 6
            right: videoButton.left
        }

        onClicked: {
            privateProps.activeButton = 1
            theModel.filter = FileObject.Audio | FileObject.Directory
        }
        status: privateProps.activeButton === 1
    }

    ButtonImageThreeStates {
        id: fileButton

        visible: !column.imageOnly
        defaultImageBg: "../images/common/btn_tipo_file.svg"
        pressedImageBg: "../images/common/btn_tipo_file_P.svg"
        selectedImageBg: "../images/common/btn_tipo_file_S.svg"
        shadowImage: "../images/common/ombra_btn_tipo_file.svg"
        defaultImage: "../images/common/ico_file.svg"
        pressedImage: "../images/common/ico_file_P.svg"
        selectedImage: "../images/common/ico_file_P.svg"
        anchors {
            top: imageBg.top
            topMargin: 6
            right: audioButton.left
        }

        onClicked: {
            privateProps.activeButton = 0
            theModel.filter = FileObject.All
        }
        status: privateProps.activeButton === 0
    }

    QtObject {
        id: privateProps
        property int activeButton: 0
    }

    UbuntuMediumText {
        id: caption
        font.pixelSize: 18
        text: qsTr("Music folder")
        color: "white"
        anchors {
            top: backButton.bottom
            topMargin: 15
            left: imageBg.left
            leftMargin: 10
            right: imageBg.right
            rightMargin: 10
        }
    }

    // TODO make an header
    // in some browsers, like weblink one, there is an header to add elements;
    // dynamically reduce elementsOnPage to make room for it!

    PaginatorOnBackground {
        id: paginator
        anchors {
            top: caption.bottom
            topMargin: 15
            left: imageBg.left
            leftMargin: 10
            right: imageBg.right
            rightMargin: 10
            bottom: imageBg.bottom
            bottomMargin: 6
        }
        elementsOnPage: 9
        buttonVisible: false
        spacing: 5

        delegate: ColumnBrowserDelegate {
            itemObject: theModel.getObject(index)
            onDelegateClicked: {
                var i = index;
                if (!column.upnp) // local model uses absolute indexes
                    i += theModel.range[0];
                switch (itemObject.fileType)
                {
                case FileObject.Audio:
                    // we need braces due to bug
                    // https://bugreports.qt-project.org/browse/QTBUG-17012
                {
                    // the index we need is the absolute index in the unfiltered model;
                    // the delegate index property is relative to actual page, so let's
                    // make some math to compute the right value
                    Stack.goToPage("AudioVideoPlayer.qml", {"model": theModel, "index": i, "isVideo": false, "upnp": column.upnp})
                    break
                }
                case FileObject.Image:
                {
                    if (column.imageOnly) {
                        column.selected(itemObject)
                        column.closeColumn()
                    }
                    else {
                        Stack.goToPage("PhotoPlayer.qml", {"model": theModel, "index": i, "upnp": column.upnp})
                    }
                    break
                }
                case FileObject.Video:
                {
                    Stack.goToPage("AudioVideoPlayer.qml", {"model": theModel, "index": i, "upnp": column.upnp})
                    break
                }
                case FileObject.Directory:
                {
                    theModel.enterDirectory(itemObject.name)
                    break
                }
                default:
                {
                    console.log("Unexpected file type: " + itemObject.fileType + " for index: " + i + " (upnp: " + column.upnp + ")")
                }
                }
            }
        }

        model: theModel
    }
}
