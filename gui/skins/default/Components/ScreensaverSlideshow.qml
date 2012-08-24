import QtQuick 1.1
import BtObjects 1.0


Rectangle {
    id: screensaver

    property bool ok: false

    width: 1024
    height: 600
    color: "black"

    SvgImage {
        id: thePhoto

        source: ok ? global.photoPlayer.fileName : ""
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        anchors.margins: 4
    }

    Timer {
        id: slideshowTimer

        interval: 4000 // TODO where to take this value?
        running: ok
        repeat: true
        onTriggered: global.photoPlayer.nextPhoto()
    }

    DirectoryListModel {
        id: model
        filter: FileObject.Image
        // TODO load right root path
        rootPath: ["media", "usb1"]
    }

    Component.onCompleted: {
        if (model.count > 0) {
            ok = true
            global.photoPlayer.generatePlaylist(model, 0)
        }
    }
}
