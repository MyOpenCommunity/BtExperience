import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "../js/Stack.js" as Stack


MenuColumn {
    id: column

    property alias text: caption.text
    property alias paginator: paginator
    property alias rootPath: listModel.rootPath

    SvgImage {
        id: imageBg
        source: "../images/common/bg_browse.svg"
    }

    ButtonImageThreeStates {
        id: backButton

        defaultImageBg: "../images/common/btn_back.svg"
        pressedImageBg: "../images/common/btn_back_P.svg"
        shadowImage: "../images/common/ombra_btn_back.svg"
        defaultImage: "../images/common/ico_back.svg"
        pressedImage: "../images/common/ico_back_P.svg"
        anchors {
            top: imageBg.top
            topMargin: 6
            left: imageBg.left
            leftMargin: 10
        }

        onClicked: listModel.exitDirectory()
        status: 0
    }

    ButtonImageThreeStates {
        id: photoButton

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
            listModel.filter = FileObject.Image | FileObject.Directory
        }
        status: privateProps.activeButton === 3
    }

    ButtonImageThreeStates {
        id: videoButton

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
            listModel.filter = FileObject.Video | FileObject.Directory
        }
        status: privateProps.activeButton === 2
    }

    ButtonImageThreeStates {
        id: audioButton

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
            listModel.filter = FileObject.Audio | FileObject.Directory
        }
        status: privateProps.activeButton === 1
    }

    ButtonImageThreeStates {
        id: fileButton

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
            listModel.filter = FileObject.All
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
            itemObject: listModel.getObject(index)
            onDelegateClicked: {
                switch (itemObject.fileType)
                {
                case FileObject.Audio:
                    // we need braces due to bug
                    // https://bugreports.qt-project.org/browse/QTBUG-17012
                {
                    console.log("Navigation to AudioPlayer to be implemented")
                    break
                }
                case FileObject.Image:
                {
                    Stack.openPage("PhotoPlayer.qml", {"model": listModel, "item": itemObject, "index": index})
                    break
                }
                case FileObject.Video:
                {
                    Stack.openPage("AudioVideoPlayer.qml", {"model": listModel, "index": index})
                    break
                }
                case FileObject.Directory:
                {
                    listModel.enterDirectory(itemObject.name)
                    break
                }
                default:
                {
                    console.log("Unexpected file type: " + itemObject.fileType + " for index: " + index)
                }
                }
            }
        }

        model: listModel
    }

    
    DirectoryListModel {
        id: listModel
        filter: FileObject.All
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
