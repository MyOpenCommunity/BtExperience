import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: profilesModel
        source: myHomeModels.profiles
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: paginator.currentIndex = -1

    PaginatorList {
        id: paginator

        model: profilesModel
        onCurrentPageChanged: column.closeChild()

        delegate: MenuItemDelegate {
            itemObject: profilesModel.getObject(index)
            hasChild: true
            name: itemObject.description
            onClicked: {
                column.loadColumn(settingsProfileComponent, itemObject.description, itemObject)
            }
        }
    }

    Component {
        id: settingsProfileComponent
        SettingsProfile {}
    }
}
