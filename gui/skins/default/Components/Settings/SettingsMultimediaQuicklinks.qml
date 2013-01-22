import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    ObjectModel {
        id: quicklinksModel
        source: myHomeModels.mediaLinks
        containers: [column.dataModel.uii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Component {
        id: renameDeleteItem
        SettingsHomeDelete { uii: column.dataModel.uii }
    }

    Column {
        MenuItem {
            name: qsTr("Add Quicklink")
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                Stack.pushPage("AddQuicklink.qml")
            }
        }

        PaginatorList {
            id: paginator
            currentIndex: -1
            onCurrentPageChanged: column.closeChild()
            delegate: MenuItemDelegate {
                id: delegate
                editable: true
                itemObject: quicklinksModel.getObject(index)
                hasChild: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    column.loadColumn(renameDeleteItem, name, itemObject)
                }
            }
            model: quicklinksModel
        }
    }
}
