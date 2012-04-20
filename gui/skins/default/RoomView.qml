import QtQuick 1.1
import Components 1.0

// Implementation of custom room view
Item {
    id: roomView
    property variant model: undefined

    signal menuSelected(variant container)
    signal menuClosed

    Component {
        id: itemComponent
        MenuContainer {
            id: container
            width: 500
            rootElement: "Components/RoomItem.qml"
            onRootElementClicked: {
                container.state = "selected"
                roomView.state = "menuSelected"
                menuSelected(container)
            }

            states: [
                State {
                    name: "selected"
                    PropertyChanges {
                        target: container
                        x: 0
                        y: 0
                        z: 10
                        // TODO: hardcoded and copied from SystemPage, to be fixed
                        width: 893 //- backButton.width - containerLeftMargin
                        height: 530
                    }
                }
            ]
        }
    }

    Component.onCompleted: {
        for (var i = 0; i < model.size; ++i)
        {
            var obj = model.getObject(i);
            var y = obj.position.y
            var x = obj.position.x
            // TODO: pageObject, how to pass it around?
            var object = itemComponent.createObject(roomView, {"rootData": obj.btObject, 'x': x, 'y': y})
        }
    }

    Rectangle {
        id: darkRect
        anchors.fill: parent
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
                onClicked: menuClosed()
            }
        }
    }

    states: [
        State {
            name: "menuSelected"
            PropertyChanges {
                target: darkRect
                opacity: 0.6
                z: 9
            }
        }
    ]
}
