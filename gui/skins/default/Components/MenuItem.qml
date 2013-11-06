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
import Components.Text 1.0


/**
  \ingroup Core

  \brief A menu item component.

  The MenuItem component implements features common to all menu items.
  A MenuItem has a visual state (normal, pressed, selected).
  A MenuItem can be editable, in such case logic to manage editing is present.
  A MenuItem contains logic and graphic to optionally show a rounded box.
  The box may change color depending on box state set.
  A MenuItem implements a colored icon that changes color depending on the
  MenuItem status.
  The MenuItem shows text through the name and description property.
  Generally, the MenuItem name property is shown as MenuTitle, too.
  */
Item {
    id: menuItem

    height: background.height
    width: background.width

    /**
      It is recommended to use this property and never set the MenuItem state
      directly. This is because there are 3 different states (default, pressed,
      selected). When the MenuItem is in the selected state and the user clicks
      on it, we want the MenuItem to pass to the pressed state.
      When user releases the MenuItem, the component goes to default state and
      not to the state it was before (this is QML design).
      To avoid this weird behavior is highly recommended to use this property
      and to not play with MenuItem state.
      */
    property bool isSelected: false
    /// is this MenuItem name editable?
    property bool editable: false
    /// the MenuItem name shown on the first row
    property string name
    /// type:string the MenuItem description shown on the last row
    property alias description: textDescription.text
    /// type:list<State> sets the state for the rounded box causing it to appear and change color
    property alias boxInfoState: boxInfo.state
    /// type:string what to show inside the rounded box
    property alias boxInfoText: boxInfoText.text
    /// the MenuItem status, causes the circle icon to appear and change color
    property int status: -1
    /// if true, shows a little arrow indicating the possible navigation to the child MenuItem
    property bool hasChild: false
    property alias backgroundImage: background.source
    /// can this MenuItem accept user input? if not, MenuItem is shown grayed out
    property bool enabled: true
    /// is mouse interaction enabled?
    property bool clickable: true

    signal clicked(variant itemClicked)
    signal pressed(variant itemPressed)
    signal released(variant itemReleased)
    signal touched(variant itemTouched)
    signal editCompleted()

    /// Hook called when the MenuItem is pressAndHeld. Default implementation
    /// starts menu editing.
    function startEdit() {
        editMenuItem()
    }

    /// Actually starts editing
    function editMenuItem() {
        labelLoader.sourceComponent = labelInputComponent
        labelLoader.item.forceActiveFocus()
        labelLoader.item.openSoftwareInputPanel()
    }

    QtObject {
        id: privateProps

        function editDone() {
            if (labelLoader.item.text !== menuItem.name) {
                menuItem.name = labelLoader.item.text
                menuItem.editCompleted()
            }
            labelLoader.sourceComponent = labelComponent
        }
    }

    function statusVisible() {
        return menuItem.status > -1
    }

    function iconStatusImage() {
        if (!statusVisible())
            return ""
        var base = "../images/common/"
        if (menuItem.status === 0)
            return base + "menu_column_item_inactive_led.svg"
        else if (menuItem.status === 1)
            return base + "menu_column_item_active_led.svg"
        else if (menuItem.status === 2)
            return base + "menu_column_item_warning_led.svg"
        else if (menuItem.status === 3)
            return base + "menu_column_item_alarm_led.svg"
        else if (menuItem.status === 4)
            return base + "menu_column_item_disabled_led.svg"
    }

    SvgImage {
        anchors.fill: parent
        id: background
        source: "../images/common/menu_column_item_bg.svg";
    }

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: menuItem.enabled === false
        MouseArea {
            anchors.fill: parent
        }
    }

    SvgImage {
        id: iconStatus

        source: iconStatusImage()
        anchors {
            top: parent.top
            topMargin: background.height / 100 * 18
            left: parent.left
            leftMargin: background.width / 100 * 2
        }
    }

    Loader {
        id: labelLoader

        property color textColor: "#2d2d2d"
        anchors {
            top: parent.top
            topMargin: background.height / 100 * 16
            left: parent.left
            leftMargin: background.width / 100 * 9
            right: arrowRight.left
        }
        sourceComponent: labelComponent
    }

    Component {
        id: labelInputComponent
        UbuntuMediumTextInput {
            text: menuItem.name
            activeFocusOnPress: false
            font.pixelSize: 15
            color: labelLoader.textColor
            onActiveFocusChanged: if (!activeFocus) { privateProps.editDone() }
        }
    }

    Component {
        id: labelComponent
        UbuntuMediumText {
            text: menuItem.name
            font.pixelSize: 15
            color:  labelLoader.textColor
            elide: Text.ElideRight
        }
    }

    SvgImage {
        id: arrowRight

        visible: menuItem.hasChild
        source: "../images/common/menu_column_item_arrow.svg"
        anchors {
            top: parent.top
            topMargin: background.height / 100 * 24
            right: parent.right
            rightMargin: background.width / 100 * 3
        }
    }

    Item {
        id: boxInfo

        width: 45
        visible: false
        anchors {
            top: labelLoader.bottom
            bottom: parent.bottom
            left: labelLoader.left
        }

        Rectangle {
            id: boxInfoRect
            color: "#999"
            radius: 4
            height: 17
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right

            UbuntuLightText {
                id: boxInfoText
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 15
            }
        }

        states: [
            State {
                name: "info"
                PropertyChanges { target: boxInfoRect; color: "#999999" }
                PropertyChanges { target: boxInfo; visible: true }

            },
            State {
                name: "warning"
                PropertyChanges { target: boxInfoRect; color: "#ed1b35" }
                PropertyChanges { target: boxInfo; visible: true }
            }
        ]
    }

    UbuntuLightText {
        id: textDescription

        color: "#626262"
        wrapMode: Text.NoWrap
        font.pixelSize: 15
        verticalAlignment: Text.AlignBottom
        anchors {
            top: labelLoader.bottom
            bottom: parent.bottom
            bottomMargin: background.height / 100 * 10
            left: boxInfo.visible ? boxInfo.right : labelLoader.left
            leftMargin: boxInfo.visible ? 5 : 0
        }
    }

    BeepingMouseArea {
        id: mousearea
        anchors.fill: parent
        visible: menuItem.clickable
        pressAndHoldEnabled: menuItem.editable
        onHeld: if (menuItem.editable) { startEdit() }
        onClicked: menuItem.clicked(menuItem)
        onPressed: {
            touchTimer.restart()
            menuItem.pressed(menuItem)
        }
        onReleased: menuItem.released(menuItem)

        Timer {
            id: touchTimer
            interval: 50
            onTriggered: menuItem.touched(menuItem)
        }
    }


    onStateChanged: {
        if (state === "")
            return

        for (var i = 0; i < states.length; ++i)
            if (state === states[i].name)
                return

        console.log("Warning: the state -> " + state + " <- is not allowed!")
    }

    states: [
        State {
            // Designed for internal use, not set from the extern of MenuItem. See comment on isSelected
            name: "_selected"
            when: isSelected && !mousearea.pressed
            PropertyChanges { target: labelLoader; textColor: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_selected.svg" }
        },
        State {
            // Designed for internal use, not set from the extern of MenuItem. See comment on isSelected
            name: "_pressed"
            when: mousearea.pressed
            PropertyChanges { target: labelLoader; textColor: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_pressed.svg" }
        }
    ]
}

