import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    SystemsModel {
        id: browser
        systemId: Container.IdMultimediaBrowser
        source: myHomeModels.mediaContainers
    }

    ObjectModel {
        id: browserLink
        source: myHomeModels.mediaLinks
        containers: [browser.systemUii]
    }

    SystemsModel {
        id: weblinks
        systemId: Container.IdMultimediaWebLink
        source: myHomeModels.mediaContainers
    }

    SystemsModel {
        id: webcams
        systemId: Container.IdMultimediaWebCam
        source: myHomeModels.mediaContainers
    }

    SystemsModel {
        id: rsslinks
        systemId: Container.IdMultimediaRss
        source: myHomeModels.mediaContainers
    }

    SystemsModel {
        id: rssmeteolinks
        systemId: Container.IdMultimediaRssMeteo
        source: myHomeModels.mediaContainers
    }

    SystemsModel {
        id: webradiolinks
        systemId: Container.IdMultimediaWebRadio
        source: myHomeModels.mediaContainers
    }

    ObjectModel {
        id: quicklinksModel
        source: myHomeModels.mediaContainers
        containers: [
            weblinks.systemUii,
            webcams.systemUii,
            rsslinks.systemUii,
            rssmeteolinks.systemUii,
            webradiolinks.systemUii
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Column {
        MenuItem {
            name: qsTr("Add Quicklink")
            onClicked: {
                if (privateProps.currentIndex !== 2) {
                    privateProps.currentIndex = 2
                    if (column.child)
                        column.closeChild()
                    paginator.currentIndex = -1
                }
                Stack.pushPage("AddQuicklink.qml", { onlyQuicklinks: true })
            }
        }

        MenuItem {
            name: qsTr("Browser")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            visible: browserLink.count > 0
            onClicked: {
                paginator.currentIndex = -1
                privateProps.currentIndex = 1
                column.loadColumn(browserComponent, name)
            }
        }

        PaginatorList {
            id: paginator

            elementsOnPage: elementsOnMenuPage - 2
            currentIndex: -1
            onCurrentPageChanged: column.closeChild()
            delegate: MenuItemDelegate {
                itemObject: quicklinksModel.getObject(index)
                name: itemObject.description
                hasChild: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    column.loadColumn(multimediaComponent, name, itemObject)
                }
            }
            model: quicklinksModel
        }
    }

    Component {
        id: multimediaComponent
        SettingsMultimediaQuicklinks {}
    }

    Component {
        id: browserComponent
        SettingsBrowser {}
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
        paginator.currentIndex = -1
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }
}
