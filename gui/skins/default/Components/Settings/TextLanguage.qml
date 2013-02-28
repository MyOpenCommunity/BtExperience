import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0

MenuColumn {
    id: column

    signal textLanguageChanged(string config)

    ObjectModelSource {
        id: listSourceModel
    }

    ObjectModel {
        id: listModel
        source: listSourceModel.model
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Component.onCompleted: listSourceModel.init(global.guiSettings.languages)

    PaginatorList {
        id: paginator
        currentIndex: -1
        onCurrentPageChanged: column.closeChild()
        delegate: MenuItemDelegate {
            itemObject: listModel.getObject(index)
            name: pageObject.names.get('LANGUAGE', itemObject.name)
            hasChild: false
            onDelegateTouched: textLanguageChanged(itemObject.name)
        }
        model: listModel
    }
}
