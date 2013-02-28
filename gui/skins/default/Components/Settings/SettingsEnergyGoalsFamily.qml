import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: dataModel.objectKey}]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            itemObject: energiesCounters.getObject(index)
            hasChild: true
            onDelegateTouched: column.loadColumn(thresholdsComponent, itemObject.name, itemObject)
        }

        onCurrentPageChanged: column.closeChild()
        model: energiesCounters
    }

    Component {
        id: thresholdsComponent
        SettingsEnergyGoalsLine {

        }
    }
}
