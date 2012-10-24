import QtQuick 1.1
import BtObjects 1.0

SongBrowser {
    id:column
    property alias rootPath: files.rootPath

    function startPlay(objIndex) {
        column.dataModel.startPlay(files, objIndex, files.count)
    }

    listModel: files

    DirectoryListModel {
        id: files
        filter: FileObject.Audio | FileObject.Directory
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
