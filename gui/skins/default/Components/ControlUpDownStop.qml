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

    signal pressed(int newStatus)

    width: bg.width
    height: bg.height

    SvgImage {
        id: bg
        source: "../images/common/bg_on-off.svg"
    }

    Row {
        anchors.centerIn: parent // in this way we need no margins

        ButtonThreeStatesAutomation {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultIcon: "../images/common/ico_alza.svg"
            pressedIcon: "../images/common/ico_alza_P.svg"
            selectedIcon: ""
            onPressed: {control.pressed(status == 0 ? 1 : 0); console.log("ControlOpenCloseStop.qml A STATUS "+status+" CONTROL "+control.status)}
            status: control.status === -1 ? 0 : (control.status == 1 ? 1 : 0)

        }

        ButtonThreeStatesAutomation {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            defaultIcon: "../images/common/ico_abbassa.svg"
            pressedIcon: "../images/common/ico_abbassa_P.svg"
            selectedIcon: ""
            onPressed: {control.pressed(status == 0 ? 2 : 0); console.log("ControlOpenCloseStop.qml B STATUS "+status+" CONTROL "+control.status)}
            status: control.status === -1 ? 0 : (control.status == 2 ? 1 : 0)
        }
    }

}

