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


SvgImage {
    id: bg

    property alias text: label.text

    property int status: 0 // 0 - gray, 1 - green

    source: "../../images/common/led_grey.svg"

    UbuntuLightText {
        id: label
        color: "black"
        anchors.centerIn: parent
        font.pixelSize: 9
    }

    states: [
        State {
            name: "green"
            when: status === 1
            PropertyChanges { target: bg; source: "../../images/common/led_green.svg" }
        }
    ]
}
