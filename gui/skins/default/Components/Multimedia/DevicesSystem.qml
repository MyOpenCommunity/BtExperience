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
                column.loadColumn(columnBrowser, clickedItem.itemText, clickedItem, clickedItem.props)
            }
        }

        model: modelList
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({
                                 "itemText": qsTr("USB"),
                                 "props": {
                                     "rootPath": ["media", "usb1"],
                                     "text": qsTr("USB")}
                             })
            modelList.append({
                                 "itemText": qsTr("media server"),
                                 "props": {
                                     "rootPath": ["media", "server1"],
                                     "text": qsTr("media server")}
                             })
            modelList.append({
                                 "itemText": qsTr("SD"),
                                 "props": {
                                     "rootPath": ["media", "sd1"],
                                     "text": qsTr("SD")}
                             })
        }
    }

    Component {
        id: columnBrowser
        ColumnBrowser {}
    }
}
