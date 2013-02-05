import QtQuick 1.1
import BtObjects 1.0


ColumnBrowserCommon {

    property alias rootPath: localModel.rootPath
    property alias filter: localModel.filter
    property bool restoreState

    theModel: localModel
    text: localModel.currentPath[localModel.currentPath.length - 1]

    DirectoryListModel {
        id: localModel
        filter: FileObject.All
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Component.onCompleted: {
        if (restoreState)
            global.audioVideoPlayer.restoreLocalState(localModel)
    }
}
