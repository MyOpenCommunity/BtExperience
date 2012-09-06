import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    ObjectModel {
        // this must stay here otherwise messagesModel cannot be constructed properly
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMessages}]
    }

    MediaModel {
        // this must stay here for count call to work
        id: messagesModel
        source: objectModel.getObject(0).messages
    }

    Column {
        // in a MenuColumn we need a Column... :(
        MenuItem {
            // TODO: this must be the number of *unread* messages
            property int numberOfMessages: messagesModel.count
            name: qsTr("inbox")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            boxInfoState: numberOfMessages > 0 ? "info" : ""
            boxInfoText: numberOfMessages

            onClicked: column.loadColumn(columnMessages, qsTr("Received messages"))
        }

        MenuItem {
            name: qsTr("new message")

            onClicked: console.log("compose message")
        }
    }

    Component {
        id: columnMessages
        ColumnMessages {}
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }
}
