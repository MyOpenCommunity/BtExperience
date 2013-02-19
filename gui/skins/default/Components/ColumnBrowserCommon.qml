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
    property bool typeFilterEnabled: true

    property alias bgHeight: imageBg.height
    property bool preview: false

    // Index of the clicked item inside the model
    signal imageClicked(variant item, int index)
    signal audioClicked(variant item, int index)
    signal videoClicked(variant item, int index)

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

        onPressed: theModel.exitDirectory()
        visible: !theModel.isRoot
    }

    ButtonImageThreeStates {
        id: photoButton

        visible: column.typeFilterEnabled && !column.upnp
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

        onPressed: {
            privateProps.activeButton = 3
            theModel.filter = FileObject.Image | FileObject.Directory
        }
        status: privateProps.activeButton === 3
    }

    ButtonImageThreeStates {
        id: videoButton

        visible: column.typeFilterEnabled && !column.upnp
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

        onPressed: {
            privateProps.activeButton = 2
            theModel.filter = FileObject.Video | FileObject.Directory
        }
        status: privateProps.activeButton === 2
    }

    ButtonImageThreeStates {
        id: audioButton

        visible: column.typeFilterEnabled && !column.upnp
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

        onPressed: {
            privateProps.activeButton = 1
            theModel.filter = FileObject.Audio | FileObject.Directory
        }
        status: privateProps.activeButton === 1
    }

    ButtonImageThreeStates {
        id: fileButton

        visible: column.typeFilterEnabled && !column.upnp
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

        onPressed: {
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
            topMargin: 10
            left: imageBg.left
            leftMargin: 10
            right: imageBg.right
            rightMargin: 10
        }
        elide: Text.ElideRight
    }

    // TODO make an header
    // in some browsers, like weblink one, there is an header to add elements;
    // dynamically reduce elementsOnPage to make room for it!

    PaginatorOnBackground {
        id: paginator
        anchors {
            top: caption.bottom
            topMargin: 10
            left: imageBg.left
            leftMargin: 10
            right: imageBg.right
            rightMargin: 10
            bottom: imageBg.bottom
            bottomMargin: 6
        }
        elementsOnPage: 9
        spacing: 5

        delegate: ColumnBrowserDelegate {
            itemObject: theModel.getObject(index)
            preview: column.preview
            onDelegateClicked: {
                var i = index;
                if (!column.upnp) // local model uses absolute indexes
                    i += theModel.range[0];
                switch (itemObject.fileType)
                {
                case FileObject.Audio: {
                    // we need braces due to bug
                    // https://bugreports.qt-project.org/browse/QTBUG-17012
                    column.audioClicked(itemObject, i)
                    break
                }
                case FileObject.Image: {
                    column.imageClicked(itemObject, i)
                    break
                }
                case FileObject.Video: {
                    column.videoClicked(itemObject, i)
                    break
                }
                case FileObject.Directory: {
                    theModel.enterDirectory(itemObject.name)
                    break
                }
                default: {
                    console.log("Unexpected file type: " + itemObject.fileType + " for index: " + i + " (upnp: " + column.upnp + ")")
                }
                }
            }
        }

        buttonComponent: ButtonImageThreeStates {
            visible: !column.upnp && (dataModel ? true : false) && dataModel.mountPoint.mounted
            defaultImageBg: "../images/common/btn_66x35.svg"
            pressedImageBg: "../images/common/btn_66x35_P.svg"
            shadowImage: "../images/common/btn_shadow_66x35.svg"
            defaultImage: "../images/common/icon_eject.svg"
            pressedImage: "../images/common/icon_eject_p.svg"
            onPressed: dataModel.mountPoint.unmount()
        }

        model: theModel
    }

    Connections {
        target: theModel
        onLoadingChanged: {
            if (!theModel.isLoading) {
                feedbackTimer.stop()
                state = ""
            }
            else {
                feedbackTimer.restart()
            }
        }
        onRangeChanged: paginator.goToPage(theModel.range[0] / paginator.elementsOnPage + 1)
    }

    Timer {
        id: feedbackTimer
        interval: 1000
        onTriggered: state = "loading"
    }

    SvgImage {
        id: loadingIndicator

        source: "../images/common/ico_caricamento_white.svg"
        anchors.centerIn: imageBg
        visible: false

        Timer {
            id: loadingTimer
            interval: 250
            repeat: true
            onTriggered: loadingIndicator.rotation += 45
        }

        states: [
            State {
                name: "indicatorShown"
                PropertyChanges { target: loadingIndicator; visible: true }
                PropertyChanges { target: loadingTimer; running: true }
            }
        ]
    }

    states: [
        State {
            name: "loading"
            PropertyChanges { target: paginator; visible: false }
            PropertyChanges { target: loadingIndicator; state: "indicatorShown" }
        }
    ]
}
