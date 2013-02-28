import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    ObjectModel {
        id: quicklinksModel
        source: myHomeModels.mediaLinks
        containers: [myHomeModels.homepageLinks.uii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    Component {
        id: renameDeleteItem
        SettingsHomeDelete {}
    }

    Column {
        MenuItem {
            name: qsTr("Add Quicklink")
            enabled: quicklinksModel.count < 7
            onTouched: {
                column.closeChild()
                Stack.pushPage("AddQuicklink.qml", {"homeCustomization": true})
            }
        }

        PaginatorList {
            id: paginator
            currentIndex: -1
            onCurrentPageChanged: column.closeChild()
            elementsOnPage: elementsOnMenuPage - 1
            delegate: MenuItemDelegate {
                editable: true
                itemObject: quicklinksModel.getObject(index)
                name: itemObject.name
                hasChild: true
                onDelegateClicked: {
                    column.loadColumn(renameDeleteItem, name, itemObject)
                }
            }
            model: quicklinksModel
        }
    }
}
