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

// On/Off control
// status: -1 no button is down ever, 0 off button is down, 1 on button is down
Item {
    id: control

    property int status: -1

    signal pressed
    signal released
    signal clicked

    width: bg.width
    height: bg.height

    SvgImage {
        id: bg
        source: "../images/common/bg_comando.svg"
    }

    Row {
        anchors.centerIn: parent // in this way we need no margins
        ButtonThreeStatesIcon {
            defaultImage: "../images/common/btn_apriporta_ok_on.svg"
            pressedImage: "../images/common/btn_apriporta_ok_on_P.svg"
            selectedImage: "../images/common/btn_apriporta_ok_on.svg"
            defaultIcon: "../images/common/ico_apriporta.svg"
            pressedIcon: "../images/common/ico_apriporta_P.svg"
            selectedIcon: "../images/common/ico_apriporta.svg"
            shadowImage: "../images/common/ombra_btn_apriporta_ok_on.svg"
            onPressed: control.pressed()
            onReleased: control.released()
            onClicked: control.clicked()
        }
    }

}
