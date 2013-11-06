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

    property alias text: radioLabel.text
    property alias pixelSize: radioLabel.font.pixelSize
    property bool status: false

    signal pressed

    height: radioBg.height

    UbuntuLightText {
        id: radioLabel

        font.pixelSize: 14
        color: "white"

        anchors {
            left: parent.left
            verticalCenter: radioBg.verticalCenter
        }
        width: parent.width / 100 * 90
        elide: Text.ElideRight
    }

    SvgImage {
        id: radioBg

        anchors {
            top: parent.top
            right: parent.right
        }

        source: "../images/common/btn_giorni.svg"

        SvgImage {
            source: "../images/common/check_giorni_azioni.svg"
            visible: control.status
            anchors.centerIn: parent
        }
    }

    BeepingMouseArea {
        anchors.fill: parent
        onPressed: control.pressed()
    }
}
