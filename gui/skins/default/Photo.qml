import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("Photo")
    rootColumn: Component { ColumnBrowser {} }
    names: MultimediaNames {}

    onRootObjectChanged: {
        if (rootObject) {
            rootObject.flags = FileObject.Image | FileObject.Directory
            // TODO load right root path
            rootObject.rootPath = [
                        "media",
                        "photos"
                    ]
        }
    }
}
