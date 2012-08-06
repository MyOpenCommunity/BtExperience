import QtQuick 1.1
import Components 1.0
import Components.SoundDiffusion 1.0


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("photo")
    rootColumn: Component { ColumnBrowser {} }
    names: MultimediaNames {}

    onRootColumnChanged: {
        if (rootColumn)
            rootColumn.flags = FileObject.Image | FileObject.Directory
    }
}

