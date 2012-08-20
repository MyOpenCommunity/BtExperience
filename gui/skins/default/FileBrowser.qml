// Page that shows a directory browser in a MenuColumn, with file type filtering
// capabilities. Plays the file on click.
// Currently used in Multimedia section
import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

SystemPage {
    id: fileBrowserPage
    property variant rootPath
    property string browserText: "file browser"

    source: "images/multimedia.jpg"
    text: qsTr("Photo")
    rootColumn: Component {
        ColumnBrowser {
            rootPath: fileBrowserPage.rootPath
            text: browserText
        }
    }
    names: MultimediaNames {}
}
