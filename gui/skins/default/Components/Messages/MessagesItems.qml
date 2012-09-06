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

            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(columnMessages, qsTr("Received messages"))
            }
        }

        MenuItem {
            name: qsTr("new message")
            backgroundImage: "../../images/common/bg_automazioni.svg"
            MouseArea { // to avoid pressed effect
                anchors.fill: parent
            }
            ButtonImageThreeStates {
                id: newButton
                anchors {
                    right: parent.right
                    rightMargin: 7
                    top: parent.top
                    topMargin: 7
                }

                defaultImageBg: "../../images/common/btn_nuovo_messaggio.svg"
                pressedImageBg: "../../images/common/btn_nuovo_messaggio_P.svg"
                selectedImageBg: "../../images/common/btn_nuovo_messaggio_S.svg"
                shadowImage: "../../images/common/ombra_btn_nuovo_messaggio.svg"
                defaultImage: "../../images/common/ico_nuovo_messaggio.svg"
                pressedImage: "../../images/common/ico_nuovo_messaggio_P.svg"
                status: 0
                onClicked: {
                    privateProps.currentIndex = -1
                    column.closeChild()
                    console.log("compose message")
                }
            }
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
