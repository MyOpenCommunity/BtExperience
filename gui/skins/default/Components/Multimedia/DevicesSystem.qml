import QtQuick 1.1
import Components 1.0

import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            name: model.itemText
            hasChild: true
            onDelegateClicked: {
                var clickedItem = modelList.get(index)
                column.loadColumn(clickedItem.model, clickedItem.itemText, clickedItem, clickedItem.props)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({
                                 "itemText": qsTr("USB"),
                                 "model": columnBrowserDirectory,
                                 "props": {
                                     "rootPath": ["media", "usb1"],
                                     "text": qsTr("USB")}
                             })
            modelList.append({
                                 "itemText": qsTr("media server"),
                                 "model": columnBrowserUpnpModel,
                                 "props": {
                                     "upnp": true,
                                     "text": qsTr("media server")}
                             })
            modelList.append({
                                 "itemText": qsTr("SD"),
                                 "model": columnBrowserDirectory,
                                 "props": {
                                     "rootPath": ["media", "sd1"],
                                     "text": qsTr("SD")}
                             })
        }
    }

    Component {
        id: columnBrowserDirectory
        ColumnBrowserDirectoryModel {}
    }

    Component {
        id: columnBrowserUpnpModel
        ColumnBrowserUpnpModel {}
    }
}
