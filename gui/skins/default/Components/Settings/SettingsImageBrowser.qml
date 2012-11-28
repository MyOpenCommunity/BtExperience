import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    property bool isCard: false
    property bool _isStock: false // used internally to know if user selected a stock image

    onChildDestroyed: {
        privateProps.currentIndex = -1
        itemList.currentIndex = -1
    }

    Column {
        MenuItem {
            name: qsTr("Stock images")
            isSelected: privateProps.currentIndex === 1
            hasChild: true

            onClicked: {
                itemList.currentIndex = -1
                privateProps.currentIndex = 1
                column._isStock = true
                var props = {
                    rootPath: global.stockImagesFolder,
                    text: qsTr("Stock images"),
                    upnp: false,
                    imageOnly: true,
                    filter: FileObject.Image | FileObject.Directory,
                    bgHeight: 422,
                    "paginator.elementsOnPage": 7,
                    preview: true
                }
                column.loadColumn(directoryBrowser, qsTr("Stock images"), undefined, props)
            }
        }

        PaginatorList {
            id: itemList
            currentIndex: -1

            delegate: MenuItemDelegate {
                itemObject: modelList.getObject(index)
                name: itemObject.name
                hasChild: true
                enabled: itemObject.mountPoint ? itemObject.mountPoint.mounted : true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    column._isStock = false
                    var upnp = itemObject.sourceType === SourceObject.Upnp;
                    var props = {
                        rootPath: itemObject.rootPath,
                        text: itemObject.name,
                        upnp: upnp,
                        imageOnly: true,
                        filter: FileObject.Image | FileObject.Directory,
                        bgHeight: 422,
                        "paginator.elementsOnPage": 7,
                        preview: true
                    }
                    column.loadColumn(upnp ? upnpBrowser : directoryBrowser, itemObject.name, itemObject, props)
                }
            }

            model: modelList
        }
    }

    SystemsModel { id: deviceModel; systemId: Container.IdMultimediaDevice; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: modelList
        containers: [deviceModel.systemUii]
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1
    }

    Component {
        id: directoryBrowser
        ColumnBrowserDirectoryModel {
            onSelected: {
                if (column.isCard) {
                    if (column._isStock)
                        column.dataModel.cardImage = item.path
                    else
                        Stack.pushPage("NewImageCard.qml", {"containerWithCard": column.dataModel, fullImage: item.path})
                }
                else {
                    column.dataModel.image = global.saveInCustomDirIfNeeded(item.path, "bg_" + column.dataModel.uii, Qt.size(global.mainWidth, global.mainHeight))
                }
            }
        }
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {
            onSelected: {
                if (column.isCard)
                    Stack.pushPage("NewImageCard.qml", {"containerWithCard": column.dataModel, fullImage: item.path})
                else
                    column.dataModel.image = global.saveInCustomDirIfNeeded(item.path, "bg_" + column.dataModel.uii, Qt.size(global.mainWidth, global.mainHeight))
            }
        }
    }
}
