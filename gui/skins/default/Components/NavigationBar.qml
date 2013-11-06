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
import Components 1.0
import Components.Text 1.0


Item {
    id: buttonsColumn
    property bool backButton: true
    property bool systemsButton: true
    property bool settingsButton: true
    property bool roomsButton: true
    property bool multimediaButton: true
    property alias text: label.text

    signal backClicked
    signal systemsClicked
    signal settingsClicked
    signal roomsClicked
    signal multimediaClicked

    // private implementation
    width: backButton.width

    Column {
        id: column
        spacing: 1


        ButtonImageThreeStates {
            id: backButton
            visible: buttonsColumn.backButton
            onTouched: buttonsColumn.backClicked()
            defaultImage: "../images/common/icon_back.svg"
            pressedImage: "../images/common/icon_back_p.svg"
            defaultImageBg: "../images/common/button_navigation_column.svg"
            pressedImageBg: "../images/common/button_navigation_column_p.svg"
        }

        ButtonImageThreeStates {
            visible: buttonsColumn.systemsButton
            onTouched: buttonsColumn.systemsClicked()
            defaultImage: "../images/common/ico_sistemi.svg"
            pressedImage: "../images/common/ico_sistemi_P.svg"
            defaultImageBg: "../images/common/button_navigation_column.svg"
            pressedImageBg: "../images/common/button_navigation_column_p.svg"
        }

        ButtonImageThreeStates {
            visible: buttonsColumn.settingsButton
            onTouched: buttonsColumn.settingsClicked()
            defaultImage: "../images/common/ico_opzioni.svg"
            pressedImage: "../images/common/ico_opzioni_P.svg"
            defaultImageBg: "../images/common/button_navigation_column.svg"
            pressedImageBg: "../images/common/button_navigation_column_p.svg"
        }

        ButtonImageThreeStates {
            visible: buttonsColumn.roomsButton
            onTouched: buttonsColumn.roomsClicked()
            defaultImage: "../images/common/ico_stanze.svg"
            pressedImage: "../images/common/ico_stanze_P.svg"
            defaultImageBg: "../images/common/button_navigation_column.svg"
            pressedImageBg: "../images/common/button_navigation_column_p.svg"
        }

        ButtonImageThreeStates {
            visible: buttonsColumn.multimediaButton
            onTouched: buttonsColumn.multimediaClicked()
            defaultImage: "../images/common/ico_multimedia.svg"
            pressedImage: "../images/common/ico_multimedia_P.svg"
            defaultImageBg: "../images/common/button_navigation_column.svg"
            pressedImageBg: "../images/common/button_navigation_column_p.svg"
        }
    }
    Rectangle {
        id: background
        color: "white"
        opacity: 0.6
        width: backButton.width

        anchors {
            top: column.bottom
            bottom: parent.bottom
            left: column.left
        }
    }

    // This Item is only a positioner element for the text. Text is rotated
    // relative to the original position of the text (excluding alignment etc)
    // but centering and anchoring is done relative to the size of the Item
    // class (which is a parent of Text element).
    // Using an Item for positioning makes it easier to get it right.
    Item {
        // swap width <-> height because we are rotating, anchors.fill is not
        // going to work
        width: background.height
        height: background.width
        anchors.centerIn: background
        rotation: 270

        UbuntuLightText {
            id: label
            anchors.fill: parent
            color: "#343434"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 32
            elide: Text.ElideRight
        }
    }
}
