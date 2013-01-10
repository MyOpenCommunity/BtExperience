import QtQuick 1.1
import Components 1.0
import BtObjects 1.0

MenuColumn {
    id: column

    SystemsModel { id: linksModel; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: radioModel
        source: myHomeModels.mediaLinks
        containers: [linksModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        delegate: MenuItemDelegate {
            itemObject: radioModel.getObject(index)
            editable: true
            onDelegateClicked: {
                column.dataModel.startPlay(radios(radioModel), index, radioModel.count)
            }
        }

        model: radioModel
        onCurrentPageChanged: column.closeChild()
    }

    function radios(model) {
        var radios = []

        for (var i = 0; i < model.count; ++i)
            radios.push(model.getObject(i))

        return radios
    }
}
