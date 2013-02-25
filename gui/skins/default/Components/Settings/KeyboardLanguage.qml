import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    signal keyboardLayoutChanged(string config)

    ObjectModelSource {
        id: listSourceModel
    }

    ObjectModel {
        id: listModel
        source: listSourceModel.model
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Component.onCompleted: listSourceModel.init(global.keyboardLayouts)

    PaginatorList {
        id: paginator
        currentIndex: -1
        onCurrentPageChanged: column.closeChild()
        delegate: MenuItemDelegate {
            itemObject: listModel.getObject(index)
            name: pageObject.names.get('KEYBOARD', itemObject.name)
            hasChild: false
            onClicked: keyboardLayoutChanged(itemObject.name)
        }
        model: listModel
    }
}
