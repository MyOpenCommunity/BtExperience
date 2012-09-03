import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMessages}]
    }

    Column {
        MenuItem {
            // TODO: this must be the number of *unread* messages
            property int numberOfMessages: messagesModel.count
            name: qsTr("inbox")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            onClicked: console.log("Show messages")
            boxInfoState: numberOfMessages > 0 ? "info" : ""
            boxInfoText: numberOfMessages

            MediaModel {
                id: messagesModel
                source: objectModel.getObject(0).messages
            }
        }

        MenuItem {
            name: qsTr("new message")
        }
    }
}
