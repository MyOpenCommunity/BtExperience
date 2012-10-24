import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        delegate: MenuItemDelegate {
            itemObject: radioModel.getObject(index)
            editable: true
            onDelegateClicked: {
                column.dataModel.startPlay(radioUrls(radioModel), index, radioModel.count)
            }
        }

        model: radioModel
    }

    SystemsModel { id: linksModel; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: radioModel
        containers: [linksModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    function radioUrls(model) {
        var urls = []

        for (var i = 0; i < model.count; ++i)
            urls.push(model.getObject(i).path)

        return urls
    }
}
