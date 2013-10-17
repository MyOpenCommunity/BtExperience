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
        property variant savedItem
        property bool upnpStopped: false

        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            name: itemObject.name
            hasChild: true
            enabled: Script.mediaItemEnabled(itemObject, restoredItem)
            onEnabledChanged: if (!Script.mediaItemMounted(itemObject)) column.closeChild()
            onDelegateTouched: pagList.tryOpenColumn(itemObject)
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

        function tryOpenColumn(itemObject) {
            if (itemObject.sourceType === SourceObject.Upnp && global.upnpPlaying) {
                savedItem = itemObject
                pageObject.installPopup(upnpDialog)
            }
            else {
                _openColumn(itemObject, false)
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

    Connections {
        target: column.pageObject
        onPopupDismissed: {
            if (pagList.upnpStopped) {
                pagList.tryOpenColumn(pagList.savedItem)
                pagList.upnpStopped = false
            }
        }
    }

    Component {
        id: upnpDialog

        TextDialog {
            title: qsTr("Sound diffusion is playing")
            text: qsTr("UPnP support is limited to only one active source. \
The UPnP source is busy in sound diffusion. Do you want to stop the sound diffusion \
source?")

            function okClicked() {
                sourceModel.getObject(0).audioVideoPlayer.terminate()
                pagList.upnpStopped = true
            }

            function cancelClicked() {
                pagList.currentIndex = -1
            }

            ObjectModel {
                id: sourceModel
                filters: [{objectId: ObjectInterface.IdSoundSource, objectKey: SourceObject.Upnp}]
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
