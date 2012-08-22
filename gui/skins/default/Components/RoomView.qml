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
                font.pixelSize: 16
            }

            MouseArea {
                anchors.fill: parent
                onClicked: privateProps.closeMenu()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: roomView.focusLost()
    }

    function startMove(container) {
        container.rootObject.focusLost()
        bgMoveGrid.selectedItem = container
        moveGrid.state = "shown"
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
            // if I click on this menu item, other menu items must lose focus
            onPressed: roomView.focusLost()
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
                container.state = "selected"
                roomView.state = "menuSelected"
                privateProps.currentMenu = container
            }

            Connections {
                target: container.rootObject
                onRequestMove: {
                    startMove(container)
                }
                ignoreUnknownSignals: true
            }

            NumberAnimation { id: xAnim; target: container; property: "x"; duration: 400; easing.type: Easing.InSine }
            NumberAnimation { id: yAnim; target: container; property: "y"; duration: 400; easing.type: Easing.InSine }

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
                privateProps.closeMenu()
                Script.modelChanged = true
            }
        }
    }

    Constants {
        id: constants
    }

    // This is to test the API of the move grid
    Connections {
        target: bgMoveGrid
        onMoveEnd: {
            moveGrid.state = ""
        }
    }



    Item {
        id: bgMoveGrid

        property int gridRightMargin: 250 // TODO: roomItem.width + edit column
        property int gridBottomMargin: 50 // TODO: roomItem.height
        property Item selectedItem: null

        signal moveEnd

        function moveTo(absX, absY) {
            // we want the MenuContainer to go exactly on the top-left corner
            // of the rectangle we clicked, so we need to exclude the title height
            // from the container.
            var itemPos = roomView.mapFromItem(null, absX, absY - constants.navbarTopMargin)
            bgMoveGrid.selectedItem.xAnimation.to = itemPos.x
            bgMoveGrid.selectedItem.yAnimation.to = itemPos.y
            bgMoveGrid.selectedItem.xAnimation.start()
            bgMoveGrid.selectedItem.yAnimation.start()
            // save the new position in the model
//                            bgMoveGrid.selectedItem.itemObject.position = Qt.point(absPos.x, absPos.y)
            bgMoveGrid.moveEnd()
            bgMoveGrid.selectedItem = null
        }

        z: roomView.z + 2 // must be on top of quicklinks
        anchors.fill: parent

        Grid {
            id: moveGrid
            // the following values are arbitrary; still waiting for clarification
            columns: 18
            rows: 14
            opacity: 0
            anchors {
                fill: parent
                rightMargin: bgMoveGrid.gridRightMargin
                bottomMargin: bgMoveGrid.gridBottomMargin
            }

            Repeater {
                model: moveGrid.columns * moveGrid.rows

                delegate: Rectangle {
                    id: rectDelegate
                    color: "transparent"
                    width: moveGrid.width / moveGrid.columns
                    height: moveGrid.height / moveGrid.rows
                    border {
                        width: 1
                        color: "cyan"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // map the coordinates to the RoomItem's parent
                            var absPos = parent.mapToItem(null, x, y)
                            bgMoveGrid.moveTo(absPos.x, absPos.y)
                        }
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            states: [
                State {
                    name: "shown"
                    PropertyChanges {
                        target: moveGrid
                        opacity: 1
                    }
                }
            ]
        }
    }



    QtObject {
        id: privateProps

        property variant currentMenu: undefined

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
            name: "menuSelected"
            PropertyChanges {
                target: darkRect
                opacity: 0.6
                z: 9
            }
        }
    ]
}
