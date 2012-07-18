import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    Image {
        id: imageBg
        source: "../../images/sound_diffusion/bg_elenco_file.svg"
    }

    ButtonImageThreeStates {
        id: backButton
        defaultImageBg: "../../images/common/btn_66x35.svg"
        pressedImageBg: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        defaultImage: "../../images/sound_diffusion/ico_back.svg"
        pressedImage: "../../images/sound_diffusion/ico_back_P.svg"
        anchors {
            top: imageBg.top
            topMargin: 6
            left: imageBg.left
            leftMargin: 10
        }

        onClicked: files.exitDirectory()
        status: 0
    }

    PaginatorOnBackground {
        id: paginator
        anchors {
            top: backButton.bottom
            topMargin: 10
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
            bottom: parent.bottom
            bottomMargin: 6
        }
        elementsOnPage: 10
        buttonVisible: false
        spacing: 5

        delegate: SongBrowserDelegate {
            itemObject: files.getObject(index)
            onDelegateClicked: {
                switch (itemObject.fileType)
                {
                case FileObject.Audio:
                    // we need braces due to bug
                    // https://bugreports.qt-project.org/browse/QTBUG-17012
                {
                    var realPath = "/" + itemObject.path.join("/")
                    console.log("Audio path: " + realPath);
                    column.dataModel.startPlay(realPath)
                    break
                }
                case FileObject.Directory:
                {
                    files.enterDirectory(itemObject.name)
                    break
                }
                }
            }
        }

        model: files
    }

    UPnPListModel {
        id: files
        filter: FileObject.Audio | FileObject.Directory
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
