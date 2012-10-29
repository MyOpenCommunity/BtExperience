import QtQuick 1.1
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0

import "../js/Stack.js" as Stack
import "../js/anchorspositioning.js" as Positioner

Item {
    id: bgQuick

    property alias imageSource: icon.source
    property string text: itemObject.name
    property string page: "Browser.qml"
    property bool editable: true
    property variant itemObject
    property int refX: -1 // used for editColumn placement, -1 means not used
    property int refY: -1 // used for editColumn placement, -1 means not used

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
        anchors.centerIn: parent
  
     Image {
            id: container
            source: global.guiSettings.skin === GuiSettings.Clear ? "../images/profiles/scheda_preferiti.svg" :
                                                    "../images/profiles/scheda_preferiti_P.svg"

            Image {
                id: icon
                anchors.centerIn: container
                anchors.verticalCenterOffset: -9

                Rectangle {
                    id: bgQuickPressed
                    color: "black"
                    opacity: 0.5
                    visible: false
                    anchors.fill: parent
                }
            }

            Image
            {
                id: containerPressed
                anchors.fill: container
                source: global.guiSettings.skin === GuiSettings.Clear ? "../images/profiles/scheda_preferiti_P.svg" :
                                                        "../images/profiles/scheda_preferiti.svg"
                visible: false
                anchors.left: container.left
                anchors.bottom: container.bottom
                anchors.right: container.right
            }

            Image
            {
                id: shadow_top
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 87
                anchors.leftMargin: 9
                source: "../images/profiles/alto.png"
            }

            Image
            {
                id: shadow_top_left
                anchors.top: parent.top
                anchors.topMargin: -10
                anchors.left: parent.left
                anchors.leftMargin: -10
                anchors.rightMargin: 0
                anchors.right: shadow_top.left
                source: "../images/profiles/alto_sx.png"
            }

            Image
            {
                id: shadow_top_right
                anchors.top: parent.top
                anchors.topMargin: -10
                anchors.left: parent.left
                anchors.leftMargin: 114
                source: "../images/profiles/alto_dx.png"
            }

            Image
            {
                id: shadow_left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 9
                anchors.left: parent.left
                anchors.leftMargin: -10
                anchors.topMargin: 0
                anchors.top: shadow_top_left.bottom
                source: "../images/profiles/sx.png"
            }

            Image
            {
                id: shadow_right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 9
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 114
                anchors.top: shadow_top_right.bottom
                source: "../images/profiles/dx.png"
            }

            Image
            {
                id: shadow_buttom_left
                anchors.left: parent.left
                anchors.leftMargin: -10
                anchors.topMargin: 0
                anchors.top: shadow_left.bottom
                source: "../images/profiles/basso_sx.png"
            }

            Image
            {
                id: shadow_buttom_right
                anchors.left: parent.left
                anchors.leftMargin: 114
                anchors.topMargin: 0
                anchors.top: shadow_right.bottom
                source: "../images/profiles/basso_dx.png"
            }

            Image
            {
                id: shadow_bottom
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -10
                anchors.leftMargin: 0
                anchors.left: shadow_buttom_left.right
                source: "../images/profiles/basso.png"
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
                color: global.guiSettings.skin === GuiSettings.Clear ? "#434343":
                                                       "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                elide: Text.ElideRight
                anchors.top: parent.top
                anchors.topMargin: -18
            }
        }

        Component {
            id: labelInputComponent
            TextInput {
                text: bgQuick.text
                color: global.guiSettings.skin === GuiSettings.Clear ? "#434343":
                                                       "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                activeFocusOnPress: false
                anchors.top: parent.top
                anchors.topMargin: -18
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
            BeepingMouseArea {
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

            BeepingMouseArea {
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

            BeepingMouseArea {
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

                BeepingMouseArea {
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

    BeepingMouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressAndHold: bgQuick.state = "selected"
        onPressed:  {
            bgQuickPressed.visible = true
            containerPressed.visible = true
        }
        onReleased: {
            bgQuickPressed.visible = false
            containerPressed.visible = false
        }
        onClicked: {
            if (page !== "")
                Stack.pushPage(page, {'urlString': itemObject.address})

            bgQuick.clicked()
        }
    }

    Behavior on x {
        SequentialAnimation {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            ScriptAction { script: Positioner.computeAnchors(bgQuick, editColumn) }
        }
    }

    Behavior on y {
        SequentialAnimation {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            ScriptAction { script: Positioner.computeAnchors(bgQuick, editColumn) }
        }
    }

    Component.onCompleted: Positioner.computeAnchors(bgQuick, editColumn)


    QtObject {
        id: privateProps

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
