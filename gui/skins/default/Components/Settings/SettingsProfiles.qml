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

    // redefined to implement menu navigation
    function openMenu(navigationTarget, navigationData) {
        if (navigationTarget === "Profile") {
            var absIndex = column.absoluteIndexInModel(profilesModel, navigationData)
            if (absIndex === -1)
                return -3 // profile not found
            var indexes = paginator.getIndexesInPaginator(absIndex)
            paginator.openDelegate(indexes)
            return 0
        }
        return -2 // wrong target
    }

    PaginatorList {
        id: paginator

        model: profilesModel
        onCurrentPageChanged: column.closeChild()

        delegate: MenuItemDelegate {
            itemObject: profilesModel.getObject(index)
            hasChild: true
            name: itemObject.description
            onClicked: paginator.openDelegate([currentPage, index])
        }

        function openDelegate(indexes) {
            currentPage = indexes[0]
            currentIndex = indexes[1]
            var itemObject = profilesModel.getObject(currentIndex)
            column.loadColumn(settingsProfileComponent, itemObject.description, itemObject)
        }
    }

    Component {
        id: settingsProfileComponent
        SettingsProfile {}
    }
}
