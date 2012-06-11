import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/RoomView.js" as Script


// Implementation of custom room view
Item {
    id: roomView
    property variant model: undefined
    property variant pageObject: undefined

    signal menuOpened
    signal menuClosed

    function closeMenu() {
        if (privateProps.currentMenu !== undefined)
        {
            privateProps.currentMenu.closeAll()
            privateProps.currentMenu.state = ""
            roomView.state = ""
            privateProps.currentMenu = undefined
        }
    }


    /* private implementation */
    Component {
        id: roomItem
        RoomItem {}
    }

    Component {
        id: itemComponent
        MenuContainer {
            id: container
            width: 500
            rootColumn: roomItem
            onRootColumnClicked: {
                container.state = "selected"
                roomView.state = "menuSelected"
                privateProps.currentMenu = container
                menuOpened()
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

            transitions: [
                Transition {
                    from: ""
                    to: "selected"
                    NumberAnimation { targets: container; properties: "x, y"; duration: 400 }
                },
                Transition {
                    from: "selected"
                    to: ""
                    SequentialAnimation {
                        NumberAnimation { targets: container; properties: "x, y"; duration: 400 }
                        ScriptAction {
                            script: closingTransitionChanged()
                        }
                    }
                }
            ]
        }
    }

    function closingTransitionChanged() {
        if (Script.modelChanged === true) {
            updateView()
        }
    }

    function updateView() {
        clearObjects()
        createObjects()
        Script.modelChanged = false
    }

    QtObject {
        id: privateProps
        property variant currentMenu: undefined
    }

    Connections {
        target: model
        onModelReset: {
            // TODO: maybe we can optimize performance by setting opacity to 0
            // for items that we don't want to show, thus avoiding a whole
            // createObject()/destroy() cycle each time
            // Anyway, this needs a more complex management and performance gains
            // must be measurable.
            if (privateProps.currentMenu === undefined) {
                updateView()
            }
            else {
                closeMenu()
                Script.modelChanged = true
            }
        }
    }

    function clearObjects() {
        var len = Script.obj_array.length
        for (var i = 0; i < len; ++i)
            Script.obj_array.pop().destroy()
    }

    function createObjects() {
        for (var i = 0; i < model.count; ++i) {
            var obj = model.getObject(i);
            var y = obj.position.y
            var x = obj.position.x
            var object = itemComponent.createObject(roomView, {"rootData": obj.btObject, 'x': x, 'y': y, 'pageObject': pageObject})
            Script.obj_array.push(object)
        }
    }

    Component.onCompleted: {
        createObjects()
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

            UbuntuLightText {
                anchors.centerIn: parent
                text: "X"
                color: "white"
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    roomView.closeMenu()
                    menuClosed()
                }
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
