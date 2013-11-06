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


Item {
    id: control

    property alias defaultImage: button.defaultImage
    property alias pressedImage: button.pressedImage
    property alias enabled: button.enabled
    property int quantity: 0

    signal touched

    visible: quantity > 0
    width: separator.width + button.width

    // separator
    SvgImage {
        id: separator

        visible: control.visible
        source: "../images/toolbar/toolbar_separator.svg"
        height: control.height
        anchors.left: parent.left
    }

    // button
    ButtonImageThreeStates {
        id: button

        visible: control.visible
        defaultImageBg: "../images/toolbar/_bg_alert.svg"
        pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        onTouched: control.touched()

        SvgImage {
            id: quantityBg
            // normally, we put images outside for performance reasons
            // here we are in a Row element and we cannot do that (the Row will
            // grow in size to make room for this image)
            visible: quantity > 0
            source: "../images/toolbar/bg_counter.svg"
            anchors {
                bottom: button.bottom
                bottomMargin: 10
                right: button.right
                rightMargin: 5
            }
        }

        UbuntuLightText {
            // see comment above
            text: quantity
            visible: quantity > 0
            color: "white"
            font.pixelSize: 10
            anchors.fill: quantityBg
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
