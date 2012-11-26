import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

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
            itemObject: modelList.getObject(index)
            name: itemObject.name
            hasChild: true
            enabled: itemObject.mountPoint.mounted
            onDelegateClicked: {
                var upnp = itemObject.sourceType === SourceObject.Upnp;
                var props = {
                    rootPath: itemObject.rootPath,
                    text: itemObject.name,
                    upnp: upnp
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
        ColumnBrowserDirectoryModel {}
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {}
    }
}
