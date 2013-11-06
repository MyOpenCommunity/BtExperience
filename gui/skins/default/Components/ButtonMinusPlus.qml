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

Item {
    id: button

    signal plusClicked
    signal minusClicked

    width: 212
    height: 50

    ButtonImageThreeStates {
        defaultImageBg: "../images/common/button_1-2.svg"
        pressedImageBg: "../images/common/button_1-2_p.svg"
        shadowImage: "../images/common/shadow_button_1-2.svg"
        defaultImage: "../images/common/symbol_minus.svg"
        pressedImage: "../images/common/symbol_minus.svg"
        repetitionOnHold: true
        onPressed: button.minusClicked()
        anchors {
            left: parent.left
            leftMargin: 7
            bottom: parent.bottom
            bottomMargin: 5
        }
    }

    ButtonImageThreeStates {
        defaultImageBg: "../images/common/button_1-2.svg"
        pressedImageBg: "../images/common/button_1-2_p.svg"
        shadowImage: "../images/common/shadow_button_1-2.svg"
        defaultImage: "../images/common/symbol_plus.svg"
        pressedImage: "../images/common/symbol_plus.svg"
        repetitionOnHold: true
        onPressed: button.plusClicked()
        anchors {
            right: parent.right
            rightMargin: 7
            bottom: parent.bottom
            bottomMargin: 5
        }
    }
}
