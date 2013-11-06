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


Column {
    id: control

    property alias text: leftText.text
    property alias repetitionWithSlowFastClicks: buttonPlus.repetitionWithSlowFastClicks

    signal plusClicked
    signal plusClickedSlow
    signal plusClickedFast
    signal minusClicked
    signal minusClickedSlow
    signal minusClickedFast

    ButtonImageThreeStates {
        id: buttonPlus

        z: 1
        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        repetitionOnHold: true
        onClicked: control.plusClicked()
        onClickedFast: control.plusClickedFast()
        onClickedSlow: control.plusClickedSlow()
    }

    SvgImage {
        id: bg
        source: "../images/common/bg_datetime.svg"
        anchors {
            left: buttonPlus.left
            right: buttonPlus.right
        }


        UbuntuLightText {
            id: leftText

            color: "#5b5b5b"
            font.pixelSize: 22
            anchors.centerIn: parent
        }
    }


    ButtonImageThreeStates {
        id: buttonMinus

        z: 1
        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        repetitionOnHold: true
        repetitionWithSlowFastClicks: buttonPlus.repetitionWithSlowFastClicks
        onClicked: control.minusClicked()
        onClickedFast: control.minusClickedFast()
        onClickedSlow: control.minusClickedSlow()
    }
}
