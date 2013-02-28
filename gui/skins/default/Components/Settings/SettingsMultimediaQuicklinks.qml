import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: quicklinksModel
        source: myHomeModels.mediaLinks
        containers: [column.dataModel.uii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    Component {
        id: renameDeleteItem
        SettingsHomeDelete { uii: column.dataModel.uii }
    }

    PaginatorList {
        id: paginator
        currentIndex: -1
        onCurrentPageChanged: column.closeChild()
        delegate: MenuItemDelegate {
            id: delegate
            itemObject: quicklinksModel.getObject(index)
            hasChild: true
            editable: true
            onDelegateClicked: column.loadColumn(renameDeleteItem, name, itemObject)
        }
        model: quicklinksModel
    }
}
