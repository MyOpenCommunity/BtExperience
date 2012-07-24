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
        onPressAndHold: bgQuick.state = "selected"
        onPressed: bgQuickPressed.visible = true
        onReleased: bgQuickPressed.visible = false
        onClicked: {
            if (page !== "")
                Stack.openPage(page, {'urlString': address})
            bgQuick.clicked()
        }
    }

    Behavior on x {
        SequentialAnimation {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            ScriptAction { script: privateProps.computeAnchors() }
        }
    }

    Behavior on y {
        SequentialAnimation {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            ScriptAction { script: privateProps.computeAnchors() }
        }
    }

    Component.onCompleted: privateProps.computeAnchors()

    QtObject {
        id: privateProps

        function computeAnchors() {
            // function to compute and set anchors considering the QuickLink
            // position and the reference point

            // first of all, resets everything
            editColumn.anchors.top = undefined
            editColumn.anchors.bottom = undefined
            editColumn.anchors.left = undefined
            editColumn.anchors.right = undefined
            editColumn.anchors.leftMargin = 0
            editColumn.anchors.rightMargin = 0

            // checks if ref point is defined, if not default to top right
            if ((bgQuick.refX === -1) || (bgQuick.refY === -1)) {
                editColumn.anchors.top = column.top
                editColumn.anchors.bottom = undefined
                editColumn.anchors.left = column.right
                editColumn.anchors.right = undefined
                editColumn.anchors.leftMargin = 1
                editColumn.anchors.rightMargin = 0
                return
            }

            // bgQuick.refX, bgQuick.refY are absolute coordinates, so converts QuickLink x, y to absolute ones
            var mov_cx = bgQuick.mapToItem(null, 0, 0).x + 0.5 * bgQuick.width
            var mov_cy = bgQuick.mapToItem(null, 0, 0).y + 0.5 * bgQuick.height

            // computes delta wrt the ref point
            var px = mov_cx - bgQuick.refX
            var py = mov_cy - bgQuick.refY

            // analyzes signs and sets the right anchorings
            if ((px >= 0) && (py >= 0)) {
                // bottom left
                editColumn.anchors.top = undefined
                editColumn.anchors.bottom = column.bottom
                editColumn.anchors.left = undefined
                editColumn.anchors.right = column.left
                editColumn.anchors.leftMargin = 0
                editColumn.anchors.rightMargin = 1
                return
            }
            else if ((px >= 0) && (py <= 0)) {
                // top left
                editColumn.anchors.top = column.top
                editColumn.anchors.bottom = undefined
                editColumn.anchors.left = undefined
                editColumn.anchors.right = column.left
                editColumn.anchors.leftMargin = 0
                editColumn.anchors.rightMargin = 1
                return
            }
            else if ((px <= 0) && (py >= 0)) {
                // bottom right
                editColumn.anchors.top = undefined
                editColumn.anchors.bottom = column.bottom
                editColumn.anchors.left = column.right
                editColumn.anchors.right = undefined
                editColumn.anchors.leftMargin = 1
                editColumn.anchors.rightMargin = 0
                return
            }
            else {
                // top right
                editColumn.anchors.top = column.top
                editColumn.anchors.bottom = undefined
                editColumn.anchors.left = column.right
                editColumn.anchors.right = undefined
                editColumn.anchors.leftMargin = 1
                editColumn.anchors.rightMargin = 0
            }
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
        }
    ]
}
