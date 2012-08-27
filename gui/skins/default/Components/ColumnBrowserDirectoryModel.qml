import QtQuick 1.1
import BtObjects 1.0


ColumnBrowserCommon {

    property alias rootPath: localModel.rootPath

    theModel: localModel

    DirectoryListModel {
        id: localModel
        filter: FileObject.All
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
