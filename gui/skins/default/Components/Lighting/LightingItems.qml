import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    width: 212
    height: paginator.height

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: objectModel.count > elementsOnPage ? elementsOnPage * 50 : objectModel.count * 50

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            editable: true

            status: itemObject.active === true ? 1 : 0
            hasChild: true
            boxInfoState: {
                if(itemObject.objectId === ObjectInterface.IdLight)
                    return ""
                // Dimmer10 and Dimmer100
                return "info"
            }
            boxInfoText: {
                if(itemObject.objectId === ObjectInterface.IdLight)
                    return ""
                // Dimmer10 and Dimmer100
                if(itemObject.active)
                    return itemObject.percentage + "%"
                return "-"
            }

            onClicked: {
                column.loadColumn(
                            mapping.getComponent(itemObject.objectId),
                            itemObject.name,
                            objectModel.getObject(model.index))
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: objectModel
        source: myHomeModels.myHomeObjects
        containers: [Container.IdLights]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
