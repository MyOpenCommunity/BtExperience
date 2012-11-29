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
            name: qsTr("Delete")
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                quicklinksModel.remove(column.dataModel)
                column.closeColumn()
            }
        }
     }
}
