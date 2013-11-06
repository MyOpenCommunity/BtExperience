/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "../js/Stack.js" as Stack
import "../js/anchorspositioning.js" as Positioner


/**
  \ingroup Multimedia

  \brief Base component to be used as Quicklink

  This component defines all common features for a QuickLink.
  A QuickLink has an image and a description. It has a toolbar that can be
  shown with a pressAndHold operation.

  The toolbar defines the following operations:
  - edit (the user may change the QuickLink description)
  - modify (normally a popup appears to change QuickLink properties)
  - move (the user may change the QuickLink position)
  - delete (the user may delete the QuickLink)

  The QuickLink can be clicked. In this case a proper action is executed.

  The QuickLink contains refX and refY properties plus the logic to position
  the toolbar around it. This logic is needed to have the toolbar always
  fully visible. The toolbar positioning logic has been factored out in a
  javascript module. The refX and refY coordinates usually refer to the center
  of the grid where QuickLink may be disposed. In this way, the toolbar will
  be always positioned toward the center of the grid.
  */
Item {
    id: bgQuick

    /// type:url the image to be shown
    property alias imageSource: icon.source
    /// the QuickLink description
    property string text: itemObject.name
    /// the page to load when clicked, if empty no page is load
    property string page: "ExternalBrowser.qml"
    /// is this QuickLink description editable?
    property bool editable: true
    /// the C++ object corresponding to this QuickLink
    property variant itemObject
    property int refX: -1 // used for editColumn placement, -1 means not used
    property int refY: -1 // used for editColumn placement, -1 means not used
    /// the profile this QuickLink belongs to if any
    property variant profile: undefined
    /// the behavior on x coordinate
    property alias xBehavior: xBehavior
    /// the behavior on y coordinate
    property alias yBehavior: yBehavior

    /// emitted when this QuickLink is selected with a pressAndHold operation
    signal selected(variant favorite)
    /// emitted when user clicks on edit button on the toolbar
    signal requestEdit(variant favorite)
    /// emitted when QuickLink is clicked, navigates to page if any
    signal clicked()
    /// emitted when user finished editing operation
    signal editCompleted()
    /// emitted when user clicks on move button on the toolbar
    signal requestMove(variant favorite)
    /// emitted when user clicks on delete button on the toolbar
    signal requestDelete(variant favorite)

    width: column.width + 10
    height: column.height + 10

    Column {
        id: column
        anchors.centerIn: parent

        Image {
            id: container
            source: homeProperties.skin === HomeProperties.Clear ? "../images/profiles/scheda_preferiti.svg" :
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
                source: homeProperties.skin === HomeProperties.Clear ? "../images/profiles/scheda_preferiti_P.svg" :
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
                color: homeProperties.skin === HomeProperties.Clear ? "#434343":
                                                                       "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 15
                elide: Text.ElideRight
                anchors.top: parent.top
                anchors.topMargin: -18.5
            }
        }

        Component {
            id: labelInputComponent
            UbuntuLightTextInput {
                text: bgQuick.text
                color: homeProperties.skin === HomeProperties.Clear ? "#434343":
                                                                       "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                activeFocusOnPress: false
                anchors.top: parent.top
                anchors.topMargin: -20
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
        pressAndHoldEnabled: true
        onHeld: if (editable) bgQuick.state = "selected"
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
                Stack.pushPage(page, {'urlString': itemObject.address, 'profile': bgQuick.profile})
            bgQuick.clicked()
        }
    }

    Behavior on x {
        id: xBehavior
        SequentialAnimation {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            ScriptAction { script: Positioner.computeAnchors(bgQuick, editColumn) }
        }
    }

    Behavior on y {
        id: yBehavior
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
                bgQuick.itemObject.name = bgQuick.text = labelLoader.item.text
            }
            labelLoader.sourceComponent = labelComponent
        }
    }

    states: [
        State {
            name: "selected"
            PropertyChanges {
                target: column
                anchors.margins: 0
            }
            PropertyChanges {
                target: editColumn
                opacity: 1
            }
            StateChangeScript {
                script: bgQuick.selected(bgQuick)
            }
        }
    ]
}
