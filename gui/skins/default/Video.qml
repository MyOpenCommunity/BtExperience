import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("video")
    rootColumn: Component { ColumnBrowser {
            text: qsTr("Video folder")
        } }
    names: MultimediaNames {}

    onRootObjectChanged: {
        if (rootObject) {
            rootObject.flags = FileObject.Video | FileObject.Directory
            // TODO load right root path
            rootObject.rootPath = [
                        "net",
                        "stuff",
                        "video",
                        "movies"
                    ]
        }
    }
}
