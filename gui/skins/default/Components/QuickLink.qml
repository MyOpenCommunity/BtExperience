import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/Stack.js" as Stack


Item {
    id: bgQuick

    property alias imageSource: icon.source
    property string text: ""
    property color color: "white"
    property string address: "www.corriere.it"
    property string page: "Browser.qml"
    property bool editable: true
    property variant itemObject
    property int refX: -1 // used for sidebar placement, -1 means not used
    property int refY: -1 // used for sidebar placement, -1 means not used

    property int additionalWidth: 10

    signal selected(variant favorite)
    signal requestEdit(variant favorite)
    signal clicked()
    signal editCompleted()
    signal requestMove(variant favorite)
    signal requestDelete(variant favorite)

    width: column.width + 10
    height: column.height + 10

    QtObject {
        id: privateProps

        function getSidebarPlacement(x, y, rx, ry) {
            // this function evaluates what selected state is right for the
            // QuickLink wrt the reference point (refX, refY)
            // for example, if the QuickLink is on right and below the reference
            // point, the sidebar will appear on the left and with the bottom
            // aligned to the QuickLink bottom
            // please note that x, y are not used, they only serve to bind to QuickLink coordinates changes
            if ((rx === -1) || (ry === -1)) // no ref point, returns default selected state
                return "selected"
            // rx, ry are absolute coordinates, so converts QuickLink x, y to absolute ones
            var mov_cx = bgQuick.mapToItem(null, 0, 0).x + 0.5 * bgQuick.width
            var mov_cy = bgQuick.mapToItem(null, 0, 0).y + 0.5 * bgQuick.height
            // computes delta wrt the ref point
            var px = mov_cx - rx
            var py = mov_cy - ry
            // analyzes signs and returns the right selected state
            if ((px >= 0) && (py >= 0))
                return "selectedBottomLeft"
            if ((px >= 0) && (py <= 0))
                return "selectedTopLeft"
            if ((px <= 0) && (py >= 0))
                return "selectedBottomRight"
            return "selectedTopRight"
        }

        function startEdit() {
            labelLoader.sourceComponent = labelInputComponent
            labelLoader.item.forceActiveFocus()
            labelLoader.item.openSoftwareInputPanel()
        }

        function editDone() {
            if (labelLoader.item.text !== bgQuick.text) {
                bgQuick.editCompleted()
                bgQuick.text = labelLoader.item.text
            }
            labelLoader.sourceComponent = labelComponent
        }
    }

    Column {
        id: column

        spacing: 10
        Rectangle {
            id: highlight
            width: icon.width + additionalWidth
            height: icon.height + additionalWidth
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
            Behavior on width {
                NumberAnimation { target: highlight; property: "width"; duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on height {
                NumberAnimation { target: highlight; property: "height"; duration: 200; easing.type: Easing.InOutQuad }
            }

            Image {
                id: icon
                anchors.centerIn: parent

                Rectangle {
                    id: bgQuickPressed
                    color: "black"
                    opacity: 0.5
                    visible: false
                    anchors.fill: parent
                }
            }
        }

        Loader {
            id: labelLoader
            anchors.horizontalCenter: parent.horizontalCenter
            width: icon.width
            sourceComponent: labelComponent
        }

        Component {
            id: labelComponent
            UbuntuLightText {
                text: bgQuick.text
                color: bgQuick.color
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        Component {
            id: labelInputComponent
            TextInput {
                text: bgQuick.text
                color: bgQuick.color
                horizontalAlignment: Text.AlignHCenter
                activeFocusOnPress: false
                onActiveFocusChanged: if (!activeFocus) { privateProps.editDone() }
            }
        }
    }

    Column {
        id: editColumn

        opacity: 0
        anchors {
            top: column.top
            left: column.right
            leftMargin: 1
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
                source: "../images/icon_text.png"
                anchors.fill: parent
                anchors.margins: 10
            }
            MouseArea {
                anchors.fill: parent
                onClicked: privateProps.startEdit()
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
                source: "../images/icon_pencil.png"
                anchors.fill: parent
                anchors.margins: 10
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bgQuick.requestEdit(bgQuick)
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
                onClicked: {
                    bgQuick.requestMove(bgQuick)
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
                source: "../images/icon_trash.png"
                anchors.fill: parent
                anchors.margins: 10

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        bgQuick.requestDelete(bgQuick)
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation { target: editColumn; property: "opacity"; duration: 200;}
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        // the getSidebarPlacement returns the selected state to use
        onPressAndHold: parent.state = privateProps.getSidebarPlacement(bgQuick.x, bgQuick.y, bgQuick.refX, bgQuick.refY)
        onPressed: bgQuickPressed.visible = true
        onReleased: bgQuickPressed.visible = false
        onClicked: {
            if (page !== "")
                Stack.openPage(page, {'urlString': address})
            bgQuick.clicked()
        }
    }

    Behavior on x {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Behavior on y {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    states: [
        State {
            name: "selected"
            PropertyChanges {
                target: column
                anchors.margins: editable ? 0 : column.margins
            }
            PropertyChanges {
                target: bgQuick
                additionalWidth: editable ? 20 : bgQuick.additionalWidth
            }
            PropertyChanges {
                target: editColumn
                opacity: editable ? 1 : editColumn.opacity
            }
            StateChangeScript {
                // execute selected script when not editable?
                script: editable ? bgQuick.selected(bgQuick) : ""
            }
        },
        State {
            name: "selectedTopLeft"
            extend: "selected"
            AnchorChanges {
                target: editColumn
                anchors.top: column.top
                anchors.bottom: undefined
                anchors.left: undefined
                anchors.right: column.left
            }
            PropertyChanges {
                target: editColumn
                anchors.leftMargin: 0
                anchors.rightMargin: 1
            }
        },
        State {
            name: "selectedTopRight"
            extend: "selected"
            AnchorChanges {
                target: editColumn
                anchors.top: column.top
                anchors.bottom: undefined
                anchors.left: column.right
                anchors.right: undefined
            }
            PropertyChanges {
                target: editColumn
                anchors.leftMargin: 1
                anchors.rightMargin: 0
            }
        },
        State {
            name: "selectedBottomLeft"
            extend: "selected"
            AnchorChanges {
                target: editColumn
                anchors.top: undefined
                anchors.bottom: column.bottom
                anchors.left: undefined
                anchors.right: column.left
            }
            PropertyChanges {
                target: editColumn
                anchors.leftMargin: 0
                anchors.rightMargin: 1
            }
        },
        State {
            name: "selectedBottomRight"
            extend: "selected"
            AnchorChanges {
                target: editColumn
                anchors.top: undefined
                anchors.bottom: column.bottom
                anchors.left: column.right
                anchors.right: undefined
            }
            PropertyChanges {
                target: editColumn
                anchors.leftMargin: 1
                anchors.rightMargin: 0
            }
        }
    ]
}
