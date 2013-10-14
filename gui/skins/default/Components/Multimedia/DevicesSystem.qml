import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

import "../../js/Stack.js" as Stack
import "../../js/MediaItem.js" as Script


MenuColumn {
    id: column

    property bool restoreBrowserState

    onChildDestroyed: {
        pagList.currentIndex = -1
    }

    SystemsModel { id: deviceModel; systemId: Container.IdMultimediaDevice; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: modelList
        containers: [deviceModel.systemUii]
        range: pagList.computePageRange(pagList.currentPage, pagList.elementsOnPage)
    }

    PaginatorList {
        id: pagList
        currentIndex: -1

        property QtObject restoredItem

        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            name: itemObject.name
            hasChild: true
            enabled: Script.mediaItemEnabled(itemObject, restoredItem)
            onEnabledChanged: if (!Script.mediaItemMounted(itemObject)) column.closeChild()
            onDelegateTouched: pagList.tryOpenColumn(itemObject, false)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()

        function _openColumn(itemObject, restoreState) {
            var upnp = itemObject.sourceType === SourceObject.Upnp;
            var props = {
                rootPath: itemObject.rootPath,
                restoreState: restoreState,
                upnp: upnp
            }
            column.loadColumn(upnp ? upnpBrowser : directoryBrowser, itemObject.name, itemObject, props)
        }

        function tryOpenColumn(itemObject, restoreState) {
            if (itemObject.sourceType === SourceObject.Upnp && global.upnpPlaying && itemObject !== restoredItem) {
                pageObject.installPopup(upnpDialog)
            }
            else {
                _openColumn(itemObject, restoreState)
            }
        }

        function restoreBrowserState() {
            for (var i = 0; i < modelList.count; ++i) {
                var itemObject = modelList.getObject(i)
                var is_upnp = itemObject.sourceType === SourceObject.Upnp

                if (global.audioVideoPlayer.matchesSavedState(is_upnp, itemObject.rootPath))
                {
                    restoredItem = itemObject
                    _openColumn(itemObject, true)
                    break
                }
            }
        }
    }

    Component {
        id: upnpDialog

        TextDialog {
            title: qsTr("UPnP is playing")
            text: qsTr("UPnP support is limited to only one active source. \
Please stop the source in sound diffusion section before continuing.")
            cancelVisible: false

            function okClicked() {
                pagList.currentIndex = -1
            }
        }
    }

    Component {
        id: directoryBrowser
        ColumnBrowserDirectoryModel {
            onImageClicked: Stack.pushPage("PhotoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
            onAudioClicked: Stack.pushPage("AudioPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
            onVideoClicked: Stack.pushPage("VideoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
        }
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {
            onImageClicked: Stack.pushPage("PhotoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
            onAudioClicked: Stack.pushPage("AudioPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
            onVideoClicked: Stack.pushPage("VideoPlayer.qml", {"model": theModel, "index": index, "upnp": upnp})
        }
    }

    Timer {
        id: delayRestore
        interval: 1
        repeat: false
        running: false
        onTriggered: pagList.restoreBrowserState()
    }

    Component.onCompleted: {
        if (restoreBrowserState)
            delayRestore.start()
    }
}
