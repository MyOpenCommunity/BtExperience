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
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    PaginatorColumn {
        id: paginator

        MenuItem {
            name: qsTr("Rename")
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                pageObject.installPopup(quicklinkEditComponent)
                pageObject.popupLoader.item.favoriteItem = column.dataModel
            }
        }

        MenuItem {
            name: qsTr("Delete")
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                quicklinksModel.remove(column.dataModel)
                column.closeColumn()
            }
        }
    }

    Connections {
        target: pageObject.popupLoader.item
        onClosePopup: column.closeColumn()
    }

    Component {
        id: quicklinkEditComponent
        FavoriteEditPopup {}
    }
}
