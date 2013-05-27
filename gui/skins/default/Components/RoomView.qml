import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/RoomView.js" as Script


Item {
    id: roomView

    property variant model: undefined
    property variant pageObject: undefined

    signal focusLost // to signal to menu when menu focus is lost

    Pannable {
        id: pannable
        anchors.fill: parent

        Item {
            id: content
            x: 0
            y: parent.childOffset
            width: parent.width
            height: parent.height

            Rectangle {
                id: darkRect
                anchors.fill: parent
                color: "black"
                opacity: 0.02
                radius: 20
                z: 9
                visible: false

                BeepingMouseArea {
                    id: areaDarkRect
                    anchors.fill: parent
                    onClicked: {
                        if (darkRect.state === "menuHighlighted")
                            privateProps.unselectObj()
                        else
                            privateProps.closeMenu()
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: privateProps.durationInterval }
                }

                states: [
                    State {
                        name: "shown"
                        PropertyChanges {
                            target: darkRect
                            opacity: 0.6
                            visible: true
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

            MoveArea {
                id: bgMoveArea

                function moveTo(absX, absY) {
                    // click refers to item center so computes offsets
                    var oX = bgMoveArea.selectedItem.itemWidth / 2
                    var oY = bgMoveArea.selectedItem.itemHeight / 2
                    // computes area coordinates from absolute ones taking offsets into consideration
                    var areaPt = bgMoveArea.absolute2area(Qt.point(absX - oX, absY - oY))
                    // repositions object inside move area if needed
                    areaPt.x = bgMoveArea.xInRect(areaPt.x, bgMoveArea.selectedItem.itemWidth)
                    // MenuItem have an y = 33 coordinate inside MenuContainer and we are
                    // positioning the container: let's take that into account
                    areaPt.y = bgMoveArea.yInRect(areaPt.y, bgMoveArea.selectedItem.itemHeight) - constants.navbarTopMargin
                    // we move objects inside content, so computes content coordinates
                    var contentPt = content.mapFromItem(bgMoveArea, areaPt.x, areaPt.y)
                    // here we manually activate animations
                    bgMoveArea.selectedItem.xAnimation.to = contentPt.x
                    bgMoveArea.selectedItem.yAnimation.to = contentPt.y
                    bgMoveArea.selectedItem.xAnimation.start()
                    bgMoveArea.selectedItem.yAnimation.start()
                    // animation started, so we can save coordinates inside item
                    bgMoveArea.selectedItem.x = contentPt.x
                    bgMoveArea.selectedItem.y = contentPt.y
                    // computes absolute coordinates and saves them in object
                    var absPt = bgMoveArea.area2absolute(areaPt)
                    // when saving absolute coordinates, we must save MenuItem coordinates
                    bgMoveArea.selectedItem.itemObject.position = Qt.point(absPt.x, absPt.y + constants.navbarTopMargin)
                }

                z: darkRect.z + 2 // must be on top of quicklinks
                anchors.fill: parent

                onMoveEnd: {
                    bgMoveArea.selectedItem.state = ""
                    bgMoveArea.state = ""
                }
            }
        }
    }

    function startMove(container) {
        privateProps.unselectObj()

        bgMoveArea.selectedItem = container
        bgMoveArea.state = "shown"
    }

    /* private implementation */
    Component {
        id: roomItemComponent

        RoomItem {
            id: roomItem
            refX: privateProps.refX
            refY: privateProps.refY

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
        id: deleteConfirmDialog
        TextDialog {
            property variant item
            function okClicked() {
                var m = roomView.model
                for (var i = 0; i < m.count; ++i) {
                    var l = m.getObject(i)
                    if (l.btObject === item)
                        roomView.model.remove(l)
                }
            }
            title: qsTr("Confirm deletion")
            text: qsTr("Are you sure to delete the selected MyHome object?")
        }
    }

    Component {
        id: itemComponent

        MenuContainer {
            id: container

            clipBehavior: false
            property alias xAnimation: xAnim
            property alias yAnimation: yAnim
            property variant itemObject: undefined
            property int refX: -1 // used for editColumn placement, -1 means not used
            property int refY: -1 // used for editColumn placement, -1 means not used
            property int itemWidth
            property int itemHeight

            onRootObjectChanged: {
                if (rootObject) {
                    itemWidth = rootObject.width
                    itemHeight = rootObject.height
                }
            }

            width: 500
            rootColumn: roomItemComponent
            onRootColumnClicked: {
                if (container.state === "highlight")
                    return

                roomView.state = "menuOpened"
                container.state = "opened"
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
                onRequestDelete: {
                    roomView.pageObject.installPopup(deleteConfirmDialog, {"item": object})
                }
                ignoreUnknownSignals: true
            }

            Connections {
                target: xAnim
                onRunningChanged: {
                    if (!xAnim.running) {
                        rootObject.updateAnchors()
                    }
                }
            }

            NumberAnimation { id: xAnim; target: container; property: "x"; duration: privateProps.durationInterval; easing.type: Easing.InSine }
            NumberAnimation { id: yAnim; target: container; property: "y"; duration: privateProps.durationInterval; easing.type: Easing.InSine }

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
                    SequentialAnimation {
                        NumberAnimation { targets: container; properties: "x, y"; duration: privateProps.durationInterval }
                        ScriptAction { script: privateProps.currentMenu = container }
                    }
                },
                Transition {
                    from: "opened"
                    to: ""
                    SequentialAnimation {
                        NumberAnimation { targets: container; properties: "x, y"; duration: privateProps.durationInterval }
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

    QtObject {
        id: privateProps

        property int refX: -1 // seee RoomItem.refX, refY
        property int refY: -1
        property int durationInterval: 400

        property variant currentMenu: undefined

        function unselectObj() {
            privateProps.currentMenu.state = ""
            privateProps.currentMenu = undefined
            roomView.state = ""
            roomView.focusLost()
        }

        function closeMenu() {
            if (privateProps.currentMenu !== undefined) {
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
            privateProps.refX = bgMoveArea.mapToItem(null, bgMoveArea.x, bgMoveArea.y).x + 0.5 * bgMoveArea.width
            privateProps.refY = bgMoveArea.mapToItem(null, bgMoveArea.x, bgMoveArea.y).y + 0.5 * bgMoveArea.height

            for (var i = 0; i < model.count; ++i) {
                // gets object
                var obj = model.getObject(i)
                // gets absolute coordinates from object, they may be unknown (-1, -1)
                var absX = obj.position.x
                var absY = obj.position.y
                // computes area coordinates from absolute ones
                var areaPt = bgMoveArea.absolute2area(Qt.point(absX, absY))
                if (absX < 0 && absY < 0) {
                    // if position is unknown, generates a random one
                    areaPt = bgMoveArea.randomPosition()
                }
                // we add objects to content, so computes content coordinates
                var contentPt = content.mapFromItem(bgMoveArea, areaPt.x, areaPt.y)
                // creates object in content coordinates and invisible because it may be outside move area
                var object = itemComponent.createObject(content, {"rootData": obj.btObject, 'x': contentPt.x, 'y': contentPt.y, 'pageObject': pageObject, "itemObject": obj, "elementsOnMenuPage": 6, "opacity": 0.01})
                // now we know object size: reposition object inside move area if needed
                areaPt.x = bgMoveArea.xInRect(areaPt.x, object.rootObject.width)
                // MenuItem have an y = 33 coordinate inside MenuContainer and we are
                // positioning the container: let's take that into account
                areaPt.y = bgMoveArea.yInRect(areaPt.y, object.rootObject.height) - constants.navbarTopMargin
                // recomputes content coordinates and assigns it to object
                contentPt = content.mapFromItem(bgMoveArea, areaPt.x, areaPt.y)
                object.x = contentPt.x
                object.y = contentPt.y
                // computes absolute coordinates and saves them in object
                var absPt = bgMoveArea.area2absolute(areaPt)
                // when saving absolute coordinates, we must save MenuItem coordinates
                obj.position = Qt.point(absPt.x, absPt.y + constants.navbarTopMargin)
                // shows and stores the object
                object.opacity = 1.0
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
