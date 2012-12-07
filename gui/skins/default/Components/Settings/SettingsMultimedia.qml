import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

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

    PaginatorList {
        id: paginator

        currentIndex: -1
        onCurrentPageChanged: closeChild()
        delegate: MenuItemDelegate {
            itemObject: quicklinksModel.getObject(index)
            name: itemObject.description
            hasChild: true
            onDelegateClicked: column.loadColumn(multimediaComponent, name, itemObject)
        }
        model: quicklinksModel
    }

    Component {
        id: multimediaComponent
        SettingsMultimediaQuicklinks {}
    }
}
