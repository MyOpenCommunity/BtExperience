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
        paginator.currentIndex = -1
    }

    SystemsModel { id: deviceModel; systemId: Container.IdMultimediaDevice; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: modelList
        containers: [deviceModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Column {
        MenuItem {
            name: qsTr("Images")
            isSelected: privateProps.currentIndex === 1
            hasChild: true

            onTouched: {
                paginator.currentIndex = -1
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

        MenuItem {
            name: qsTr("Last used")
            isSelected: privateProps.currentIndex === 2
            hasChild: true

            onTouched: {
                paginator.currentIndex = -1
                privateProps.currentIndex = 2
                column._isStock = false
                var props = {
                    rootPath: isCard ? global.customCardImagesFolder : global.customBackgroundImagesFolder,
                    text: qsTr("Last used"),
                    upnp: false,
                    bgHeight: 422,
                    "paginator.elementsOnPage": 7,
                }
                column.loadColumn(directoryBrowser, qsTr("Last used"), undefined, props)
            }
        }

        PaginatorList {
            id: paginator
            currentIndex: -1

            delegate: MenuItemDelegate {
                itemObject: modelList.getObject(index)
                name: itemObject.name
                hasChild: true
                enabled: Script.mediaItemEnabled(itemObject)
                onEnabledChanged: column.closeChild()
                onDelegateTouched: {
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

            elementsOnPage: elementsOnMenuPage - 2
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
            onImageClicked: pageObject.installPopup(okCancelDialog, {"item": item})
        }
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {
            typeFilterEnabled: false
            filter: FileObject.Image | FileObject.Directory
            preview: true
            onImageClicked: pageObject.installPopup(okCancelDialog, {"item": item})
        }
    }

    Component {
        id: okCancelDialog

        TextDialog {
            property variant item

            title: qsTr("Confirm operation")
            text: qsTr("Do you want to change actual image with the one selected?")

            function okClicked() {
                var path = item.path + ""
                if (path.indexOf("file:///") === 0)
                    path = path.slice(7)

                if (column.isCard) {
                    if (column._isStock)
                        column.dataModel.cardImage = path
                    else
                        Stack.pushPage("NewImageCard.qml", {containerWithCard: column.dataModel, fullImage: path, newFilename: "custom_images/card/bg_" + column.dataModel.uii})
                }
                else if (column.homeCustomization) {
                    if (column._isStock)
                        homeProperties.homeBgImage = path
                    else
                        global.saveInCustomDirIfNeeded(homeProperties, "homeBgImage", path, "custom_images/background/home_bg", Qt.size(global.mainWidth, global.mainHeight))
                }
                else {
                    if (column._isStock) {
                        column.dataModel.image = path
                    }
                    else {
                        var newFilename = "custom_images/background/bg_" + column.dataModel.uii
                        global.saveInCustomDirIfNeeded(column.dataModel, "image", path, newFilename, Qt.size(global.mainWidth, global.mainHeight))
                    }
                }
            }
        }
    }
}
