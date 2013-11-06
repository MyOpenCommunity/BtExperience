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

/**
  * A control that implements a text and a button 3 states to perform a command.
  * The text is on the left, the button is on the right.
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property string text: "cancelletto"
    property alias defaultImage: button.defaultImage
    property alias pressedImage: button.pressedImage

    signal clicked
    signal pressed
    signal released

    source: "../../images/common/bg_automazioni.svg"

    UbuntuMediumText {
        id: caption

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 11
            right: button.left
            rightMargin: 11
        }
        font.pixelSize: 14
        color: "#323232"
        text: control.text
        elide: Text.ElideRight
    }

    ButtonImageThreeStates {
        id: button

        defaultImageBg: "../../images/common/btn_66x35.svg"
        pressedImageBg: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        defaultImage: "../../images/common/ico_cancelletto.svg"
        pressedImage: "../../images/common/ico_cancelletto_P.svg"
        onClicked: control.clicked()
        onPressed: control.pressed()
        onReleased: control.released()
        anchors {
            bottom: parent.bottom
            bottomMargin: 12
            right: parent.right
            rightMargin: 7
        }
    }
}
