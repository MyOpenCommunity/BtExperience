import QtQuick 1.1
import BtObjects 1.0


MenuColumn {
    id: column

    signal requestMove
    signal requestSelect

    /* simply forwarding to the menu builtin focusLost function */
    function focusLost() {
        if (theMenu.state === "toolbar")
            theMenu.state = ""
    }

    function select() {
        theMenu.state = "toolbar"
    }

    MenuItem {
        id: theMenu

        function startEdit() {
            column.requestSelect()
        }

        name: dataModel.name
        status: dataModel.active === true ? 1 : 0
        hasChild: true

        // We are assuming that items in rooms are always editable
        editable: true
        onEditCompleted: dataModel.name = name

        onClicked: {
            if (theMenu.state === "toolbar")
                return

            column.columnClicked()
            column.loadColumn(mapping.getComponent(dataModel.objectId), "", dataModel)
        }

        Column {
            id: sidebar

            opacity: 0
            anchors {
                top: parent.top
                left: parent.right
            }

            Behavior on opacity {
                NumberAnimation { target: sidebar; property: "opacity"; duration: 200;}
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
                PropertyChanges { target: sidebar; opacity: 1 }
                PropertyChanges {
                    target: blockMouseInteractionOnToolbarState
                    visible: true
                }
            }
        ]
    }

    BtObjectsMapping { id: mapping }
}

