import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("Photo")
    rootColumn: Component {
        ColumnBrowser {
            rootPath: ["media", "photos"]
            flags: FileObject.Image | FileObject.Directory
        }
    }
    names: MultimediaNames {}
}
