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

    QtObject {
        id: privateProps
        property variant currentMenu: undefined
    }

    function menuSelected(menuContainer) {
        page.state = "menuSelected"
        privateProps.currentMenu = menuContainer
    }

    ObjectModel {
        id: roomModel
        filters: [{objectId: ObjectInterface.IdRoom}]
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

    RoomView {
        id: roomCustomView
        anchors {
            left: systemsButton.right
            leftMargin: 20
            right: parent.right
            rightMargin: 20
            top: toolbar.bottom
            bottom: roomView.top
        }
        model: roomModel
        onMenuSelected: page.menuSelected(container)
        onMenuClosed: page.closeCurrentMenu()
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
        roomCustomView.state = ""
        privateProps.currentMenu = undefined
    }

    states: [
        State {
            name: "menuSelected"
            PropertyChanges {
                target: outerClickableArea
                visible: true
            }
        }
    ]
}
