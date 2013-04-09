import QtQuick 1.1
import BtObjects 1.0


ColumnBrowserCommon {

    property alias rootPath: localModel.rootPath
    property alias filter: localModel.filter
    property bool restoreState
    property int level: localModel.currentPath.length - 1

    theModel: localModel
    text: level === 1 ? dataModel.name : localModel.currentPath[level]

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
