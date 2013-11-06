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
    id: control

    property string separator: ","
    property string leftText
    property string rightText

    signal leftPlusClicked
    signal leftMinusClicked
    signal rightPlusClicked
    signal rightMinusClicked

    width: buttonLeftPlus.width + buttonRightPlus.width
    height: buttonLeftPlus.height + bg.height + buttonLeftMinus.height


    ButtonImageThreeStates {
        id: buttonLeftPlus
        z: 1
        anchors {
            top: parent.top
            left: parent.left
        }

        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        repetitionOnHold: true
        onClicked: control.leftPlusClicked()
    }

    ButtonImageThreeStates {
        id: buttonRightPlus
        z: 1
        anchors {
            top: parent.top
            left: buttonLeftPlus.right
        }

        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        repetitionOnHold: true
        onClicked: control.rightPlusClicked()
    }

    SvgImage {
        id: bg
        source: "../images/common/bg_datetime.svg"
        anchors {
            top: buttonLeftPlus.bottom
            left: buttonLeftPlus.left
            right: buttonRightPlus.right
        }
    }

    ButtonImageThreeStates {
        id: buttonLeftMinus
        z: 1
        anchors {
            top: bg.bottom
            left: parent.left
        }

        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        repetitionOnHold: true
        onClicked: control.leftMinusClicked()
    }

    ButtonImageThreeStates {
        id: buttonRightMinus
        z: 1
        anchors {
            top: bg.bottom
            left: buttonLeftMinus.right
        }

        defaultImageBg: "../images/common/btn_99x35.svg"
        pressedImageBg: "../images/common/btn_99x35_P.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        repetitionOnHold: true
        onClicked: control.rightMinusClicked()
    }


    UbuntuLightText {
        id: leftText

        text: control.leftText
        color: "#5b5b5b"
        font.pixelSize: 22
        anchors.horizontalCenter: buttonLeftMinus.horizontalCenter
        anchors.verticalCenter: bg.verticalCenter
    }

    UbuntuLightText {
        id: separator1

        text: control.separator
        color: "#5b5b5b"
        font.pixelSize: 22
        anchors.verticalCenter: bg.verticalCenter
        anchors.left: buttonLeftMinus.right
        anchors.leftMargin: - paintedWidth / 2
    }

    UbuntuLightText {
        id: rightText

        text: control.rightText
        color: "#5b5b5b"
        font.pixelSize: 22
        anchors.horizontalCenter: buttonRightMinus.horizontalCenter
        anchors.verticalCenter: bg.verticalCenter
    }
}

