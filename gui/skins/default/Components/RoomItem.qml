import QtQuick 1.1
import BtObjects 1.0


MenuColumn {
    id: column

    signal requestMove
    signal selected

    /* simply forwarding to the menu builtin focusLost function */
    function focusLost() {
        if (theMenu.state === "toolbar")
            theMenu.state = ""
    }

    MenuItem {
        id: theMenu

        function startEdit() {
            theMenu.state = "toolbar"
            column.selected()
        }

        name: dataModel.name
        status: dataModel.active === true ? 1 : 0
        hasChild: true

        // We are assuming that items in rooms are always editable
        editable: true
        onEditCompleted: dataModel.name = name

        onClicked: {
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
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        theMenu.editMenuItem()
                        theMenu.state = ""
                    }
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
                MouseArea {
                    anchors.fill: parent
                    onClicked: column.requestMove()
                }
            }
        }

        states: [
            State {
                name: "toolbar"
                PropertyChanges { target: sidebar; opacity: 1 }
            }
        ]
    }

    BtObjectsMapping { id: mapping }
}

