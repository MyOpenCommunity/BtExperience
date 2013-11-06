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


Image {
    id: controlBalance
    source: "../images/common/bg_panel_212x100.svg"
    property int value: 1
    // Range of the component, symmetric. [-range, +range]
    property int balanceRange: 10
    property string description: qsTr("balance")

    signal leftClicked
    signal rightClicked

    UbuntuLightText {
        id: label
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
            right: percentageLabel.left
            rightMargin: 7
        }
        font.pixelSize: 15
        color: "#444546"
        text: controlBalance.description
        elide: Text.ElideRight
    }

    UbuntuLightText {
        id: percentageLabel
        text: value > 0 ? "+" + value : value
        anchors {
            top: parent.top
            topMargin: 5
            right: parent.right
            rightMargin: 15
        }
        font.pixelSize: 15
        color: "white"
    }

    SvgImage {
        id: image1
        anchors {
            top: label.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        source: "../images/common/bg_regola_dimmer.svg"
    }

    SvgImage {
        id: image2
        x: image1.x + (image1.width - image2.width) * ((value + balanceRange) / (2 * balanceRange))
        anchors.verticalCenter: image1.verticalCenter
        source: "../images/common/cursore_bilanciamento.svg"
    }


    Row {
        anchors {
            top: image1.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }

        ButtonImageThreeStates {
            defaultImageBg: "../images/common/btn_99x35.svg"
            pressedImageBg: "../images/common/btn_99x35_P.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultImage: "../images/common/ico_freccia_sx.svg"
            pressedImage: "../images/common/ico_freccia_sx_P.svg"
            onPressed: leftClicked()
        }

        ButtonImageThreeStates {
            defaultImageBg: "../images/common/btn_99x35.svg"
            pressedImageBg: "../images/common/btn_99x35_P.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultImage: "../images/common/ico_freccia_dx.svg"
            pressedImage: "../images/common/ico_freccia_dx_P.svg"
            onPressed: rightClicked()
        }
    }
}
