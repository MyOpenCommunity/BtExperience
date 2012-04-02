import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: paginator.height

    PaginatorList {
        id: paginator
        width: parent.width
        listHeight: 50 * paginator.elementsOnPage
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            name: itemObject.name
            selectOnClick: true
            onDelegateClicked: {
                element.dataModel.preset = index + objectModel.range[0]
            }
        }

        model: objectModel
    }

    ObjectModel {
        id: objectModel
        source: element.dataModel.presets
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
