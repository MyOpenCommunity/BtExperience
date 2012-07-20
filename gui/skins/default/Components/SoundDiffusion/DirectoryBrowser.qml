import QtQuick 1.1
import BtObjects 1.0

SongBrowser {
    property alias rootPath: files.rootPath

    listModel: files

    DirectoryListModel {
        id: files
        filter: FileObject.Audio | FileObject.Directory
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
