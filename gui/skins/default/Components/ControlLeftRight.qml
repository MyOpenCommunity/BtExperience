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


SvgImage {
    id: control

    property string text: "7 seconds"

    signal leftClicked
    signal rightClicked

    UbuntuLightText {
        id: timing

        anchors {
            verticalCenter: rightButton.verticalCenter
            left: parent.left
            right: leftButton.left
            rightMargin: 4
            leftMargin: 7
        }
        font.pixelSize: 15
        color: "white"
        text: control.text
        elide: Text.ElideRight
    }

    ButtonImageThreeStates {
        id: leftButton
        defaultImageBg: "../images/common/btn_frecce.svg"
        pressedImageBg: "../images/common/btn_frecce_P.svg"
        shadowImage: "../images/common/ombra_btn_frecce.svg"
        defaultImage: "../images/common/ico_freccia_sx.svg"
        pressedImage: "../images/common/ico_freccia_sx_P.svg"
        onPressed: leftClicked()
        anchors {
            bottom: parent.bottom
            bottomMargin: 11
            right: rightButton.left
            rightMargin: 3
        }
    }

    ButtonImageThreeStates {
        id: rightButton
        defaultImageBg: "../images/common/btn_frecce.svg"
        pressedImageBg: "../images/common/btn_frecce_P.svg"
        shadowImage: "../images/common/ombra_btn_frecce.svg"
        defaultImage: "../images/common/ico_freccia_dx.svg"
        pressedImage: "../images/common/ico_freccia_dx_P.svg"
        onPressed: rightClicked()
        anchors {
            bottom: parent.bottom
            bottomMargin: 11
            right: parent.right
            rightMargin: 7
        }
    }
}
