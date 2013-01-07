import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    property int uii: myHomeModels.homepageLinks.uii

    ObjectModel {
        id: quicklinksModel
        source: myHomeModels.mediaLinks
        containers: [uii]
    }

    Column {
        MenuItem {
            name: qsTr("Rename")
            onClicked: {
                pageObject.installPopup(quicklinkEditComponent)
                pageObject.popupLoader.item.favoriteItem = column.dataModel
            }
        }

        MenuItem {
            name: qsTr("Delete")
            onClicked: {
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
