import QtQuick 1.1
import BtObjects 1.0


ColumnBrowserCommon {

    property variant rootPath
    property alias filter: upnpModel.filter

    theModel: upnpModel

    UPnPListModel {
        id: upnpModel
        filter: FileObject.All
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
