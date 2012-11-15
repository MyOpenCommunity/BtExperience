import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    property bool isCard: false

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            name: itemObject.name
            hasChild: true
            onDelegateClicked: {
                var upnp = itemObject.sourceType === SourceObject.Upnp;
                var props = {
                    rootPath: itemObject.rootPath,
                    text: itemObject.name,
                    upnp: upnp,
                    imageOnly: true,
                    filter: FileObject.Image | FileObject.Directory,
                    bgHeight: 422,
                    "paginator.elementsOnPage": 7
                }
                column.loadColumn(upnp ? upnpBrowser : directoryBrowser, itemObject.name, itemObject, props)
            }
        }

        model: modelList
    }

    SystemsModel { id: deviceModel; systemId: Container.IdMultimediaDevice; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: modelList
        containers: [deviceModel.systemUii]
    }

    Component {
        id: directoryBrowser
        ColumnBrowserDirectoryModel {
            onSelected: {
                if (column.isCard) {
                    Stack.pushPage("NewImageCard.qml", {"containerWithCard": column.dataModel, fullImage: item.path})
                }
                else {
                    column.dataModel.image = item.path
                }
            }
        }
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {
            onSelected: {
                if (column.isCard) {
                    Stack.pushPage("NewImageCard.qml", {"containerWithCard": column.dataModel, fullImage: item.path})
                }
                else {
                    column.dataModel.image = item.path
                }
            }
        }
    }
}
