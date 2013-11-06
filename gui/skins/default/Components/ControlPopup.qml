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


Column {
    id: control

    property alias title: title.text
    property alias line1: line1.text
    property alias line2: line2.text
    property alias line3: line3.text
    property alias confirmText: buttonConfirm.text
    property alias dismissText: buttonDismiss.text

    signal confirmClicked
    signal dismissClicked

    spacing: 4

    SvgImage {
        id: bgTitle

        source: "../images/scenarios/bg_titolo.svg"
        anchors.left: control.left

        UbuntuMediumText {
            id: title

            color: "white"
            font.pixelSize: 24
            text: "ANTINTRUSIONE"
            anchors {
                fill: parent
                leftMargin: parent.width / 100 * 2.27
                rightMargin: parent.width / 100 * 2.27
            }
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    SvgImage {
        id: bgBody

        source: "../images/scenarios/bg_testo.svg"
        anchors.left: control.left

        UbuntuMediumText {
            id: line1

            color: "white"
            font.pixelSize: 18
            text: "Zona 4 'persiane'"
            width: parent.width / 100 * 90
            elide: Text.ElideRight
            anchors {
                centerIn: bgBody
                verticalCenterOffset: -bgTitle.height / 100 * 28.09
            }
        }

        UbuntuLightText {
            id: line2

            color: "white"
            font.pixelSize: 18
            text: "14:27 - 10/09/2012"
            width: parent.width / 100 * 90
            elide: Text.ElideRight
            anchors {
                centerIn: bgBody
                verticalCenterOffset: 0
            }
        }

        UbuntuLightText {
            id: line3

            color: "white"
            font.pixelSize: 18
            text: "Manomissione"
            width: parent.width / 100 * 90
            elide: Text.ElideRight
            anchors {
                centerIn: bgBody
                verticalCenterOffset: bgTitle.height / 100 * 28.09
            }
        }
    }

    SvgImage {
        id: bgBottom

        source: "../images/scenarios/bg_ok_annulla.svg"
        anchors.left: control.left

        ButtonThreeStates {
            id: buttonDismiss
            visible: buttonDismiss.text !== ""
            defaultImage: "../images/common/btn_150x35.svg"
            pressedImage: "../images/common/btn_150x35.svg"
            selectedImage: "../images/common/btn_150x35.svg"
            shadowImage: "../images/common/btn_shadow_150x35.svg"
            text: qsTr("dismiss")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 14
            onPressed: dismissClicked()
            anchors {
                right: bgBottom.right
                rightMargin: bgTitle.width / 100 * 1.59
                bottom: bgBottom.bottom
                bottomMargin: bgTitle.height / 100 * 11.24
            }
        }

        ButtonThreeStates {
            id: buttonConfirm
            defaultImage: "../images/common/btn_150x35.svg"
            pressedImage: "../images/common/btn_150x35.svg"
            selectedImage: "../images/common/btn_150x35.svg"
            shadowImage: "../images/common/btn_shadow_150x35.svg"
            text: qsTr("confirm")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 14
            onPressed: confirmClicked()
            anchors {
                right: buttonDismiss.visible ? buttonDismiss.left : bgBottom.right
                rightMargin: buttonDismiss.visible ? 0 : bgTitle.width / 100 * 1.59
                bottom: bgBottom.bottom
                bottomMargin: bgTitle.height / 100 * 11.24
            }
        }
    }
}
