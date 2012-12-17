import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator
        delegate: MenuItemDelegate {
            itemObject: energiesCounters.getObject(index)
            hasChild: true
            onClicked: column.loadColumn(goalsLineComponent, itemObject.name, itemObject)
        }

        onCurrentPageChanged: column.closeChild()
        model: energiesCounters
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyFamily}]
    }

    Component {
        id: goalsLineComponent
        SettingsEnergyGoalsFamily {

        }
    }
}
