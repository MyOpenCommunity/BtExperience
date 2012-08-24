import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/RoomView.js" as Script


Item {
    id: roomView

    property variant model: undefined
    property variant pageObject: undefined

    signal focusLost // to signal to menu when menu focus is lost

    Rectangle {
        id: darkRect

        anchors.fill: parent
        color: "black"
        opacity: 0
        radius: 20

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (darkRect.state === "menuHighlighted")
                    privateProps.unselectObj()
                else
                    privateProps.closeMenu()
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: darkRect
                    opacity: 0.6
                }
            },
            State {
                name: "menuOpened"
                extend: "shown"
            },
            State {
                name: "menuHighlighted"
                extend: "shown"
            }
        ]
    }

    function startMove(container) {
        privateProps.unselectObj()

        bgMoveGrid.selectedItem = container
        bgMoveGrid.state = "shown"
    }

    /* private implementation */
    Component {
        id: roomItemComponent

        RoomItem {
            id: roomItem

            // if I click on the background around the menu item, focus is lost
            Connections {
                target: roomView
                // please note that this focusLost call refers to the delegating
                // function inside RoomItem.qml, it is not a call to the signal
                // defined here
                onFocusLost: roomItem.focusLost()
            }
        }
    }

    Component {
        id: itemComponent

        MenuContainer {
            id: container

            property alias xAnimation: xAnim
            property alias yAnimation: yAnim

            width: 500
            rootColumn: roomItemComponent
            onRootColumnClicked: {
                if (container.state === "highlight")
                    return

                container.state = "opened"
                roomView.state = "menuOpened"
                privateProps.currentMenu = container
            }

            Connections {
                target: container.rootObject
                onRequestMove: {
                    startMove(container)
                }
                onRequestSelect: {
                    if (container.state === "opened")
                        return

                    privateProps.currentMenu = container
                    roomView.state = "menuHightlighted"
                    container.state = "highlight"
                    container.rootObject.select()
                }
                ignoreUnknownSignals: true
            }

            NumberAnimation { id: xAnim; target: container; property: "x"; duration: 400; easing.type: Easing.InSine }
            NumberAnimation { id: yAnim; target: container; property: "y"; duration: 400; easing.type: Easing.InSine }

            states: [
                State {
                    name: "opened"
                    PropertyChanges {
                        target: container
                        x: 0
                        y: 0
                        z: 10
                        // TODO: hardcoded and copied from SystemPage, to be fixed
                        width: 893 //- backButton.width - containerLeftMargin
                        height: 530
                    }
                },
                State {
                    name: "highlight"
                    PropertyChanges {
                        target: container
                        z: 10
                    }
                }
            ]

            transitions: [
                Transition {
                    from: ""
                    to: "opened"
                    NumberAnimation { targets: container; properties: "x, y"; duration: 400 }
                },
                Transition {
                    from: "opened"
                    to: ""
                    SequentialAnimation {
                        NumberAnimation { targets: container; properties: "x, y"; duration: 400 }
                        ScriptAction {
                            script: privateProps.closingTransitionChanged()
                        }
                    }
                }
            ]
        }
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
                privateProps.updateView()
            }
            else {
                if (roomView.state === "menuOpened") {
                    privateProps.closeMenu()
                    Script.modelChanged = true
                }
                else {
                    privateProps.unselectObj()
                    privateProps.updateView()
                }
            }
        }
    }

    Constants {
        id: constants
    }

    MoveGrid {
        id: bgMoveGrid

        function moveTo(absX, absY) {
            // we want the MenuContainer to go exactly on the top-left corner
            // of the rectangle we clicked, so we need to exclude the title height
            // from the container.
            var itemPos = roomView.mapFromItem(null, absX, absY - constants.navbarTopMargin)
            bgMoveGrid.selectedItem.xAnimation.to = itemPos.x
            bgMoveGrid.selectedItem.yAnimation.to = itemPos.y
            bgMoveGrid.selectedItem.xAnimation.start()
            bgMoveGrid.selectedItem.yAnimation.start()
            // TODO: save the new position in the model
            //                            bgMoveGrid.selectedItem.itemObject.position = Qt.point(absPos.x, absPos.y)
        }

        gridRightMargin: 250 // TODO: roomItem.width + edit column
        gridBottomMargin: 50 // TODO: roomItem.height
        anchors.fill: parent
        z: roomView.z + 2 // must be on top of quicklinks
        onMoveEnd: {
            bgMoveGrid.selectedItem.state = ""
            bgMoveGrid.state = ""
        }
    }

    QtObject {
        id: privateProps

        property variant currentMenu: undefined

        function unselectObj() {
            privateProps.currentMenu.state = ""
            privateProps.currentMenu = undefined
            roomView.state = ""
            roomView.focusLost()
        }

        function closeMenu() {
            if (privateProps.currentMenu !== undefined)
            {
                privateProps.currentMenu.closeAll()
                privateProps.currentMenu.state = ""
                roomView.state = ""
                privateProps.currentMenu = undefined
            }
        }

        function closingTransitionChanged() {
            if (Script.modelChanged === true) {
                privateProps.updateView()
            }
        }

        function updateView() {
            privateProps.clearObjects()
            privateProps.createObjects()
            Script.modelChanged = false
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
    }

    Component.onCompleted: {
        privateProps.createObjects()
    }

    states: [
        State {
            name: "menuOpened"
            PropertyChanges {
                target: darkRect
                state: "menuOpened"
                z: 9
            }
        },
        State {
            name: "menuHightlighted"
            PropertyChanges {
                target: darkRect
                state: "menuHighlighted"
                z: 9
            }
        }
    ]
}
