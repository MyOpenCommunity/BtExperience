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


SvgImage {
    id: control

    signal okClicked
    signal cancelClicked

    source: "../images/common/panel_212x50.svg"

    ButtonThreeStates {
        id: okButton

        defaultImage: "../images/common/btn_99x35.svg"
        pressedImage: "../images/common/btn_99x35_P.svg"
        selectedImage: "../images/common/btn_99x35_S.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        text: qsTr("ok")
        font.pixelSize: 15
        onPressed: control.okClicked()
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 7
        }
    }

    ButtonThreeStates {
        id: cancelButton

        defaultImage: "../images/common/btn_99x35.svg"
        pressedImage: "../images/common/btn_99x35_P.svg"
        selectedImage: "../images/common/btn_99x35_S.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        text: qsTr("cancel")
        font.pixelSize: 15
        onPressed: control.cancelClicked()
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 7
        }
    }
}
