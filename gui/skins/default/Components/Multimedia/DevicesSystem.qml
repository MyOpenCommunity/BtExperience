import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

import "../../js/Stack.js" as Stack
import "../../js/MediaItem.js" as Script


MenuColumn {
    id: column

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    SystemsModel { id: deviceModel; systemId: Container.IdMultimediaDevice; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: modelList
        containers: [deviceModel.systemUii]
    }

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            name: itemObject.name
            hasChild: true
            enabled: Script.mediaItemEnabled(itemObject)
            onEnabledChanged: column.closeChild()
            onDelegateClicked: {
                var upnp = itemObject.sourceType === SourceObject.Upnp;
                var props = {
                    rootPath: itemObject.rootPath,
                    upnp: upnp
                }
                column.loadColumn(upnp ? upnpBrowser : directoryBrowser, itemObject.name, itemObject, props)
            }
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    Component {
        id: directoryBrowser
        ColumnBrowserDirectoryModel {
            onImageClicked: Stack.goToPage("PhotoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
            onAudioClicked: Stack.goToPage("AudioVideoPlayer.qml", {"model": theModel, "index": index, "isVideo": false, "upnp": upnp})
            onVideoClicked: Stack.goToPage("AudioVideoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
        }
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {
            onImageClicked: Stack.goToPage("PhotoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
            onAudioClicked: Stack.goToPage("AudioVideoPlayer.qml", {"model": theModel, "index": index, "isVideo": false, "upnp": upnp})
            onVideoClicked: Stack.goToPage("AudioVideoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
        }
    }
}
