import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

import "../../js/Stack.js" as Stack
import "../../js/MediaItem.js" as Script


MenuColumn {
    id: column

    property bool isCard: false
    property bool homeCustomization: false
    property bool _isStock: false // used internally to know if user selected a stock image

    onChildDestroyed: {
        privateProps.currentIndex = -1
        itemList.currentIndex = -1
    }

    SystemsModel { id: deviceModel; systemId: Container.IdMultimediaDevice; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: modelList
        containers: [deviceModel.systemUii]
    }

    Column {
        MenuItem {
            name: qsTr("Images")
            isSelected: privateProps.currentIndex === 1
            hasChild: true

            onClicked: {
                itemList.currentIndex = -1
                privateProps.currentIndex = 1
                column._isStock = true
                var props = {
                    rootPath: isCard ? global.stockCardImagesFolder : global.stockBackgroundImagesFolder,
                    text: qsTr("Images"),
                    upnp: false,
                    bgHeight: 422,
                    "paginator.elementsOnPage": 7,
                }
                column.loadColumn(directoryBrowser, qsTr("Images"), undefined, props)
            }
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
                    privateProps.currentIndex = -1
                    column._isStock = false
                    var upnp = itemObject.sourceType === SourceObject.Upnp;
                    var props = {
                        rootPath: itemObject.rootPath,
                        upnp: upnp,
                        bgHeight: 422,
                        "paginator.elementsOnPage": 7,
                    }
                    column.loadColumn(upnp ? upnpBrowser : directoryBrowser, itemObject.name, itemObject, props)
                }
            }

            model: modelList
            onCurrentPageChanged: column.closeChild()
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1
    }

    Component {
        id: directoryBrowser
        ColumnBrowserDirectoryModel {
            typeFilterEnabled: false
            filter: FileObject.Image | FileObject.Directory
            preview: true
            onImageClicked: pageObject.installPopup(okCancelDialogLocal, {"item": item})
        }
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {
            typeFilterEnabled: false
            filter: FileObject.Image | FileObject.Directory
            preview: true
            onImageClicked: pageObject.installPopup(okCancelDialogUpnp, {"item": item})
        }
    }

    Component {
        id: okCancelDialogLocal

        TextDialog {
            property variant item

            title: qsTr("Confirm operation")
            text: qsTr("Do you want to change actual image with the one selected?")

            function okClicked() {
                if (column.isCard) {
                    if (column._isStock)
                        column.dataModel.cardImage = item.path
                    else
                        Stack.pushPage("NewImageCard.qml", {"containerWithCard": column.dataModel, fullImage: item.path})
                }
                else if (column.homeCustomization) {
                    global.saveInCustomDirIfNeeded(homeProperties, "homeBgImage", item.path, "home_bg", Qt.size(global.mainWidth, global.mainHeight))
                }
                else {
                    global.saveInCustomDirIfNeeded(column.dataModel, "image", item.path, "bg_" + column.dataModel.uii, Qt.size(global.mainWidth, global.mainHeight))
                }
            }
        }
    }

    Component {
        id: okCancelDialogUpnp

        TextDialog {
            property variant item

            title: qsTr("Confirm operation")
            text: qsTr("Do you want to change actual image with the one selected?")

            function okClicked() {
                if (column.isCard)
                    Stack.pushPage("NewImageCard.qml", {"containerWithCard": column.dataModel, fullImage: item.path})
                else if (column.homeCustomization)
                    global.saveInCustomDirIfNeeded(homeProperties, "homeBgImage", item.path, "home_bg", Qt.size(global.mainWidth, global.mainHeight))
                else
                    global.saveInCustomDirIfNeeded(column.dataModel, "image", item.path, "bg_" + column.dataModel.uii, Qt.size(global.mainWidth, global.mainHeight))
            }
        }
    }
}
