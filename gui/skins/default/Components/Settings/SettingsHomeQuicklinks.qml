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
        SettingsHomeDelete {}
    }

    Column {
        MenuItem {
            name: qsTr("Add Quicklink")
            isSelected: privateProps.currentIndex === 1
            enabled: quicklinksModel.count < 7
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.closeChild()
                Stack.pushPage("AddQuicklink.qml", {"homeCustomization": true})
            }
        }

        PaginatorList {
            id: paginator
            currentIndex: -1
            onCurrentPageChanged: column.closeChild()
            delegate: MenuItemDelegate {
                editable: true
                itemObject: quicklinksModel.getObject(index)
                name: itemObject.name
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
