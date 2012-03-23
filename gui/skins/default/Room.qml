import QtQuick 1.1
import "Stack.js" as Stack


Page {
    source: "images/imgsfondo_sfumato.png"

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }

    ButtonSystems {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: toolbar.bottom
        anchors.topMargin: 30
        onClicked: Stack.popPage()
    }

    ListView {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width
        height: 110

        orientation: ListView.Horizontal
        delegate: Image {
            source: model.selected ? "images/common/stanzaS.png" : "images/common/stanza.png"
            Image {
                source: model.image
                fillMode: Image.PreserveAspectCrop
                clip: true
                width: parent.width - (model.selected ? 30 : 20)
                height: parent.height - (model.selected ? 30 : 20)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        model: roomsModel

        ListModel {
            id: roomsModel

            ListElement {
                image: "images/rooms/studio.png"
                name: "studio"
                selected: false
            }
            ListElement {
                image: "images/rooms/box.png"
                name: "box"
                selected: false
            }
            ListElement {
                image: "images/rooms/cameretta.png"
                name: "camera ragazzi"
                selected: true
            }
            ListElement {
                image: "images/rooms/camera.png"
                name: "camera genitori"
                selected: false
            }
            ListElement {
                image: "images/rooms/bagno.png"
                name: "bagno zona giorno"
                selected: false
            }
            ListElement {
                image: "images/rooms/cucina.png"
                name: "cucina"
                selected: false
            }
            ListElement {
                image: "images/rooms/soggiorno.png"
                name: "soggiorno"
                selected: false
            }
        }
    }
}
