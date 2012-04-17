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
        id: systemsButton
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: toolbar.bottom
        anchors.topMargin: 30
        onClicked: Stack.popPage()
    }


    Component {
        id: itemComponent
        MenuContainer {
            id: container
            width: 500
            rootElement: "Components/RoomItem.qml"
            onRootElementClicked: {
                container.state = "selected"
                menuSelected(container)
            }

            states: [
                State {
                    name: "selected"
                    PropertyChanges {
                        target: container
                        // TODO: hardcoded and copied from SystemPage, to be fixed
                        x: 122 //+ backButton.width + containerLeftMargin
                        y: 63
                        z: 10
                        width: 893 //- backButton.width - containerLeftMargin
                        height: 530
                    }
                }
            ]
        }
    }

    QtObject {
        id: privateProps
        property variant currentMenu: undefined
    }

    function menuSelected(menuContainer) {
        page.state = "menuSelected"
        privateProps.currentMenu = menuContainer
    }

    Component.onCompleted: {
        var positions = [{'x': 100, 'y': 100}, {'x': 200, 'y': 400}, {'x': 400, 'y': 200}, {'x': 400, 'y': 100}, {'x': 100, 'y': 300}, {'x': 200, 'y': 250}]

        for (var i = 0; i < objectList.size; ++i) {
            var object = itemComponent.createObject(page, {"rootData": objectList.getObject(i), 'x': positions[i].x + (i * 10), 'y': positions[i].y, "pageObject": page})
        }
    }


    ObjectModel {
        id: objectList
        filters: [
            {objectId: ObjectInterface.IdLight, objectKey: "13"},
            {objectId: ObjectInterface.IdSoundAmplifier},
            {objectId: ObjectInterface.IdPowerAmplifier},
            {objectId: ObjectInterface.IdThermalControlUnit99}
        ]
    }

    // An ugly workaround: the ObjectModel and the underlying FilterListModel is not
    // populated unless the model is used in a View item.
    ListView {
        visible: false
        delegate: Item {}
        model: objectList
    }

    ListView {
        id: roomView
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

    function closeCurrentMenu() {
        privateProps.currentMenu.closeAll()
        privateProps.currentMenu.state = ""
        page.state = ""
        privateProps.currentMenu = undefined
    }

    Rectangle {
        id: darkRect
        anchors {
            left: systemsButton.right
            leftMargin: 20
            right: parent.right
            rightMargin: 20
            top: toolbar.bottom
            bottom: roomView.top
        }
        color: "black"
        opacity: 0
        radius: 20

        MouseArea {
            anchors.fill: parent
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Rectangle {
            border.color: "white"
            border.width: 2
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 10
            width: 30
            height: 30
            radius: 30
            color: parent.color

            Text {
                anchors.centerIn: parent
                text: "X"
                color: "white"
                font.pointSize: 12
            }

            MouseArea {
                anchors.fill: parent
                onClicked: page.closeCurrentMenu()
            }
        }
    }

    MouseArea {
        id: outerClickableArea
        visible: false
        anchors {
            left: parent.left
            right: parent.right
            top: toolbar.bottom
            bottom: roomView.top
        }

        onClicked: page.closeCurrentMenu()
    }

    states: [
        State {
            name: "menuSelected"
            PropertyChanges {
                target: darkRect
                opacity: 0.6
                z: 9
            }
            PropertyChanges {
                target: outerClickableArea
                visible: true
            }
        }
    ]
}
