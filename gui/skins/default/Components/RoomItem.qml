import QtQuick 1.1
import BtObjects 1.0

import "../js/anchorspositioning.js" as Positioner
import "../js/MenuItem.js" as Script

MenuColumn {
    id: column

    signal requestMove
    signal requestSelect

    property alias refX: theMenu.refX
    property alias refY: theMenu.refY

    /* simply forwarding to the menu builtin focusLost function */
    function focusLost() {
        if (theMenu.state === "toolbar")
            theMenu.state = ""
    }

    function select() {
        theMenu.state = "toolbar"
    }

    function updateAnchors() {
        Positioner.computeAnchors(theMenu, editColumn)
    }

    MenuItem {
        id: theMenu

        property int refX: -1 // used for editColumn placement, -1 means not used
        property int refY: -1 // used for editColumn placement, -1 means not used

        function startEdit() {
            column.requestSelect()
        }

        function handleClick() {
            var object = dataModel
            var properties = {}

            switch (dataModel.objectId) {
            case ObjectInterface.IdSurveillanceCamera:
            case ObjectInterface.IdExternalPlace:
            case ObjectInterface.IdSwitchboard:
                cctvModel.getObject(0).cameraOn(dataModel)
                return
            case ObjectInterface.IdInternalIntercom:
            case ObjectInterface.IdExternalIntercom:
                object = intercomModel.getObject(0)
                properties["intercom"] = dataModel
                break
            }

            column.columnClicked()
            column.loadColumn(mapping.getComponent(dataModel.objectId), "", object, properties)
        }

        name: dataModel.name
        description: Script.description(dataModel)
        status: Script.status(dataModel)
        boxInfoState: Script.boxInfoState(dataModel)
        boxInfoText: Script.boxInfoText(dataModel)
        hasChild: Script.hasChild(dataModel)

        // We are assuming that items in rooms are always editable
        editable: true
        onEditCompleted: dataModel.name = name

        onClicked: {
            if (theMenu.state === "toolbar")
                return

            handleClick()
        }

        ObjectModel {
            id: cctvModel
            filters: [{objectId: ObjectInterface.IdCCTV}]
        }
        ObjectModel {
            id: intercomModel
            filters: [{objectId: ObjectInterface.IdIntercom}]
        }

        Column {
            id: editColumn

            opacity: 0
            anchors {
                top: parent.top
                left: parent.right
            }

            Behavior on opacity {
                NumberAnimation { target: editColumn; property: "opacity"; duration: 200;}
            }

            Rectangle {
                width: 48
                height: 48
                gradient: Gradient {
                    GradientStop {
                        position: 0.00;
                        color: "#b7b7b7";
                    }
                    GradientStop {
                        position: 1.00;
                        color: "#ffffff";
                    }
                }
                Image {
                    source: "../images/icon_pencil.png"
                    anchors.fill: parent
                    anchors.margins: 10
                }
                BeepingMouseArea {
                    anchors.fill: parent
                    onClicked: theMenu.editMenuItem()
                }
            }

            Rectangle {
                width: 48
                height: 48
                gradient: Gradient {
                    GradientStop {
                        position: 0.00;
                        color: "#b7b7b7";
                    }
                    GradientStop {
                        position: 1.00;
                        color: "#ffffff";
                    }
                }
                Image {
                    source: "../images/icon_move.png"
                    anchors.fill: parent
                    anchors.margins: 10
                }
                BeepingMouseArea {
                    anchors.fill: parent
                    onClicked: column.requestMove()
                }
            }
        }

        // We rely on the state to be "toolbar" when the toolbar is open, but
        // the MenuItem automatically changes state to "pressed".
        // This hack is used to block interaction with the MenuItem and make
        // things work.
        MouseArea {
            id: blockMouseInteractionOnToolbarState
            anchors.fill: parent
            visible: false
        }

        states: [
            State {
                name: "toolbar"
                PropertyChanges { target: editColumn; opacity: 1 }
                PropertyChanges {
                    target: blockMouseInteractionOnToolbarState
                    visible: true
                }
            }
        ]
    }

    BtObjectsMapping { id: mapping }
    Component.onCompleted: Positioner.computeAnchors(theMenu, editColumn)
}

