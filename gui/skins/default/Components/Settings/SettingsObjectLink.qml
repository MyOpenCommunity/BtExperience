import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    property int uii
    property int index

    MediaModel {
        id: objectLinksModel
        source: myHomeModels.objectLinks
        containers: [uii]
    }

    Column {
        MenuItem {
            name: qsTr("Rename")
            onTouched: {
                pageObject.installPopup(quicklinkEditComponent, {"item": objectLinksModel.getObject(index).btObject})
            }
        }

        MenuItem {
            name: qsTr("Delete")
            onTouched: pageObject.installPopup(deleteConfirmDialog)
        }
    }

    Connections {
        target: pageObject.popupLoader.item
        onClosePopup: column.closeColumn()
    }

    Component {
        id: quicklinkEditComponent
        FavoriteEditPopup {
            property variant item

            title: qsTr("Change MyHome object name")
            topInputLabel: qsTr("New Name:")
            topInputText: objectLinksModel.getObject(index).btObject.name
            bottomVisible: false

            function okClicked() {
                item.name = topInputText
            }
        }
    }

    Component {
        id: deleteConfirmDialog
        TextDialog {
            function okClicked() {
                objectLinksModel.remove(objectLinksModel.getObject(index))
            }

            title: qsTr("Confirm deletion")
            text: qsTr("Are you sure to delete the selected MyHome object?")
        }
    }
}
