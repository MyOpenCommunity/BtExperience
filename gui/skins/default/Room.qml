import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0
import Components 1.0

Page {
    id: page
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

    Component {
        id: itemComponent
        MenuColumn {
            property variant itemObject
            MenuItem {
                name: itemObject.name
                status: itemObject.active === true ? 1 : 0
                hasChild: true
            }
        }
    }

    Component.onCompleted: {
        var positions = [{'x': 100, 'y': 100}, {'x': 200, 'y': 400}, {'x': 400, 'y': 200}]
        for (var i = 0; i < objectList.size; ++i) {
//            console.log('creating object: ' + objectList.getObject(i).name)
            var object = itemComponent.createObject(page, {"itemObject": objectList.getObject(i), 'x': positions[i].x + (i * 10), 'y': positions[i].y})
        }
    }


    ObjectModel {
        id: objectList
        filters: [{objectId: ObjectInterface.IdLight, objectKey: "13"},
                  {objectId: ObjectInterface.IdSoundSource}]
    }

    // An ugly workaround: the ObjectModel and the underlying FilterListModel is not
    // populated unless the model is used in a View item.
    ListView {
        visible: false
        delegate: Item {}
        model: objectList
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
