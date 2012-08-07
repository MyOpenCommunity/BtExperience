import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("photo")
    rootColumn: Component { ColumnBrowser {} }
    names: MultimediaNames {}

    onRootObjectChanged: {
        if (rootObject) {
            rootObject.flags = FileObject.Image | FileObject.Directory
            // TODO load right root path
            rootObject.rootPath = [
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
    }
}
