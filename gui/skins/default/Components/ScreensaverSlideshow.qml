import QtQuick 1.1
import BtObjects 1.0


Rectangle {
    id: screensaver

    width: 1024
    height: 600
    color: "black"

    SvgImage {
        id: thePhoto

        source: privateProps.item.path
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        anchors.margins: 4
    }

    Timer {
        id: slideshowTimer

        interval: 4000 // TODO where to take this value?
        running: true
        repeat: true
        onTriggered: privateProps.goNextImage()
    }

    DirectoryListModel {
        id: model
        filter: FileObject.Image | FileObject.Directory
        // TODO load right root path
        rootPath: [
            "home",
            "roberto",
            "work",
            "bticino",
            "repos",
            "bt_experience",
            "gui",
            "skins",
            "default",
            "images",
            "common"
        ]
    }

    QtObject {
        id: privateProps

        property variant item: model.getObject(0)
        property int index: 0

        function goNextImage() {
            var n = model.count
            // note we start from 1, not 0
            for (var i = 1; i < n; ++i) {
                var k = (privateProps.index + i) % n
                var obj = model.getObject(k)
                if (obj.fileType === privateProps.item.fileType) {
                    privateProps.item = obj
                    privateProps.index = k
                    break
                }
            }
        }
    }
}
