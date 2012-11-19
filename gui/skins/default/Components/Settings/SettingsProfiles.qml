import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/navigationconstants.js" as NavigationConstants


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
            var absIndex = profilesModel.getAbsoluteIndexOf(navigationData)
            if (absIndex === -1)
                return NavigationConstants.NAVIGATION_PROFILE_NOT_FOUND
            var indexes = paginator.getIndexesInPaginator(absIndex)
            paginator.openDelegate(indexes)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
        return NavigationConstants.NAVIGATION_WRONG_TARGET
    }

    PaginatorList {
        id: paginator

        model: profilesModel
        onCurrentPageChanged: column.closeChild()

        delegate: MenuItemDelegate {
            itemObject: profilesModel.getObject(index)
            hasChild: true
            name: itemObject.description
            onClicked: openDelegate([currentPage, index])
        }

        function openDelegate(indexes) {
            paginator.goToPage(indexes[0])
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
