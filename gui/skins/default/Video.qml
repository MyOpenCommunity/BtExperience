import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("Video")
    rootColumn: Component { ColumnBrowser {
            text: qsTr("Video folder")
            rootPath: [
                "net",
                "stuff",
                "video",
                "movies"
            ]
            flags: FileObject.Video | FileObject.Directory
        } }
    names: MultimediaNames {}
}
