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
    id: alert

    property alias message: text.text

    signal closePopup
    signal alertOkClicked
    signal alertCancelClicked

    spacing: 4

    SvgImage {
        source: "../images/scenarios/bg_titolo.svg"

        UbuntuMediumText {
            text: qsTr("Warning")
            font.pixelSize: 24
            color: "white"
            anchors {
                left: parent.left
                leftMargin: parent.width / 100 * 2
                right: parent.right
                rightMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }
            elide: Text.ElideRight
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_testo.svg"

        UbuntuMediumText {
            id: text
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "white"
            text: "Alert message goes here."
            wrapMode: Text.Wrap
            anchors {
                left: parent.left
                leftMargin: parent.width / 100 * 2
                right: parent.right
                rightMargin: parent.width / 100 * 2
            }
            elide: Text.ElideRight
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_ok_annulla.svg"

        Row {
            anchors {
                right: parent.right
                rightMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("ok")
                font.pixelSize: 14
                onPressed: {
                    alert.alertOkClicked()
                    alert.closePopup()
                }
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("cancel")
                font.pixelSize: 14
                onPressed: {
                    alert.alertCancelClicked()
                    alert.closePopup()
                }
            }
        }
    }
}



